#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

ConVar enable_bots;
ConVar rcbot_quota;
ConVar force_class;
ConVar rcbot_force_class;

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_rcbot", MenuOpen);

    enable_bots = CreateConVar("menu_bots_rcbot_enablebots", "1", _, _, true, 0.0, true, 1.0);
    rcbot_quota = FindConVar("rcbot_bot_quota_interval");
    CreateTimer(1.0, Timer_KickBots, _, TIMER_REPEAT);

    force_class = CreateConVar("menu_bots_rcbot_force_class", "None");
    rcbot_force_class = FindConVar("rcbot_force_class");
    HookConVarChange(force_class, force_class_changed);
}

public void OnClientDisconnect_Post(int client)
{
    for (int client = 1; client < MaxClients + 1; client++)
        if (IsClientInGame(client) && !IsFakeClient(client))
            return;

    SetConVarInt(enable_bots, 1);
}

void KickBots() {
    for (int client = 1; client < MaxClients + 1; client++)
        if (IsClientInGame(client) && IsFakeClient(client) && !IsClientSourceTV(client))
            KickClient(client);
}

public Action Timer_KickBots(Handle timer) {
    if (GetConVarInt(enable_bots) < 1) {
        SetConVarInt(rcbot_quota, 0);
        KickBots();
    }
    else
        SetConVarInt(rcbot_quota, 1);
}

public void force_class_changed(ConVar convar, const char[] oldValue, const char[] newValue) {
    if (StrEqual(oldValue, newValue))
        return;

    int cvar_value = 0;
    if (StrEqual(newValue, "Scout")) cvar_value = 1;
    else if (StrEqual(newValue, "Soldier")) cvar_value = 2;
    else if (StrEqual(newValue, "Pyro")) cvar_value = 3;
    else if (StrEqual(newValue, "Demoman")) cvar_value = 4;
    else if (StrEqual(newValue, "Heavy")) cvar_value = 5;
    else if (StrEqual(newValue, "Engineer")) cvar_value = 6;
    else if (StrEqual(newValue, "Medic")) cvar_value = 7;
    else if (StrEqual(newValue, "Sniper")) cvar_value = 8;
    else if (StrEqual(newValue, "Spy")) cvar_value = 9;

    SetConVarInt(rcbot_force_class, cvar_value);
    KickBots();
}

public Action MenuOpen(int client, int args) {
    if (GameRules_GetProp("m_bPlayingMannVsMachine")) {
        Server_PrintToChat(client, "Menu", "RCBots can't be added to mvm automatically yet.");
        return Plugin_Stop;
    }

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("RCBot settings");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    char text[128];

    Format(text, sizeof(text), "Enable RCBots (Currently: %b)", GetConVarBool(enable_bots));
    menu.AddItem("rcbots_enable", text);

    char force_class_value[16];
    GetConVarString(force_class, force_class_value, sizeof(force_class_value));
    Format(text, sizeof(text), "Force RCBots to specific class (Currently: %s)", force_class_value);
    menu.AddItem("rcbots_force_class", text);

    Format(text, sizeof(text), "RCBots use custom items (Currently: %b)", GetConVarBool(FindConVar("sm_gbmw_enabled")));
    menu.AddItem("rcbot_customloadouts", text);

    Format(text, sizeof(text), "RCBots only use melee (Silly) (Currently: %b)", GetConVarBool(FindConVar("rcbot_melee_only")));
    menu.AddItem("rcbots_melee", text);

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                Voting_CreateYesNoConVarVote(client, "menu_bots_rcbot_enablebots", "Enable RCBots?");
            case 1:
                Voting_CreateStringConVarVote(client, "menu_bots_rcbot_force_class", "Force RCBots to specific class?", "None", "Scout", "Soldier", "Pyro", "Demoman", "Heavy", "Engineer", "Medic", "Sniper", "Spy");
            case 2:
                Voting_CreateYesNoCommandVote(client, "sm_gbmw_enabled 1; sm_gbmc_enabled 1", "Should rcbots use custom items?", "sm_gbmw_enabled 0; sm_gbmc_enabled 0");
            case 3:
                Voting_CreateYesNoConVarVote(client, "rcbot_melee_only", "Should rcbots use melee only? (Silly)");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu_bots");
    } else if (action == MenuAction_End)
        delete menu;
}
