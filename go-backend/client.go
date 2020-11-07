package main

import (
	"github.com/Niggelgame/chatapp/go-backend/models"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"time"
)

const (
	// Time allowed to write a message to the peer.
	writeWait = 10 * time.Second

	// Time allowed to read the next pong message from the peer.
	pongWait = 60 * time.Second

	// Send pings to peer with this period. Must be less than pongWait.
	pingPeriod = (pongWait * 9) / 10

	// Maximum message size allowed from peer.
	maxMessageSize = 512
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

type ClientFunctions interface {
	GetChats() []*models.UserChat
	SendIntoChat(message *models.SendMessage)
}

type Client struct {
	handler *Handler

	user models.User

	conn *websocket.Conn

	send chan models.SendMessage

	createdChat chan models.UserChat
}

func (c *Client) GetChats() []*models.UserChat {
	userChats := []*models.UserChat{}
	for _, chat := range c.handler.chats {
		isIn := false

		for _, user := range chat.Users {
			if user.ID == c.user.ID {
				isIn = true
				break
			}
		}
		userChats = append(userChats, models.NewUserChat(*chat, isIn))
	}
	println(userChats)
	return userChats
}

func (c *Client) SendIntoChat(message *models.SendMessage) {
	println("Sending message", message)
	for _, chat := range c.handler.chats {
		if chat.ID == message.ChatID {
			//TODO: BAD CODE

			for _, u := range chat.Users {
				c.handler.sendmessage <- models.HandlerSendMessage{
					Message: *message,
					User:    u,
				}
			}
			return
		}
	}
}

func (c *Client) readPump() {
	defer func() {
		c.handler.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	// c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error { c.conn.SetReadDeadline(time.Now().Add(pongWait)); return nil })
	for {
		var message MessagePacket
		err := c.conn.ReadJSON(&message)

		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			} else {
				log.Println("Probably failed to decode JSON")
				log.Println(err)
			}
			break
		}

		switch m := message.Message.(type) {
		case *ReceiveMessage:
			sendMessage := models.NewSendMessage(m.Message, c.user.Username, m.ChatID)
			c.SendIntoChat(sendMessage)
		case *models.CreateChat:
			c.handler.createdChat <- *models.NewChat([]models.User{c.user}, m.Name)
		case *models.JoinChat:
			for _, chat := range c.handler.chats {
				if chat.ID == m.ChatID {
					chat.Users = append(chat.Users, c.user)
					c.conn.WriteJSON(models.NewJoinedChat(*m))
				}
			}
		case *models.LeaveChat:
			println("Leaving Chat")
			for _, chat := range c.handler.chats {
				if chat.ID == m.ChatID {
					for i, user := range chat.Users {
						if user.ID == c.user.ID {
							chat.Users = append(chat.Users[:i], chat.Users[i+1:]...)
							break
						}
					}
					println("Left Chat")
					c.conn.WriteJSON(models.NewLeftChat(*m))
					break
				}
			}
		}
	}
}

func (c *Client) writePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()
	for {
		select {
		case message, ok := <-c.send:
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			log.Println(message)

			c.conn.WriteJSON(message)

			n := len(c.send)
			for i := 0; i < n; i++ {
				message, ok = <-c.send
				c.conn.WriteJSON(message)
			}
		case chat, ok := <-c.createdChat:
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			err := c.conn.WriteJSON(chat)

			if err != nil {

			}
		case <-ticker.C:
			// c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func serverWs(handler *Handler, w http.ResponseWriter, r *http.Request) {
	name, ok := r.URL.Query()["username"]

	if !ok || len(name[0]) < 1 {
		http.Error(w, "No name provided", http.StatusBadRequest)
		return
	}

	password, ok := r.URL.Query()["password"]

	if !ok || len(name[0]) < 1 {
		http.Error(w, "No name provided", http.StatusBadRequest)
		return
	}

	u := models.NewUser(name[0], password[0])

	println(u)

	println(r.Header)

	conn, err := upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Println(err)
		return
	}

	n := name[0]

	log.Println("name: ", n)

	client := &Client{
		handler:     handler,
		conn:        conn,
		send:        make(chan models.SendMessage, 100),
		user:        *u,
		createdChat: make(chan models.UserChat, 100),
	}

	go client.writePump()
	go client.readPump()

	/*client.handler.chats = append(client.handler.chats, models.NewChat([]models.User{client.user}, client.user.Username))*/

	chats := client.GetChats()

	c := models.NewUserChats(chats)

	err = client.conn.WriteJSON(c)

	if err != nil {
		println("Cannot write Chats because of ", err)
	}

	client.handler.register <- client
}
