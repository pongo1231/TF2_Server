#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_mvm", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    if (!GameRules_GetProp("m_bPlayingMannVsMachine")) {
        Server_PrintToChat(client, "Menu", "Can't open mvm menu when not playing mvm.");
        return Plugin_Stop;
    }

    Menu menu = new Menu(Handle_BotVoteMenu);
    menu.SetTitle("MvM settings");

    char text[128];

    Format(text, sizeof(text), "Robots only use melee (Currently: %b)", GetConVarBool(FindConVar("tf_bot_melee_only")));
    menu.AddItem("mvm_bots_melee", text);

    Format(text, sizeof(text), "Bomb carrier robot can attack (Currently: %b)", GetConVarBool(FindConVar("tf_mvm_bot_allow_flag_carrier_to_fight")));
    menu.AddItem("mvm_bomb_bot_attack", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_BotVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
        	case 0:
                Voting_CreateBoolConVarVote("tf_bot_melee_only", "Make robots use melee only?");
            case 1:
                Voting_CreateBoolConVarVote("tf_mvm_bot_allow_flag_carrier_to_fight", "Should bomb carrier robot be able to attack?");
        }
    else if (action == MenuAction_End)
        delete menu;
}