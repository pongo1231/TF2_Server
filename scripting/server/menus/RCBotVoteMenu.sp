#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_rcbot", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_BotVoteMenu);
    menu.SetTitle("RCBot settings");

    char text[128];

    Format(text, sizeof(text), "Enable rcbots (Can't disable)");
    menu.AddItem("rcbots_enable", text);

    float rcbots_skill = GetConVarFloat(FindConVar("rcbot_skill"));
    Format(text, sizeof(text), "RCBot skill (Currently: %f)", rcbots_skill);
    menu.AddItem("rcbots_skill", text);

    bool rcbots_melee_only = GetConVarBool(FindConVar("rcbot_melee_only"));
    Format(text, sizeof(text), "RCBots only use melee (Currently: %b)", rcbots_melee_only);
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
                	Voting_CreateBoolConVarVote("rcbot_bot_quota_interval", "Enable rcbots?");
        	case 1:
                Voting_CreateConVarVote("rcbot_skill", "Set rcbot skill", "0.0", "0.25", "0.5", "0.75", "1.0");
            case 2:
                Voting_CreateBoolConVarVote("rcbot_melee_only", "Should rcbots use melee only?");
        }
    else if (action == MenuAction_End)
        delete menu;
}