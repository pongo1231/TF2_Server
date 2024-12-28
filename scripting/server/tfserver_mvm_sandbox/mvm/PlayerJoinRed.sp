#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	CreateTimer(5.0, Timer_JoinPlayersIntoTeam, _, TIMER_REPEAT);
}

public Action Timer_JoinPlayersIntoTeam(Handle timer) {
	for (int client = 1; client < MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client) && (TF2_GetClientTeam(client) == TFTeam_Spectator || TF2_GetClientTeam(client) == TFTeam_Unassigned)
			&& GetUserAdmin(client) == INVALID_ADMIN_ID)
			FakeClientCommand(client, "sm_mvmred");
	}
}
