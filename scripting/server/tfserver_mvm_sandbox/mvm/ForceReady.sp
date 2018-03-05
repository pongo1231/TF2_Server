#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <server/serverchat>

bool playing_mvm = false;

public void OnPluginStart() {
	CreateTimer(1.0, Timer_CheckReady, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public Action Timer_CheckReady(Handle timer) {
	if (!playing_mvm)
		return Plugin_Continue;

	bool players_ready = false;
	for (int i = 1; i < 33; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			if (!IsPlayerReady(i)) {
				players_ready = false;
				break;
			} else
				players_ready = true;

	if (players_ready) {
		ServerCommand("mp_restartround 10");
		for (int i = 1; i < 33; i++)
			if (IsClientInGame(i) && !IsFakeClient(i))
				MakePlayerReady(i, false);
	}

	return Plugin_Handled;
}

bool IsGamemodeMvm() {
	return GameRules_GetProp("m_bPlayingMannVsMachine") ? true : false;
}

bool IsPlayerReady(int client) {
	if (!IsClientInGame(client))
		return false;
	else
		return view_as<bool>(GameRules_GetProp("m_bPlayerReady", 1, client));
}

void MakePlayerReady(int client, bool state) {
	if (IsClientInGame(client))
		FakeClientCommand(client, "tournament_player_readystate %i", state);
}