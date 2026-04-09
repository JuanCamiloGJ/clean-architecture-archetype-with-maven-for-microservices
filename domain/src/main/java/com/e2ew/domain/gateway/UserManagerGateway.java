package com.e2ew.domain.gateway;

import com.e2ew.domain.model.User;

public interface UserManagerGateway {

    boolean isUsernameAvailable(String username);

    User getUserById(Long id);
}
