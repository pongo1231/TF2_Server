#include <sourcemod>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	CreateTimer(1.0, Timer_AddAttribsToActiveWep, _, TIMER_REPEAT);
	HookEvent("player_builtobject", Event_PlayerBuiltObject);
}

public Action Timer_AddAttribsToActiveWep(Handle timer) {
	for (int i = 1; i < GetMaxClients(); i++)
		if (IsClientInGame(i) && IsFakeClient(i) && TF2_GetClientTeam(i) == TFTeam_Red)  {
			int wep = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");

			TF2Attrib_SetByName(wep, "heal on hit for rapidfire", 1000.0);
			TF2Attrib_SetByName(wep, "damage bonus", 3.0);
			TF2Attrib_SetByName(wep, "ammo regen", 1.0);
			TF2Attrib_SetByName(wep, "clip size bonus", 3.0);
			TF2Attrib_SetByName(wep, "fire rate bonus", 0.7);
			TF2Attrib_SetByName(wep, "mod rage on hit bonus", 100.0);
			TF2Attrib_SetByName(wep, "Reload time decreased", 0.5);

			switch (TF2_GetPlayerClass(i)) {
				case TFClass_Engineer: {
					TF2Attrib_SetByName(wep, "engy sentry damage bonus", 1.0);
					TF2Attrib_SetByName(wep, "engy building health bonus", 1.0);
					TF2Attrib_SetByName(wep, "engineer sentry build rate multiplier", 200.0);
					TF2Attrib_SetByName(wep, "metal regen", 1000.0);
				}
				case TFClass_Medic: {
					TF2Attrib_SetByName(wep, "ubercharge rate bonus", 500.0);
					TF2Attrib_SetByName(wep, "generate rage on heal", 100.0);
				}
			}

		}
}

public Action Event_PlayerBuiltObject(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && TF2_GetClientTeam(client) == TFTeam_Red) {
		int sentry = GetEventInt(event, "index");
		SetEntProp(sentry, Prop_Send, "m_iUpgradeLevel", 3);
		SetEntProp(sentry, Prop_Send, "m_iAmmoShells", -1); 
	}
}