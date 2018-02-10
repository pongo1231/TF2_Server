#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_deadlywater_enabled", "0", "Enable plugin");
	CreateTimer(0.1, Timer_WaterCheck, _, TIMER_REPEAT);
}

public Action Timer_WaterCheck(Handle timer) {
	if (GetConVarBool(g_enabled))
		for (int i = 1; i < 33; i++)
			if (IsClientInGame(i) && GetEntProp(i, Prop_Data, "m_nWaterLevel"))
				FakeClientCommand(i, "kill");
}