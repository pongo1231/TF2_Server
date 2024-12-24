#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <server/serverchat>

bool playing_mvm = false;

public void OnPluginStart() {
	CreateTimer(1.0, Timer_CheckReady, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != 0;
}

public Action Timer_CheckReady(Handle timer) {
	if (!playing_mvm)
		return Plugin_Continue;

	bool players_ready = false;
	if (GameRules_GetRoundState() == RoundState_Preround || GameRules_GetRoundState() == RoundState_BetweenRounds) {
		for (int i = 1; i < MaxClients; i++)
			if (IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Red)
				if (!IsPlayerReady(i) && !IsFakeClient(i)) {
					players_ready = false;
					break;
				} else if (IsPlayerReady(i))
					if (IsFakeClient(i)) {
						players_ready = false;
						break;
					} else
						players_ready = true;
	}

	if (players_ready)
		for (int i = 1; i < MaxClients; i++)
			if (IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Red)
				MakePlayerReady(i, true);

	return Plugin_Handled;
}

bool IsPlayerReady(int client) {
	return view_as<bool>(GameRules_GetProp("m_bPlayerReady", 1, client));
}

void MakePlayerReady(int client, bool state) {
	FakeClientCommand(client, "tournament_player_readystate %i", state);
}
