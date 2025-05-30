#include <sourcemod>
#include <tf2attributes>

ConVar g_enabled;
bool recently_disabled = false;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_hugeexplosions_enabled", "0", "Enable plugin");
	CreateTimer(2.0, Timer_HugeExplosions, _, TIMER_REPEAT)
}

public Action Timer_HugeExplosions(Handle timer, int client) {
	bool enabled = GetConVarBool(g_enabled);
	if (!enabled && !recently_disabled)
		return Plugin_Continue;

	recently_disabled = true;

	for (int client = 1; client < MaxClients + 1; client++)
		if (IsClientInGame(client))
			TF2Attrib_SetByName(client, "use large smoke explosion", enabled ? 1.0 : 0.0);

	if (!enabled && recently_disabled)
		recently_disabled = false;

	return Plugin_Handled;
}
