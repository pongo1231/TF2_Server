#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_rcbot", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    if (GameRules_GetProp("m_bPlayingMannVsMachine")) {
        Server_PrintToChat(client, "Menu", "RCBots can't be added to mvm automatically yet.");
        return Plugin_Stop;
    }

    Menu menu = new Menu(Handle_BotVoteMenu);
    menu.SetTitle("RCBot settings");

    char text[128];

    Format(text, sizeof(text), "Enable rcbots");
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

public int Handle_BotVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
        	case 0:
        	    if (GetConVarBool(FindConVar("rcbot_bot_quota_interval")) || GameRules_GetProp("m_bPlayingMannVsMachine"))
        	    	Server_PrintToChat(param1, "Menu", "RCBots Are Already Enabled.");
        	    else
                	Voting_CreateBoolCommandVote("rcbot_bot_quota_interval 1", "rcbot_bot_quota_interval 0; sm_kick @bots", "Enable rcbots?");
        	case 1:
                Voting_CreateConVarVote("rcbot_anglespeed", "Set rcbot skill", "0.01", "0.21", "0.41", "0.61", "0.81", "1.0");
           case 2:
                Voting_CreateBoolConVarVote("sm_gbw_enabled", "Should rcbots use custom weapons?");
           case 3:
                Voting_CreateBoolConVarVote("sm_gbc_enabled", "Should rcbots use custom cosmetics?");
           case 4:
                Voting_CreateBoolConVarVote("rcbot_melee_only", "Should rcbots use melee only?");
        }
    else if (action == MenuAction_End)
        delete menu;
}