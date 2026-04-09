package com.e2ew.usecase;

import com.e2ew.domain.gateway.UserManagerGateway;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public class ExampleNamingUseCase {

    private final UserManagerGateway userManagerGateway;

    public String execute(String name) {
        boolean isAvailable = userManagerGateway.isUsernameAvailable(name);
        return isAvailable ? "Username is available" : "Username is taken";
    }
}
