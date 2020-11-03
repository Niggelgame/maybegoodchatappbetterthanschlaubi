package models

type SendMessage struct {
	Message string `json:"message"`
	Author  string `json:"author"`
	ChatID  int64  `json:"chat_id"`
	OP      string `json:"op"`
}

func NewSendMessage(message string, author string, chatID int64) *SendMessage {
	return &SendMessage{Message: message, Author: author, ChatID: chatID, OP: "receive_message"}
}

type HandlerSendMessage struct {
	Message SendMessage
	User User
}