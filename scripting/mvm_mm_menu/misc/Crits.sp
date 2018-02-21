#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <sdktools>

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_alwayscrits_enabled", "0", "Enable plugin", _, true, 0.0, true, 1.0);
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result) {
	if (GetConVarBool(g_enabled)) {
		result = true;
		return Plugin_Handled;
	}

	return Plugin_Continue;
}