package models

import "encoding/json"

type IncomingMessage struct {
	Message interface{} `json:"-"`
	RawMessage json.RawMessage `json:"message"`
}

