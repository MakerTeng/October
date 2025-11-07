package com.cy.relaxservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.function.context.config.ContextFunctionCatalogAutoConfiguration;

@SpringBootApplication(exclude = {ContextFunctionCatalogAutoConfiguration.class})
public class RelaxServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(RelaxServiceApplication.class, args);
    }

}
