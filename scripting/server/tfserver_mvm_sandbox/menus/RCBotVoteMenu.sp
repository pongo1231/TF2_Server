#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

ConVar g_kickBots;
ConVar g_rcbotQuota;

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_rcbot", MenuOpen);
    g_kickBots = CreateConVar("menu_bots_rcbot_enablebots", "1", _, _, true, 0.0, true, 1.0);
    g_rcbotQuota = FindConVar("rcbot_bot_quota_interval");
    CreateTimer(1.0, Timer_KickBots, _, TIMER_REPEAT);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("RCBot settings");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    char text[128];

    Format(text, sizeof(text), "Enable RCBots (Currently: %b)", GetConVarBool(FindConVar("menu_bots_rcbot_enablebots")));
    menu.AddItem("bots_robots", text);

    Format(text, sizeof(text), "RCBots are robots (Currently: %b)", GetConVarBool(FindConVar("sm_bbr_enabled")));
    menu.AddItem("bots_robots", text);

    Format(text, sizeof(text), "RCBot skill (Currently: %f)", GetConVarFloat(FindConVar("rcbot_anglespeed")));
    menu.AddItem("rcbots_skill", text);

    Format(text, sizeof(text), "RCBots use custom items (Currently: %b)", GetConVarBool(FindConVar("sm_gbw_enabled")));
    menu.AddItem("rcbots_cweps", text);

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
                Voting_CreateYesNoConVarVote(client, "sm_bbr_enabled", "Make RCBots robots?");
            case 2:
                Voting_CreateStringConVarVote(client, "rcbot_anglespeed", "Set rcbot skill (0.4 is default)", "0.01", "0.2", "0.4", "0.6", "0.8", "1.0");
            case 3:
                Voting_CreateYesNoCommandVote(client, "sm_gbw_enabled 1; sm_gbc_enabled 1", "Should rcbots use custom items?", "sm_gbw_enabled 0; sm_gbc_enabled 0");
            case 4:
                Voting_CreateYesNoConVarVote(client, "rcbot_melee_only", "Should rcbots use melee only? (Silly)");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu_bots");
    } else if (action == MenuAction_End)
        delete menu;
}


public Action Timer_KickBots(Handle timer) {
    if (GetConVarInt(g_kickBots) < 1) {
        SetConVarInt(g_rcbotQuota, 0);
        for (int i = 1; i < GetMaxClients(); i++)
            if (IsClientInGame(i) && IsFakeClient(i) && TF2_GetClientTeam(i) == TFTeam_Red)
                KickClient(i);
    }
    else
        SetConVarInt(g_rcbotQuota, 1);
}
