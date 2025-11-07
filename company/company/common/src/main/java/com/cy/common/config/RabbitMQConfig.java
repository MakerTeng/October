package com.cy.common.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.amqp.core.Queue;

@Configuration
public class RabbitMQConfig {

    // 定义队列名称
    public static final String USER_QUEUE = "user.queue";
    public static final String WORK_QUEUE = "work.queue";
    public static final String RELAX_QUEUE = "relax.queue";

    /**
     * 用户服务队列
     */
    @Bean
    public Queue userQueue() {
        return new Queue(USER_QUEUE);
    }

    /**
     * 工作服务队列
     */
    @Bean
    public Queue workQueue() {
        return new Queue(WORK_QUEUE);
    }

    /**
     * 休闲服务队列
     */
    @Bean
    public Queue relaxQueue() {
        return new Queue(RELAX_QUEUE);
    }
}