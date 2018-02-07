#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <sdktools>

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_alwayscrits_enabled", "0", "Enable plugin");
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result) {
	if (GetConVarBool(g_enabled)) {
		result = true;
		return Plugin_Handled;
	}

	return Plugin_Continue;
}