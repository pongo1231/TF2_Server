#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_rcbot", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("RCBot settings");

    char text[128];

    Format(text, sizeof(text), "Enable rcbots (WARNING: No disabling until map change)");
    menu.AddItem("rcbots_enable", text);

    Format(text, sizeof(text), "RCBot skill (Currently: %f)", GetConVarFloat(FindConVar("rcbot_anglespeed")));
    menu.AddItem("rcbots_skill", text);

    Format(text, sizeof(text), "RCBots use custom weapons (Currently: %f)", GetConVarFloat(FindConVar("sm_gbw_enabled")));
    menu.AddItem("rcbots_cweps", text);

    Format(text, sizeof(text), "RCBots use custom cosmetics (Currently: %f)", GetConVarFloat(FindConVar("sm_gbc_enabled")));
    menu.AddItem("rcbots_cmiscs", text);

    Format(text, sizeof(text), "RCBots only use melee (Currently: %b)", GetConVarBool(FindConVar("rcbot_melee_only")));
    menu.AddItem("rcbots_melee", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                if (GetConVarBool(FindConVar("rcbot_bot_quota_interval")))
                    Server_PrintToChat(client, "Menu", "RCBots are already enabled and can't be disabled until map change.");
                else
                    Voting_CreateYesNoConVarVote(client, "rcbot_bot_quota_interval", "Enable rcbots?");
            case 1:
                Voting_CreateStringConVarVote(client, "rcbot_anglespeed", "Set rcbot skill", "0.01", "0.21", "0.41", "0.61", "0.81", "1.0");
            case 2:
                Voting_CreateYesNoConVarVote(client, "sm_gbw_enabled", "Should rcbots use custom weapons?");
            case 3:
                Voting_CreateYesNoConVarVote(client, "sm_gbc_enabled", "Should rcbots use custom cosmetics?");
            case 4:
                Voting_CreateYesNoConVarVote(client, "rcbot_melee_only", "Should rcbots use melee only?");
        }
    else if (action == MenuAction_End)
        delete menu;
}