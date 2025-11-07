-- ============================================
-- 员工事务管理系统数据库表设计
-- ============================================

-- 1. 用户表（user-service使用）
-- 用于用户登录、认证
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（加密后）',
  `employee_id` BIGINT DEFAULT NULL COMMENT '关联的员工ID',
  `role` TINYINT NOT NULL DEFAULT 0 COMMENT '角色：0-普通员工，1-部门经理，2-老板',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. 员工表（user-service使用）
-- 员工基本信息
CREATE TABLE `employees` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '员工ID',
  `name` VARCHAR(50) NOT NULL COMMENT '姓名',
  `employee_no` VARCHAR(20) DEFAULT NULL COMMENT '工号',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `department` VARCHAR(50) DEFAULT NULL COMMENT '部门',
  `position` VARCHAR(50) DEFAULT NULL COMMENT '职位',
  `hire_date` DATE DEFAULT NULL COMMENT '入职日期',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-离职，1-在职',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_employee_no` (`employee_no`),
  KEY `idx_department` (`department`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';

-- 3. 请假申请表（relax-service使用）
-- 请假申请和审批流程
CREATE TABLE `leave_requests` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '请假单ID',
  `employee_id` BIGINT NOT NULL COMMENT '员工ID',
  `employee_name` VARCHAR(50) NOT NULL COMMENT '员工姓名',
  `leave_type` VARCHAR(20) NOT NULL COMMENT '请假类型：年假、病假、事假等',
  `start_date` DATE NOT NULL COMMENT '开始日期',
  `end_date` DATE NOT NULL COMMENT '结束日期',
  `days` DECIMAL(5,1) NOT NULL COMMENT '请假天数',
  `reason` VARCHAR(500) DEFAULT NULL COMMENT '请假原因',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待审批，1-已通过，2-已拒绝',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审批人ID',
  `approver_name` VARCHAR(50) DEFAULT NULL COMMENT '审批人姓名',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审批时间',
  `approve_comment` VARCHAR(500) DEFAULT NULL COMMENT '审批意见',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请假申请表';

-- 4. 考勤记录表（work-service使用）
-- 员工签到/签退记录
CREATE TABLE `attendance_records` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '考勤记录ID',
  `employee_id` BIGINT NOT NULL COMMENT '员工ID',
  `employee_name` VARCHAR(50) NOT NULL COMMENT '员工姓名',
  `attendance_date` DATE NOT NULL COMMENT '考勤日期',
  `check_in_time` DATETIME DEFAULT NULL COMMENT '签到时间',
  `check_out_time` DATETIME DEFAULT NULL COMMENT '签退时间',
  `work_hours` DECIMAL(5,2) DEFAULT NULL COMMENT '工作时长（小时）',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-正常，1-迟到，2-早退，3-缺勤',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_employee_date` (`employee_id`, `attendance_date`),
  KEY `idx_attendance_date` (`attendance_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤记录表';

-- ============================================
-- 初始化测试数据
-- ============================================

-- 插入测试员工数据
INSERT INTO `employees` (`id`, `name`, `employee_no`, `phone`, `email`, `department`, `position`, `hire_date`, `status`) VALUES
(1, '张三', 'E001', '13800138001', 'zhangsan@example.com', '技术部', '高级工程师', '2023-01-01', 1),
(2, '李四', 'E002', '13800138002', 'lisi@example.com', '技术部', '部门经理', '2022-06-01', 1),
(3, '王五', 'E003', '13800138003', 'wangwu@example.com', '人事部', '老板', '2020-01-01', 1),
(4, '赵六', 'E004', '13800138004', 'zhaoliu@example.com', '技术部', '工程师', '2023-03-01', 1);

-- 插入测试用户数据
INSERT INTO `users` (`id`, `username`, `password`, `employee_id`, `role`, `status`) VALUES
(1, 'zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJw2', 1, 0, 1), -- 密码：123456
(2, 'lisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJw2', 2, 1, 1), -- 密码：123456
(3, 'wangwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJw2', 3, 2, 1), -- 密码：123456
(4, 'zhaoliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pJw2', 4, 0, 1); -- 密码：123456

