#include <sourcemod>

ConVar g_forceClassProxy;
ConVar g_forceClass;

public void OnPluginStart() {
	g_forceClassProxy = CreateConVar("menu_bots_rcbot_forceclass", "None");
	HookConVarChange(g_forceClassProxy, OnBotForceClassProxyChange);
	g_forceClass = FindConVar("rcbot_force_class");
}

public void OnBotForceClassProxyChange(ConVar convar, char[] oldValue, char[] newValue) {
	if (StrEqual(newValue, "scout", false))
		SetConVarInt(g_forceClass, 1);
	else if (StrEqual(newValue, "soldier", false))
		SetConVarInt(g_forceClass, 2);
	else if (StrEqual(newValue, "pyro", false))
		SetConVarInt(g_forceClass, 3);
	else if (StrEqual(newValue, "demo", false))
		SetConVarInt(g_forceClass, 4);
	else if (StrEqual(newValue, "heavy", false))
		SetConVarInt(g_forceClass, 5);
	else if (StrEqual(newValue, "engineer", false))
		SetConVarInt(g_forceClass, 6);
	else if (StrEqual(newValue, "medic", false))
		SetConVarInt(g_forceClass, 7);
	else if (StrEqual(newValue, "sniper", false))
		SetConVarInt(g_forceClass, 8);
	else if (StrEqual(newValue, "spy", false))
		SetConVarInt(g_forceClass, 9);
	else
		SetConVarInt(g_forceClass, 0);
}