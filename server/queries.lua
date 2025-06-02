QUERIES = {
    CREATE_USER = 'INSERT INTO `users` (identifiers) VALUES (?) RETURNING *;',
    DELETE_USER = 'DELETE FROM `users` WHERE id = ?',
    GET_USER_FROM_IDENTIFIER = "SELECT * FROM `users` WHERE JSON_SEARCH(identifiers, 'one', ?) IS NOT NULL LIMIT 1",
    UPDATE_USER_BAN_STATUS = 'UPDATE `users` SET banned = ? WHERE id = ?',
    UPDATE_USER_ALLOW_STATUS = 'UPDATE `users` SET allowed = ? WHERE id = ?',
    UPDATE_USER_MAX_CHARACTERS = 'UPDATE `users` SET maxCharacters = ? WHERE id = ?',
}
