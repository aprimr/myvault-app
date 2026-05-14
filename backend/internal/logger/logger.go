package logger

import (
	"log"
)

const (
	dev  = "development"
	prod = "production"
)

var env string

func Init(environment string) {
	env = environment

	log.SetFlags(log.Ldate | log.Ltime)
}

func Info(message string) {
	log.Println(message)
}

func Debug(message string) {
	if env == dev {
		log.Printf("[DEBUG]: %s \n", message)
	}
}

func Fatal(message string, err error) {
	if err != nil {
		log.Fatalf("[FATAL]: %s -> %v \n", message, err)
	} else {
		log.Fatalf("[FATAL]: %s \n", message)
	}
}

func Error(message string, err error) {
	if env == dev && err != nil {
		log.Printf("[ERROR]: %s -> %v", message, err)
	} else if env == prod || err == nil {
		log.Printf("[ERROR]: %s", message)
	}
}
