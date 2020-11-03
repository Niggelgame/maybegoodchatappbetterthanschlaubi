package main

import (
	"log"
	"net/http"
)

const addr = ":8081"

func main() {

	// Creating a Handler, that has all the Client Connections saved
	handler := newHandler()
	// Starting the Handler Coroutines for the Channels

	go handler.run()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		r.BasicAuth()
		serverWs(handler, w, r)
	})

	err := http.ListenAndServe(addr, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
