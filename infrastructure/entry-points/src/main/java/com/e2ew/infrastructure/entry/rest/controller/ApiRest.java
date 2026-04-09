package com.e2ew.infrastructure.entry.rest.controller;

import com.e2ew.usecase.ExampleNamingUseCase;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/api/v1", produces = MediaType.APPLICATION_JSON_VALUE)
@Slf4j
@AllArgsConstructor
public class ApiRest {

    private final ExampleNamingUseCase exampleNamingUseCase;

    @GetMapping(path = "/validate-name")
    public ResponseEntity<String> registerUser(@RequestParam(name = "name") @NotBlank String name) {
        String result = exampleNamingUseCase.execute(name);
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }
}
