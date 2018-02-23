/**
*   NOTE: Unused!
*/

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf2idb>
#include <sdktools>

public Plugin info = {
	name = "BotWeps",
	author = "pongo1231",
	description = "Gives TF2 bots custom weapons",
	version = "1.0",
	url = "n/a"
}

char wep_slots[][] = {"primary", "secondary", "melee"};
char blacklist_classnames[][] = {"tf_weapon_shotgun", "saxxy"};
Handle g_hWeaponEquip;

public void OnPluginStart() {
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetFromConf(LoadGameConfigFile("give.bots.weapons"), SDKConf_Virtual, "WeaponEquip");
    PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
    g_hWeaponEquip = EndPrepSDKCall();

    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if (IsFakeClient(client))
        for (int wep_slot = 0; wep_slot < 3; wep_slot++) {
            TF2_RemoveWeaponSlot(client, wep_slot);

            char client_class[16];
            GetClassString(client_class, sizeof(client_class), TF2_GetPlayerClass(client));

            char search_query[512];
            Format(search_query, sizeof(search_query), "SELECT a.id FROM tf2idb_item a JOIN tf2idb_class b ON a.id=b.id WHERE b.class='%s' AND a.baseitem=0 AND a.holiday_restriction IS NULL AND a.slot='%s'", client_class, wep_slots[wep_slot]);
            Handle found_weps = TF2IDB_FindItemCustom(search_query);
            if (GetArraySize(found_weps) > 0) {
                int randomized_wep;
                char wep_class_name[128];
                while (!wep_class_name[0] || IsBlacklistedItemClass(wep_class_name)) {
                    randomized_wep = GetArrayCell(found_weps, GetRandomInt(0, GetArraySize(found_weps)-1))
                    TF2IDB_GetItemClass(randomized_wep, wep_class_name, sizeof(wep_class_name));
                }

                CreateWeapon(client, wep_class_name, randomized_wep);
            }
        }
}

void GetClassString(char[] buffer, int length, TFClassType class) {
	char class_name[64];

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

bool CreateWeapon(int client, char[] classname, int itemindex, int level = 0) {
    int weapon = CreateEntityByName(classname);
    
    if (!IsValidEntity(weapon))
    {
        return false;
    }
    
    char entclass[64];
    GetEntityNetClass(weapon, entclass, sizeof(entclass));
    SetEntData(weapon, FindSendPropInfo(entclass, "m_iItemDefinitionIndex"), itemindex);     
    SetEntData(weapon, FindSendPropInfo(entclass, "m_bInitialized"), 1);
    SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 6);

    if (level)
    {
        SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityLevel"), level);
    }
    else
    {
        SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityLevel"), GetRandomUInt(1,99));
    }

    switch (itemindex)
    {
        case 810:
        {
            SetEntData(weapon, FindSendPropInfo(entclass, "m_iObjectType"), 3);
        }
        case 998:
        {
            SetEntData(weapon, FindSendPropInfo(entclass, "m_nChargeResistType"), GetRandomUInt(0,2));
        }
    }
    
    DispatchSpawn(weapon);
    SDKCall(g_hWeaponEquip, client, weapon);
    return true;
}

bool IsBlacklistedItemClass(char[] classname) {
    for (int i = 0; i < sizeof(blacklist_classnames); i++)
        if (StrEqual(blacklist_classnames[i], classname))
            return true;

    return false;
}

int GetRandomUInt(int min, int max) {
    return RoundToFloor(GetURandomFloat() * (max - min + 1)) + min;
}