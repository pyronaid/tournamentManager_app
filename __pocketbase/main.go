package main

import (
	"log"
	"os"

	epapis "extended-pocketbase/internals/apis"
	"extended-pocketbase/internals/hooks"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

// importSchemaIfFresh reads pb_schema.json and imports all collections when the
// database has no user collections yet (fresh volume).  It is a no-op on every
// subsequent start because user collections will already exist.
func importSchemaIfFresh(app *pocketbase.PocketBase) error {
	data, err := os.ReadFile("./pb_schema.json")
	if err != nil {
		if os.IsNotExist(err) {
			log.Println("[startup] pb_schema.json not found — skipping schema import")
			return nil
		}
		return err
	}
	log.Printf("[startup] pb_schema.json read (%d bytes)", len(data))

	collections, err := app.FindAllCollections()
	if err != nil {
		return err
	}
	log.Printf("[startup] found %d collection(s) on bootstrap", len(collections))
	for _, c := range collections {
		log.Printf("[startup]   collection: %q", c.Name)
		// "tournaments" is an app-specific collection that PocketBase never
		// creates on its own (unlike "users", which v0.29+ creates automatically).
		// Its presence means the schema was already imported on a prior boot.
		if c.Name == "tournaments" {
			log.Println("[startup] 'tournaments' collection found — schema already imported, skipping")
			return nil
		}
	}

	if err := app.ImportCollectionsByMarshaledJSON(data, false); err != nil {
		log.Printf("[startup] schema import failed: %v", err)
		return err
	}
	log.Println("[startup] schema imported from pb_schema.json")
	return nil
}

func main() {
	app := pocketbase.New()

	// Import the schema on first boot (fresh pb_data volume).
	// Runs after Bootstrap completes so the DB connection is ready.
	app.OnBootstrap().BindFunc(func(e *core.BootstrapEvent) error {
		if err := e.Next(); err != nil {
			return err
		}
		return importSchemaIfFresh(app)
	})

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// serves static files from the provided public dir (if exists)
		se.Router.GET("/{path...}", apis.Static(os.DirFS("./pb_public"), false))
		return se.Next()
	})
	epapis.RegisterTournamentEnrollmentAPI(app)
	epapis.DeleteTournamentEnrollmentAPI(app)
	epapis.GetUserInfoToEnrollAPI(app)

	epapis.CreateRoundAPI(app)
	epapis.DeleteRoundAPI(app)
	epapis.CloseTournamentAPI(app)

	epapis.RegisterHeathCheckAPI(app)

	hooks.SetupNewsCollectionHooks(app)
	hooks.SetupEnrollmentsCollectionHooks(app)
	hooks.SetupRoundsCollectionHooks(app)

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
