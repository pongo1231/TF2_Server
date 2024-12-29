#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_deadlywater_enabled", "0", "Enable plugin", _, true, 0.0, true, 1.0);
	CreateTimer(0.1, Timer_WaterCheck, _, TIMER_REPEAT);
}

public Action Timer_WaterCheck(Handle timer) {
	if (GetConVarBool(g_enabled))
		for (int client = 1; client < MaxClients + 1; client++)
			if (IsClientInGame(client) && GetEntProp(client, Prop_Data, "m_nWaterLevel"))
				FakeClientCommand(client, "kill");
}
