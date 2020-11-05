package models

type Chat struct {
	ID    int64  `json:"chat_id"`
	Users []User `json:"users"`
	Name  string `json:"chat_name"`
	OP    string `json:"op"`
}

type UserChat struct {
	ID       int64  `json:"chat_id"`
	Name     string `json:"chat_name"`
	IsJoined bool   `json:"is_joined"`
	OP       string `json:"op"`
	Chat     Chat   `json:"-"`
}

func NewUserChat(Chat Chat, isJoined bool) *UserChat {
	return &UserChat{ID: Chat.ID, Name: Chat.Name, IsJoined: isJoined, OP: Chat.OP, Chat: Chat}
}

func NewChat(users []User, name string) *Chat {
	return &Chat{ID: node.Generate().Int64(), Users: users, Name: name, OP: "receive_chat"}
}

type UserChats struct {
	Chats []*UserChat `json:"chats"`
	OP    string      `json:"op"`
}

func NewUserChats(chats []*UserChat) *UserChats {
	return &UserChats{Chats: chats, OP: "receive_chats"}
}

type CreateChat struct {
	Name string `json:"name"`
}

type JoinChat struct {
	ChatID int64 `json:"chat_id"`
}

type LeaveChat struct {
	ChatID int64 `json:"chat_id"`
}

type JoinedChat struct {
	ChatID int64  `json:"chat_id"`
	OP     string `json:"op"`
}

type LeftChat struct {
	ChatID int64  `json:"chat_id"`
	OP     string `json:"op"`
}

func NewJoinedChat(joinChat JoinChat) *JoinedChat {
	return &JoinedChat{ChatID: joinChat.ChatID, OP: "joined_chat"}
}

func NewLeftChat(leftChat LeaveChat) *LeftChat {
	return &LeftChat{ChatID: leftChat.ChatID, OP: "left_chat"}
}
