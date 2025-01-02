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

Handle g_play_taunt;

int g_bot_taunt_time[MAXPLAYERS];

int GetRandomUInt(int min, int max)
{
    return RoundToFloor(GetURandomFloat() * (max - min + 1)) + min;
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

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen) {
    g_bot_taunt_time[client - 1] = 0;

    return true;
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	if (!GetConVarBool(g_enabled))
		return Plugin_Continue;

	int killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (killer == 0 || !IsFakeClient(killer))
		return Plugin_Continue;

	if (((playing_mvm && TF2_GetClientTeam(killer) == TFTeam_Blue) || !playing_mvm) && GetRandomUInt(0, 100) < GetConVarInt(g_taunt_chance)) {
		char class_name[16];
		GetClassString(class_name, sizeof(class_name), TF2_GetPlayerClass(killer));
		Handle class_taunts = GetClassTaunts(class_name);

		if (GetArraySize(class_taunts) > 0) {
			// Thanks to Pick from the bots-united.com Discord server for the logic

			int taunt = CreateEntityByName("tf_wearable_vm");

			if (!IsValidEntity(taunt))
			{
				return Plugin_Handled;
			}

			char entclass[64];
			GetEntityNetClass(taunt, entclass, sizeof(entclass));
			SetEntData(taunt, FindSendPropInfo(entclass, "m_iItemDefinitionIndex"), GetArrayCell(class_taunts, GetRandomUInt(0, GetArraySize(class_taunts) - 1)));
			SetEntData(taunt, FindSendPropInfo(entclass, "m_bInitialized"), 1);
			SetEntData(taunt, FindSendPropInfo(entclass, "m_iEntityLevel"), 1);
			SetEntData(taunt, FindSendPropInfo(entclass, "m_iEntityQuality"), 6);
			SetEntProp(taunt, Prop_Send, "m_bValidatedAttachedEntity", 1);

			Address pEconItemView = GetEntityAddress(taunt) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));

			SDKCall(g_play_taunt, killer, pEconItemView) ? 1 : 0;
			AcceptEntityInput(taunt, "Kill");
		}

		CloseHandle(class_taunts);
	}

	return Plugin_Continue;
}

public Action Timer_TauntTick(Handle timer) {
	for (int i = 1; i < MaxClients + 1; i++) {
		if (!IsClientConnected(i) || !IsFakeClient(i) || !TF2_IsPlayerInCondition(i, TFCond_Taunting)) {
			g_bot_taunt_time[i - 1] = 0;
			continue;
		}

		if (g_bot_taunt_time[i - 1] <= 0)
			g_bot_taunt_time[i - 1] = GetRandomUInt(15, 30);
		else if (--g_bot_taunt_time[i - 1] <= 0)
			TF2_RemoveCondition(i, TFCond_Taunting);
	}

	return Plugin_Continue;
}

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_bottaunt_enabled", "1", "Enable plugin");
	g_taunt_chance = CreateConVar("sm_bottaunt_chance", "100", "Chance for bots to taunt after kill", _, true, 0.0, true, 100.0);

	Handle conf = LoadGameConfigFile("tf2.tauntem");
	if (conf == INVALID_HANDLE)
	{
		SetFailState("Unable to load gamedata/tf2.tauntem.txt");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTFPlayer::PlayTauntSceneFromItem");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	g_play_taunt = EndPrepSDKCall();

	if (g_play_taunt == INVALID_HANDLE)
	{
		SetFailState("Unable to initialize call to CTFPlayer::PlayTauntSceneFromItem");
		CloseHandle(conf);
		return;
	}

	HookEvent("player_death", Event_PlayerDeath);

	CreateTimer(1.0, Timer_TauntTick, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != 0;
}
