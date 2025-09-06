#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <server/serverchat>

bool playing_mvm = false;

bool IsPlayerReady(int client) {
	return view_as<bool>(GameRules_GetProp("m_bPlayerReady", 1, client));
}

void MakePlayerReady(int client, bool state) {
	FakeClientCommand(client, "tournament_player_readystate %i", state);
}

Action Timer_CheckReady(Handle timer) {
	if (!playing_mvm)
		return Plugin_Continue;

	if (GameRules_GetRoundState() != RoundState_Preround && GameRules_GetRoundState() != RoundState_BetweenRounds)
		return Plugin_Continue;

	bool players_ready = true;
	for (int client = 1; client < MaxClients + 1; client++) {
		if (!IsClientInGame(client) || IsFakeClient(client) || TF2_GetClientTeam(client) != TFTeam_Red)
			continue;

		if (!IsPlayerReady(client)) {
			players_ready = false;
			break;
		}
	}

	if (players_ready) {
		for (int client = 1; client < MaxClients + 1; client++) {
			if (IsClientInGame(client) && TF2_GetClientTeam(client) == TFTeam_Red && !IsPlayerReady(client))
				MakePlayerReady(client, true);
		}
	}

	return Plugin_Handled;
}


public void OnPluginStart() {
	CreateTimer(1.0, Timer_CheckReady, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != 0;
}
