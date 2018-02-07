#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <tf2idb>

public Plugin info = {
	name = "BotRestrictWeps",
	author = "pongo1231",
	description = "Restricts bots to certain weapon slots",
	version = "1.0",
	url = "n/a"
}

/*public void OnPluginStart() {
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    //if (IsFakeClient(client)) {

    	TF2_RemoveWeaponSlot(client, 0);
    	TF2_RemoveWeaponSlot(client, 1);
    	TF2_RemoveWeaponSlot(client, 3);
    	TF2_RemoveWeaponSlot(client, 4);

    	int wep = GetPlayerWeaponSlot(client, 2);
    	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);  
    //}
}*/

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int id, Handle& hItem) {
    int slot = view_as<int>(TF2IDB_GetItemSlot(id));

    if (slot == 0 || slot == 1 || slot == 3 || slot == 4)
        return Plugin_Handled;
    return Plugin_Continue;
}

/**
  * Block build command (no sentries)
  */
public Action OnClientCommand(int client, int args) {
    char arg[8];
    GetCmdArg(1, arg, sizeof(arg));

    if (StrEqual(arg, "build"))
        return Plugin_Handled;

    return Plugin_Continue;
}