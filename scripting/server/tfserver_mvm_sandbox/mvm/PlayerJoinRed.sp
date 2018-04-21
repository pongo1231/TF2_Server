#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	CreateTimer(5.0, Timer_JoinPlayersIntoTeam, _, TIMER_REPEAT);
}

public Action Timer_JoinPlayersIntoTeam(Handle timer) {
	for (int i = 1; i < GetMaxClients() + 1; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i) && (TF2_GetClientTeam(i) == TFTeam_Spectator || TF2_GetClientTeam(i) == TFTeam_Unassigned)
			&& GetUserAdmin(i) == INVALID_ADMIN_ID)
			FakeClientCommand(i, "sm_mvmred");
	}
}