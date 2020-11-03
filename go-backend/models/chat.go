package models

type Chat struct {
	ID    int64  `json:"chat_id"`
	Users []User `json:"users"`
	Name string `json:"chat_name"`
	OP string `json:"op"`
}

func NewChat(users []User, name string) *Chat {
	return &Chat{ID: node.Generate().Int64(), Users: users, Name: name, OP: "receive_chat"}
}


type Chats struct {
	Chats []*Chat `json:"chats"`
	OP string `json:"op"`
}

func NewChats(chats []*Chat) *Chats {
	return &Chats{Chats: chats, OP: "receive_chats"}
}

type CreateChat struct {
	Name string `json:"name"`
}