package main

import (
	"errors"
	"fmt"
	"net/http"
	"os"
	"sort"
	"time"

	"github.com/labstack/echo/v4"
	echodd "gopkg.in/DataDog/dd-trace-go.v1/contrib/labstack/echo.v4"
	"gopkg.in/DataDog/dd-trace-go.v1/ddtrace/tracer"
)

func main() {
	fmt.Fprintf(os.Stdout, "out: starting\n")
	fmt.Fprintf(os.Stderr, "err: starting\n")

	tracer.Start(tracer.WithDebugMode(true))
	defer tracer.Stop()

	fmt.Fprintf(os.Stdout, "out: tracer initialized\n")
	fmt.Fprintf(os.Stderr, "err: tracer initialized\n")

	e := echo.New()
	e.HideBanner = true
	e.Use(echodd.Middleware())

	e.GET("/env/", env)
	e.GET("/hello/", hello)

	err := e.Start(":8080")
	fmt.Fprintf(os.Stderr, "%s\n", err)
}

func env(c echo.Context) error {
	envs := os.Environ()
	sort.Strings(envs)
	for _, env := range envs {
		fmt.Println(env)
	}
	return c.JSON(http.StatusOK, envs)
}

func hello(c echo.Context) error {
	span, _ := tracer.StartSpanFromContext(c.Request().Context(), "controller")
	defer span.Finish()

	if time.Now().Second()%3 == 0 { // Sometimes I want to make an error.
		err := errors.New("error if seconds are a multiple of 3")
		fmt.Fprintf(os.Stderr, "ERR: %s\n", err)
		return err
	} else {
		msg := "Hello, World!"
		fmt.Fprintf(os.Stdout, "OUT: %s\n", msg)
		return c.String(http.StatusOK, msg)
	}
}
