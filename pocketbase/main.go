package main

import (
    "log"
    "os"

    "extended-pocketbase/internals/hooks"
    "github.com/pocketbase/pocketbase"
    "github.com/pocketbase/pocketbase/apis"
    "github.com/pocketbase/pocketbase/core"
)

func main() {
    app := pocketbase.New()

    app.OnServe().BindFunc(func(se *core.ServeEvent) error {
        // serves static files from the provided public dir (if exists)
        se.Router.GET("/{path...}", apis.Static(os.DirFS("./pb_public"), false))
        return se.Next()
    })
    //RegisterTournamentEnrollmentAPI(app)


    hooks.SetupNewsCollectionHooks(app)
    hooks.SetupEnrollmentsCollectionHooks(app)
    hooks.SetupRoundsCollectionHooks(app)

    if err := app.Start(); err != nil {
        log.Fatal(err)
    }
}