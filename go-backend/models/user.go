package models

import "github.com/bwmarrin/snowflake"

var node, _ = snowflake.NewNode(1)

type User struct {
	ID       int64  `json:"user_id"`
	Username string `json:"username"`
	Password string `json:"password"`
}

func NewUser(username string, password string) *User {
	return &User{ID: node.Generate().Int64(), Username: username, Password: password}
}
