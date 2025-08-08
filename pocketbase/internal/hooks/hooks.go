package hooks

import (
	"fmt"
	"log"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/types"
)

func SetupNewsCollectionHooks(app *pocketbase.PocketBase) {
	//CREATION OF NEW RECORDS
	app.OnRecordAfterCreateSuccess("news").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_news", value)
		}
		return nil
	})

	//DELETION OF NEW RECORDS
	app.OnRecordAfterDeleteSuccess("news").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_news", value)
		}
		return nil
	})

	//UPDATE OF NEW RECORDS
	app.OnRecordAfterUpdateSuccess("news").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_news", value)
		}
		return nil
	})
}

func SetupEnrollmentsCollectionHooks(app *pocketbase.PocketBase) {
	//CREATION OF NEW RECORDS
	app.OnRecordAfterCreateSuccess("enrollments").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_enrollments", value)
		}
		return nil
	})

	//DELETION OF NEW RECORDS
	app.OnRecordAfterDeleteSuccess("enrollments").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_enrollments", value)
		}
		return nil
	})

	//UPDATE OF NEW RECORDS
	app.OnRecordAfterUpdateSuccess("enrollments").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_enrollments", value)
		}
		return nil
	})
}

func SetupRoundsCollectionHooks(app *pocketbase.PocketBase) {
	//CREATION OF NEW RECORDS
	app.OnRecordAfterCreateSuccess("rounds").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_rounds", value)
		}
		return nil
	})

	//DELETION OF NEW RECORDS
	app.OnRecordAfterDeleteSuccess("rounds").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_rounds", value)
		}
		return nil
	})

	//UPDATE OF NEW RECORDS
	app.OnRecordAfterUpdateSuccess("rounds").BindFunc(func(e *core.RecordEvent) error {
		value := e.Record.GetString("id_tournament")
		if value != "" {
			return lastUpdateTargetRecord(app, "tournaments", "lastUpdated_rounds", value)
		}
		return nil
	})
}

func lastUpdateTargetRecord(app *pocketbase.PocketBase, targetCollection, fieldName, recordId string) error {

	err := app.RunInTransaction(func(txApp core.App) error {
		record, err := txApp.FindRecordById(targetCollection, recordId)
		if err != nil {
			return fmt.Errorf("failed to find record with ID %s in collection %s: %w", recordId, targetCollection, err)
		}
		fields := record.Collection().Fields
		found := false
		for _, field := range fields {
			if field.GetName() == fieldName {
				found = true
				break
			}
		}
		if !found {
			return fmt.Errorf("field %s does not exist in collection %s", fieldName, targetCollection)
		}

		lastValue := record.GetDateTime(fieldName)
		now := types.NowDateTime()
		if now.Time().After(lastValue.Time()) {
			record.Set(fieldName, now)
			if err := txApp.Save(record); err != nil {
				return fmt.Errorf("failed to save record: %w", err)
			}
		}

		return nil
	})

	if err != nil {
		log.Printf("Error updating %s in %s: %v", fieldName, targetCollection, err)
		return err
	}

	return nil

}
