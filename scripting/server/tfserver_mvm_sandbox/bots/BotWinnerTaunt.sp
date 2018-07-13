#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf2_taunts_tf2idb/taunt_enforcer>
#include <tf2_taunts_tf2idb/tf2_extra_stocks>
#include <tf2idb>

public Plugin info = {
	name = "BotWeps",
	author = "pongo1231",
	description = "Gives TF2 bots custom weapons",
	version = "1.0",
	url = "n/a"
}
bool playing_mvm = false;

ConVar g_enabled;
ConVar g_taunt_chance;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_bottaunt_enabled", "1", "Enable plugin");
	g_taunt_chance = CreateConVar("sm_bottaunt_chance", "1.0", "Chance for bots to taunt after kill", _, true, 0.0, true, 100.0);

	HookEvent("player_death", Event_PlayerDeath);
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	if (!GetConVarBool(g_enabled))
		return Plugin_Continue;

	int killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (killer == 0 || !IsFakeClient(killer))
		return Plugin_Continue;

	if (((playing_mvm && TF2_GetClientTeam(killer) == TFTeam_Blue) || !playing_mvm) && GetRandomFloat(0.0, 100.0) < GetConVarFloat(g_taunt_chance)) {
		CTauntEnforcer enforcer = new CTauntEnforcer(LoadGameConfigFile("tf2.tauntem"));

		char class_name[16];
		GetClassString(class_name, sizeof(class_name), TF2_GetPlayerClass(killer));
		Handle class_taunts = GetClassTaunts(class_name);

		if (GetArraySize(class_taunts) > 0)
			enforcer.ForceTaunt(killer, GetArrayCell(class_taunts, GetRandomInt(0, GetArraySize(class_taunts) - 1)));
		CloseHandle(class_taunts);
	}

	return Plugin_Continue;
}

bool IsGamemodeMvm() {
	return GameRules_GetProp("m_bPlayingMannVsMachine") ? true : false;
}

Handle GetClassTaunts(char[] class_name) {
	char search_query[128];
	Format(search_query, sizeof(search_query), "SELECT a.id FROM tf2idb_item a JOIN tf2idb_class b ON a.id=b.id WHERE a.slot='taunt' AND b.class='%s'", class_name);
	Handle class_taunts = TF2IDB_FindItemCustom(search_query);

	return class_taunts;
}

void GetClassString(char[] buffer, int length, TFClassType class) {
	char class_name[16];

	switch (class) {
    	case TFClass_Scout:
    		class_name = "scout";
    	case TFClass_Soldier:
    		class_name = "soldier";
    	case TFClass_Pyro:
    		class_name = "pyro";
    	case TFClass_DemoMan:
    		class_name = "demoman";
    	case TFClass_Heavy:
    		class_name = "heavy";
    	case TFClass_Engineer:
    		class_name = "engineer";
    	case TFClass_Medic:
    		class_name = "medic";
    	case TFClass_Sniper:
    		class_name = "sniper";
    	case TFClass_Spy:
    		class_name = "spy";
    }

	strcopy(buffer, length, class_name);
}