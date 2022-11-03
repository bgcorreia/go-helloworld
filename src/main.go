package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

func PrettyString(str string) (string, error) {
	var prettyJSON bytes.Buffer
	if err := json.Indent(&prettyJSON, []byte(str), "", "    "); err != nil {
		return "", err
	}
	return prettyJSON.String(), nil
}

func logHttpRequest(req *http.Request) {
	log.Println(fmt.Sprintf("Method: \"%v\", URI: \"%v\", User-Agent: \"%v\"", req.Method, req.URL.String(), req.Header.Get("User-Agent")))
}

func root(w http.ResponseWriter, req *http.Request) {
	logHttpRequest(req)
	location := os.Getenv("LOCATION")
	jsonData := []byte(fmt.Sprintf(`{"info": "Welcome on the Go program from TCC's Bruno","location": "%v"}`, location))

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonData)
}

func status(w http.ResponseWriter, req *http.Request) {
	logHttpRequest(req)

	jsonData := []byte(fmt.Sprintf(`{"status": "ok"}`))

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonData)
}

func main() {
	httpPort := os.Getenv("PORT")

	http.HandleFunc("/", root)
	http.HandleFunc("/health", status)

	fmt.Printf("Listening on %v\n", httpPort)

	http.ListenAndServe(fmt.Sprintf(":%v", httpPort), nil)
}
