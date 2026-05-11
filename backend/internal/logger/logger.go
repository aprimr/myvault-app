package logger

import (
	"log"
)

var env string

func Init(environment string) {
	env = environment

	log.SetFlags(log.Ldate | log.Ltime | log.Llongfile)
}

func Info(message string) {
	log.Println(message)
}

func Debug(message string) {
	if env == "development" {
		log.Printf("[DEBUG]: %s \n", message)
	}
}

func Fatal(message string, err error) {
	if err != nil {
		log.Fatalf("[FATAL]: %s -> %s \n", message, err)
	} else {
		log.Fatalf("[FATAL]: %s \n", message)
	}
}

func Error(message string, err error) {
	if env == "development" && err != nil {
		log.Printf("[ERROR]: %s -> %s", message, err)
	} else {
		log.Printf("[ERROR]: %s", message)
	}
}
