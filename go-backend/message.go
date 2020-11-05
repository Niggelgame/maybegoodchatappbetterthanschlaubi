package main

import (
	"encoding/json"
	"errors"
	"github.com/Niggelgame/chatapp/go-backend/models"
)

type ReceiveMessage struct {
	Message string `json:"message"`
	ChatID  int64  `json:"chat_id"`
}

type MessagePacket struct {
	Message interface{} `json:"-"`
	RawMessage json.RawMessage `json:"message"`
	OP      string         `json:"op"`
}

func (m *MessagePacket) UnmarshalJSON(b []byte) error {
	type messagepacket MessagePacket

	println("Unmarshaling JSON of Client message")

	err := json.Unmarshal(b, (*messagepacket) (m))
	if err != nil {
		return err
	}

	var i interface{}

	switch m.OP {
	case "send_message":
		i = &ReceiveMessage{}
	case "created_chat":
		i = &models.CreateChat{}
	case "join_chat":
		i = &models.JoinChat{}
	case "leave_chat":
		println("Leaving Chat")
		i = &models.LeaveChat{}
	default:
		return errors.New("unknown message type")
	}

	err = json.Unmarshal(m.RawMessage, i)
	if err != nil {
		return err
	}

	m.Message = i

	return nil
}