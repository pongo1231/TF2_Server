#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

ConVar g_enabled;
ConVar g_rtdsay_min_dur;
ConVar g_rtdsay_max_dur;
ConVar g_rtdsay_mvmbots;
bool playing_mvm = false;
int playerData[32];

int GetRandomUInt(int min, int max)
{
    return RoundToFloor(GetURandomFloat() * (max - min + 1)) + min;
}

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_botrtd_enabled", "0", "Enable plugin");
	g_rtdsay_min_dur = CreateConVar("sm_botrtd_min_dur", "60", "Min duration until bot runs rtd (in secs)", _, true, 0.0);
	g_rtdsay_max_dur = CreateConVar("sm_botrtd_max_dur", "600", "Max duration until bot runs rtd (in secs)", _, true, 0.0);
	g_rtdsay_mvmbots = CreateConVar("sm_botrtd_mvmbots", "0", "Include mvm bots", _, true, 0.0, true, 1.0);
	for (int i = 0; i < sizeof(playerData); i++)
		playerData[i] = GetRandomUInt(GetConVarInt(g_rtdsay_min_dur), GetConVarInt(g_rtdsay_max_dur));
	CreateTimer(1.0, Timer_RTDTick, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") ? true : false;
}

public Action Timer_RTDTick(Handle timer) {
	if (!GetConVarBool(g_enabled))
		return Plugin_Continue;

	for (int client = 1; client < MaxClients + 1; client++) {
		if (IsClientInGame(client) && IsFakeClient(client) && IsPlayerAlive(client) && (!playing_mvm || TF2_GetClientTeam(client) != TFTeam_Blue || GetConVarBool(g_rtdsay_mvmbots))) {
			playerData[client - 1]--;
			if (playerData[client - 1] <= 0) {
				FakeClientCommand(client, "sm_rtd");
				playerData[client - 1] = GetRandomUInt(GetConVarInt(g_rtdsay_min_dur), GetConVarInt(g_rtdsay_max_dur));
			}
		}
	}

	return Plugin_Handled;
}
