#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_rcbot", MenuOpen);
    RegAdminCmd("sm_kickbots", Command_KickBots, ADMFLAG_KICK);
}

public void OnClientDisconnect_Post(int client)
{
    for (int client = 1; client < MaxClients + 1; client++)
        if (IsClientInGame(client) && !IsFakeClient(client))
            return;

    SetConVarInt(FindConVar("rcbot_bot_quota_interval"), 1);
    SetConVarInt(FindConVar("rcbot_force_class"), 0);
}

public Action Command_KickBots(int client, int args)
{
    for (int client = 1; client <= MaxClients; client++)
        if (IsClientInGame(client) && IsFakeClient(client) && !IsClientSourceTV(client))
            KickClientEx(client, "Bot kicked");
    
    return Plugin_Handled;
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

    Format(text, sizeof(text), "Enable rcbots");
    menu.AddItem("rcbots_enable", text);

    Format(text, sizeof(text), "RCBot skill (Currently: %f)", GetConVarFloat(FindConVar("rcbot_anglespeed")));
    menu.AddItem("rcbots_skill", text);

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
                Voting_CreateYesNoCommandVote(client, "rcbot_bot_quota_interval 1", "Enable rcbots?", "rcbot_bot_quota_interval 0; sm_kickbots");
            case 1:
                Voting_CreateStringConVarVote(client, "rcbot_anglespeed", "Set rcbot skill", "0.01", "0.2", "0.4", "0.6", "0.8", "1.0");
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
