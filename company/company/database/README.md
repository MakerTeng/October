# 员工事务管理系统数据库设计

## 数据库表结构

### 1. 用户表（users）- user-service使用

**用途**：存储用户登录信息，用于用户认证和授权

**字段说明**：
- `id`: 用户ID（主键）
- `username`: 用户名（唯一）
- `password`: 密码（加密后存储）
- `employee_id`: 关联的员工ID（外键关联employees表）
- `role`: 角色（0-普通员工，1-部门经理，2-老板）
- `status`: 状态（0-禁用，1-启用）
- `create_time`: 创建时间
- `update_time`: 更新时间

**索引**：
- 主键：id
- 唯一索引：username
- 普通索引：employee_id, role

---

### 2. 员工表（employees）- user-service使用

**用途**：存储员工基本信息，用于员工信息管理

**字段说明**：
- `id`: 员工ID（主键）
- `name`: 姓名
- `employee_no`: 工号（唯一）
- `phone`: 手机号
- `email`: 邮箱
- `department`: 部门
- `position`: 职位
- `hire_date`: 入职日期
- `status`: 状态（0-离职，1-在职）
- `create_time`: 创建时间
- `update_time`: 更新时间

**索引**：
- 主键：id
- 唯一索引：employee_no
- 普通索引：department, status

---

### 3. 请假申请表（leave_requests）- relax-service使用

**用途**：存储请假申请信息，支持请假申请和审批流程

**字段说明**：
- `id`: 请假单ID（主键）
- `employee_id`: 员工ID
- `employee_name`: 员工姓名（冗余字段，便于查询）
- `leave_type`: 请假类型（年假、病假、事假等）
- `start_date`: 开始日期
- `end_date`: 结束日期
- `days`: 请假天数
- `reason`: 请假原因
- `status`: 状态（0-待审批，1-已通过，2-已拒绝）
- `approver_id`: 审批人ID
- `approver_name`: 审批人姓名
- `approve_time`: 审批时间
- `approve_comment`: 审批意见
- `create_time`: 创建时间
- `update_time`: 更新时间

**索引**：
- 主键：id
- 普通索引：employee_id, status, create_time

**MQ消息流程**：
- 当经理审批完请假单后（status变为1或2），relax-service会向MQ发送"审批完成"消息
- 消息内容包含：请假单ID、员工ID、审批结果等
- 通知服务监听到消息后，执行发送通知操作

---

### 4. 考勤记录表（attendance_records）- work-service使用

**用途**：存储员工签到/签退记录

**字段说明**：
- `id`: 考勤记录ID（主键）
- `employee_id`: 员工ID
- `employee_name`: 员工姓名（冗余字段，便于查询）
- `attendance_date`: 考勤日期
- `check_in_time`: 签到时间
- `check_out_time`: 签退时间
- `work_hours`: 工作时长（小时）
- `status`: 状态（0-正常，1-迟到，2-早退，3-缺勤）
- `remark`: 备注
- `create_time`: 创建时间
- `update_time`: 更新时间

**索引**：
- 主键：id
- 唯一索引：employee_id + attendance_date（确保每天只有一条记录）
- 普通索引：attendance_date, status

---

## 角色说明

### 角色类型（role字段）
- **0 - 普通员工**：可以提交请假申请、查看自己的考勤记录
- **1 - 部门经理**：可以审批请假申请、查看部门员工的考勤记录
- **2 - 老板**：可以查看所有员工的请假申请和考勤记录

### 菜单权限（根据角色动态返回）
- 普通员工：我的请假、我的考勤
- 部门经理：我的请假、我的考勤、请假审批、部门考勤
- 老板：我的请假、我的考勤、请假审批、部门考勤、全部考勤、全部请假

---

## 服务与表的对应关系

| 服务 | 使用的表 | 说明 |
|------|---------|------|
| user-service | users, employees | 用户登录、员工信息管理 |
| relax-service | leave_requests | 请假申请、审批流程 |
| work-service | attendance_records | 考勤记录管理 |
| gateway | 无 | 仅做权限验证和转发 |
| common | 无 | 通用工具类，处理token |

---

## 使用说明

1. **执行SQL脚本**：
   ```sql
   source database/schema.sql
   ```

2. **测试账号**：
   - 普通员工：zhangsan / 123456
   - 部门经理：lisi / 123456
   - 老板：wangwu / 123456

3. **密码说明**：
   - 测试数据中的密码都是 `123456`（BCrypt加密）
   - 实际使用时需要使用BCryptPasswordEncoder进行加密

---

## 注意事项

1. **角色字段**：使用TINYINT类型，0-普通员工，1-部门经理，2-老板
2. **状态字段**：统一使用TINYINT类型，0表示禁用/拒绝/离职等，1表示启用/通过/在职等
3. **时间字段**：统一使用DATETIME类型，并设置自动更新
4. **MQ消息**：审批完成后，relax-service发送消息到MQ，通知服务监听并处理
5. **Token传递**：Gateway通过header传递user-info，common模块从ThreadLocal中获取

