package com.e2ew.infrastructure.driven.repository;

import com.e2ew.domain.gateway.UserManagerGateway;
import com.e2ew.domain.model.User;
import org.springframework.stereotype.Repository;

@Repository
public class UserManagerRepositoryAdapter implements UserManagerGateway {
    @Override
    public boolean isUsernameAvailable(String username) {
        return false;
    }

    @Override
    public User getUserById(Long id) {
        return null;
    }
}
