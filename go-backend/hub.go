package main

import (
	"github.com/Niggelgame/chatapp/go-backend/models"
	"log"
)


type Handler struct {
	clients map[*Client]bool

	sendmessage chan models.HandlerSendMessage

	createdChat chan models.Chat

	register chan *Client

	unregister chan *Client

	chats []*models.Chat
}

func newHandler() *Handler {
	return &Handler{
		sendmessage:  make(chan models.HandlerSendMessage, 100),
		createdChat: make(chan models.Chat, 100),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
		chats: []*models.Chat{},
	}
}

func (h *Handler) run() {
	for {
		select {
		case client := <-h.register:
			h.clients[client] = true
		case client := <-h.unregister:
			if _, ok := h.clients[client]; ok {
				log.Println("Unregistering client ", client.user.Username)
				delete(h.clients, client)
				close(client.send)
			}
		case m := <- h.sendmessage:
			println(h.clients)
			println("Sending message to", m.User.ID)
			for client := range h.clients {
				println("Client", client.user.ID)
				println("Message User ID", m.User.ID)
				if m.User.ID == client.user.ID {
					println("Found fitting Client for Message", m.User.ID, client.user.ID)
					select {
						case client.send <- m.Message:
					default:
						log.Println("Did NOT Sent out message ", m.Message, " by ", m.Message.Author, " to ", client.user.Username, " - Closing client connection")
						close(client.send)
					}
					break
				}
			}
		case c := <- h.createdChat:
			h.chats = append(h.chats, &c)
			for client := range h.clients {
				isIn := false
				for _, u := range c.Users {
					if u.ID == client.user.ID {
						isIn = true
						break
					}
				}

				select {
					case client.createdChat <- *models.NewUserChat(c, isIn):
				default:
					log.Println("Did NOT Sent out chat creation command")
					close(client.send)
				}
			}
		}

	}
}