package main

import (
    "log"
    "os"

    "extended-pocketbase/internal/hooks"
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


    SetupNewsCollectionHooks(app)
    SetupEnrollmentsCollectionHooks(app)
    //SetupRoundsCollectionHooks(app)

    if err := app.Start(); err != nil {
        log.Fatal(err)
    }
}