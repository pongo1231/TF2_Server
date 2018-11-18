#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

ConVar g_enabled;
ConVar g_rtdsay_min_dur;
ConVar g_rtdsay_max_dur;
ConVar g_rtdsay_mvmbots;
bool playing_mvm = false;
int playerData[32];

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_botrtd_enabled", "0", "Enable plugin");
	g_rtdsay_min_dur = CreateConVar("sm_botrtd_min_dur", "60", "Min duration until bot runs rtd (in secs)", _, true, 0.0);
	g_rtdsay_max_dur = CreateConVar("sm_botrtd_max_dur", "600", "Max duration until bot runs rtd (in secs)", _, true, 0.0);
	g_rtdsay_mvmbots = CreateConVar("sm_botrtd_mvmbots", "0", "Include mvm bots", _, true, 0.0, true, 1.0);
	for (int i = 0; i < sizeof(playerData); i++)
		playerData[i] = GetRandomInt(GetConVarInt(g_rtdsay_min_dur), GetConVarInt(g_rtdsay_max_dur));
	CreateTimer(1.0, Timer_RTDTick, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") ? true : false;
}

public Action Timer_RTDTick(Handle timer) {
	if (!GetConVarBool(g_enabled))
		return Plugin_Continue;

	for (int i = 1; i < 32; i++) {
		if (IsClientInGame(i) && IsFakeClient(i) && (!playing_mvm || TF2_GetClientTeam(i) != TFTeam_Blue || GetConVarBool(g_rtdsay_mvmbots))) {
			playerData[i - 1]--;
			if (playerData[i - 1] <= 0) {
				FakeClientCommand(i, "sm_rtd");
				playerData[i - 1] = GetRandomInt(GetConVarInt(g_rtdsay_min_dur), GetConVarInt(g_rtdsay_max_dur));
			}
		}
	}

	return Plugin_Handled;
}