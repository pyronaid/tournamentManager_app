package hooks

import (
	"fmt"
	"time"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// NotificationResult represents the result of a push notification attempt
type NotificationResult struct {
	Success   bool
	TotalSent int
	Error     string
}

// NotificationHelper provides methods for handling notifications
type NotificationHelper struct {
	app *pocketbase.PocketBase
}

// NewNotificationHelper creates a new notification helper instance
func NewNotificationHelper(app *pocketbase.PocketBase) *NotificationHelper {
	return &NotificationHelper{
		app: app,
	}
}

func (h *NotificationHelper) CreateNotificationRecord(record *core.Record, playerA string, playerB string, tableIndex int) error {
	// Get the notifications collection
	notifications, err := h.app.FindCollectionByNameOrId("notifications")
	if err != nil {
		h.app.Logger().Error(fmt.Sprintf("[CreateNotificationRecord] Failed to find notifications collection: %v", err))
		return err
	}

	// Create new notification record
	notification := core.NewRecord(notifications)
	notification.Set("playerAId", playerA)
	notification.Set("playerBId", playerB)
	notification.Set("tableIndex", tableIndex)
	notification.Set("id_record", record.Id)
	if err := h.app.Save(record); err != nil {
		h.app.Logger().Error(fmt.Sprintf("[CreateNotificationRecord] notifications insert failed: %v", err))
		return fmt.Errorf("[CreateNotificationRecord] notifications insert failed: %v", err)
	}

	return nil
}

func (h *NotificationHelper) GetUserTokens(userId string) ([]string, error) {
	// Get the notifications collection
	deviceTokens, err := h.app.FindCollectionByNameOrId("device_tokens")
	if err != nil {
		h.app.Logger().Error(fmt.Sprintf("[GetUserTokens] Failed to find device_tokens collection: %v", err))
		return nil, err
	}

	// Query the device_tokens collection for this user's tokens
	records, err := h.app.FindRecordsByFilter(
		deviceTokens, // collection name
		"id_user = {:userId}",
		"-created", // sort by created descending
		0,          // limit (0 = no limit)
		0,          // offset
		map[string]any{
			"userId": userId,
		},
	)

	if err != nil || len(records) == 0 {
		h.app.Logger().Error("[GetUserTokens] Failed to query device_tokens for user %s: %v", userId, err)
		return nil, fmt.Errorf("[GetUserTokens] Failed to query device_tokens for user %s: %v", userId, err)
	}

	// Extract tokens from records
	tokens := make([]string, 0, len(records))
	for _, record := range records {
		token := record.GetString("token")
		if token != "" {
			tokens = append(tokens, token)
		}
	}

	return tokens, nil
}

// GetNotificationTitle returns the notification title based on status
func (h *NotificationHelper) GetNotificationTitle(tournamentName string, roundIndex int) string {
	return fmt.Sprintf("[%s] Nuovo pairing per il Round %d", tournamentName, roundIndex)
}
func (h *NotificationHelper) GetNotificationMessage(tableIndex int, playerName string, playerSurname string, playerUsername string, playerOpponentName string, playerOpponentSurname string, playerOpponentUsername string) string {
	return fmt.Sprintf("Ciao %s %s (@%s), sei stato abbinato al tavolo %d contro %s %s (@%s). Buona partita!", playerName, playerSurname, playerUsername, tableIndex, playerOpponentName, playerOpponentSurname, playerOpponentUsername)
}

// SendPushNotification sends a push notification via Firebase FCM
func (h *NotificationHelper) SendPushNotification(tokens []string, title string, body string, data map[string]string) NotificationResult {
	// TODO: Implement actual Firebase FCM integration
	// This is a placeholder that you'll need to implement with Firebase Admin SDK

	// For now, return a mock success
	h.app.Logger().Debug(fmt.Sprintf("[FCM] Would send notification: %s - %s to %d devices", title, body, len(tokens)))

	return NotificationResult{
		Success:   true,
		TotalSent: len(tokens),
		Error:     "",
	}
}

func SetupPairingsCollectionHooks(app *pocketbase.PocketBase) {
	//CREATION OF NEW RECORDS
	app.OnRecordAfterCreateSuccess("pairings").BindFunc(func(e *core.RecordEvent) error {
		playerAId := e.Record.GetString("id_tournament")
		playerAName := e.Record.GetString("id_tournament")
		playerASurname := e.Record.GetString("id_tournament")
		playerAUsername := e.Record.GetString("id_tournament")
		playerBId := e.Record.GetString("id_tournament")
		playerBIdName := e.Record.GetString("id_tournament")
		playerBIdSurname := e.Record.GetString("id_tournament")
		playerBIdUsername := e.Record.GetString("id_tournament")
		roundIndex := e.Record.GetInt("id_tournament")
		tableIndex := e.Record.GetInt("id_tournament")
		tournamentName := e.Record.GetString("id_tournament")

		if playerAId != "" && playerBId != "" && tableIndex != 0 && tournamentName != "" {
			// Create notification helper instance
			helper := NewNotificationHelper(app)

			// Create notification record in database for history
			if err := helper.CreateNotificationRecord(e.Record, playerAId, playerBId, tableIndex); err != nil {
				app.Logger().Warn(fmt.Sprintf("[Notification Hook] Failed to create notification record: %v", err))
				// Continue anyway - don't block on history creation
			}

			for _, playerId := range []string{playerAId, playerBId} {
				playerName := ""
				playerSurname := ""
				playerUsername := ""
				playerOpponentName := ""
				playerOpponentSurname := ""
				playerOpponentUsername := ""
				if playerId == playerAId {
					playerName = playerAName
					playerSurname = playerASurname
					playerUsername = playerAUsername
					playerOpponentName = playerBIdName
					playerOpponentSurname = playerBIdSurname
					playerOpponentUsername = playerBIdUsername
				} else {
					playerName = playerBIdName
					playerSurname = playerBIdSurname
					playerUsername = playerBIdUsername
					playerOpponentName = playerAName
					playerOpponentSurname = playerASurname
					playerOpponentUsername = playerAUsername
				}

				// Push notification to player A and B
				tokens, err := helper.GetUserTokens(playerId)
				if err != nil {
					app.Logger().Error("[Notification Hook] Failed to get user tokens for playerId %s: %v", playerId, err)
					continue
				}

				if len(tokens) == 0 {
					app.Logger().Error(fmt.Sprintf("[Notification Hook] No FCM tokens found for playerId %s", playerId))
					continue
				}

				app.Logger().Debug(fmt.Sprintf("[Notification Hook] Found %d token(s) for user %s", len(tokens), playerId))

				// Prepare notification content
				title := helper.GetNotificationTitle(tournamentName, roundIndex)
				body := helper.GetNotificationMessage(tableIndex, playerName, playerSurname, playerUsername, playerOpponentName, playerOpponentSurname, playerOpponentUsername)

				data := map[string]string{
					"otherData": "foo",
					"timestamp": time.Now().Format(time.RFC3339),
				}

				result := helper.SendPushNotification(tokens, title, body, data)

				if result.Success {
					app.Logger().Debug("[Notification Hook] [player %d] ✅ Notification sent successfully to %d devices", playerId, result.TotalSent)
				} else {
					app.Logger().Error("[Notification Hook] [player %d] ❌ Failed to send notification: %s", playerId, result.Error)
				}

			}

		} else {
			app.Logger().Error("[Notification Hook] Error: Missing required fields to push pairing creation")
		}

		return nil
	})
}
