#include <sourcemod>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>

bool playing_mvm = false;

public void OnPluginStart() {
	CreateTimer(1.0, Timer_AddAttribsToActiveWep, _, TIMER_REPEAT);
	HookEvent("player_builtobject", Event_PlayerBuiltObject);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != 0;
}

public Action Timer_AddAttribsToActiveWep(Handle timer) {
	if (!playing_mvm)
		return Plugin_Continue;

	for (int client = 1; client < MaxClients; client++) {
		if (!IsClientInGame(client) || !IsFakeClient(client) || TF2_GetClientTeam(client) != TFTeam_Red)
			continue;
		
		TF2Attrib_SetByName(client, "dmg taken from fire reduced", 0.5);
		TF2Attrib_SetByName(client, "dmg taken from crit reduced", 0.1);
		TF2Attrib_SetByName(client, "dmg taken from blast reduced", 0.5);
		TF2Attrib_SetByName(client, "dmg taken from bullets reduced", 0.5);
		TF2Attrib_SetByName(client, "health regen", 2.0);
		TF2Attrib_SetByName(client, "ammo regen", 0.1);

		int wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		//TF2Attrib_SetByName(wep, "heal on hit for rapidfire", 2.0);
		TF2Attrib_SetByName(wep, "damage bonus", 4.0);
		TF2Attrib_SetByName(wep, "clip size bonus", 3.0);
		TF2Attrib_SetByName(wep, "fire rate bonus", 0.7);
		TF2Attrib_SetByName(wep, "mod rage on hit bonus", 1000.0);
		TF2Attrib_SetByName(wep, "heal on kill", 25.0);
		TF2Attrib_SetByName(wep, "Reload time decreased", 0.5);
		//TF2Attrib_SetByName(wep, "critboost on kill", 5.0);
		TF2Attrib_SetByName(wep, "slow enemy on hit", 1.0);
		TF2Attrib_SetByName(wep, "attack projectiles", 100.0);
		TF2Attrib_SetByName(wep, "melee range multiplier", 3.0);

		switch (TF2_GetPlayerClass(client)) {
			case TFClass_Scout: {
				TF2Attrib_SetByName(client, "move speed bonus", 1.3);
				TF2Attrib_SetByName(client, "increased jump height", 1.6);
			}
			case TFClass_Soldier: {
				TF2Attrib_SetByName(wep, "rocket specialist", 4.0);
			}
			case TFClass_Pyro: {
				TF2Attrib_SetByName(wep, "airblast pushback scale", 300.0);
				TF2Attrib_SetByName(wep, "mult airblast refire time", 0.1);
				TF2Attrib_SetByName(wep, "airblast cost decreased", 0.1);
			}
			case TFClass_Engineer: {
				TF2Attrib_SetByName(client, "engy sentry damage bonus", 3.0);
				TF2Attrib_SetByName(client, "engy building health bonus", 4.0);
				TF2Attrib_SetByName(client, "engineer sentry build rate multiplier", 200.0);
				TF2Attrib_SetByName(client, "engy sentry radius increased", 1000.0);
				TF2Attrib_SetByName(client, "metal regen", 1000.0);
				TF2Attrib_SetByName(client, "bidirectional teleport", 1.0);
				TF2Attrib_SetByName(client, "engy dispenser radius increased", 7.0);
			}
			case TFClass_Medic: {
				TF2Attrib_SetByName(wep, "ubercharge rate bonus", 500.0);
				TF2Attrib_SetByName(wep, "generate rage on heal", 100.0);
			}
			case TFClass_Sniper: {
				TF2Attrib_SetByName(wep, "damage bonus", 7.0);
				TF2Attrib_SetByName(wep, "sniper charge per sec", 10000.0);
				TF2Attrib_SetByName(wep, "Reload time decreased", 0.1);
				TF2Attrib_SetByName(wep, "explosive sniper shot", 10.0);
			}
			case TFClass_Spy: {
				TF2Attrib_SetByName(client, "move speed bonus", 1.5);
				TF2Attrib_SetByName(client, "increased jump height", 1.6);
				TF2Attrib_SetByName(client, "sanguisuge", 1.0);
			}
		}
	}

	return Plugin_Handled;
}

public Action Event_PlayerBuiltObject(Handle event, const char[] name, bool dontBroadcast) {
	if (!playing_mvm)
		return Plugin_Continue;

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(client) || TF2_GetClientTeam(client) != TFTeam_Red)
		return Plugin_Continue;

	int sentry = GetEventInt(event, "index");
	//SetEntProp(sentry, Prop_Send, "m_iUpgradeLevel", 3);
	SetEntProp(sentry, Prop_Send, "m_iAmmoShells", 9999999999);

	return Plugin_Continue;
}
