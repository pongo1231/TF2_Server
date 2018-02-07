#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_BotVoteMenu);
    menu.SetTitle("Bot Settings");

    char text[128];

    Format(text, sizeof(text), "Bot settings");
    menu.AddItem("bots_enable", text);

    bool bots_taunt_on_kill = GetConVarBool(FindConVar("sm_bottaunt_enabled"));
    Format(text, sizeof(text), "Bots taunt on kill (Currently: %b)", bots_taunt_on_kill);
    menu.AddItem("bots_taunt", text);

    bool bots_hurt_voice = GetConVarBool(FindConVar("sm_bothurtvoice_enabled"));
    Format(text, sizeof(text), "Bots do a voice command on damage (Currently: %b)", bots_hurt_voice);
    menu.AddItem("bots_hurt", text);

    bool bots_melee_only = GetConVarBool(FindConVar("tf_bot_melee_only"));
    Format(text, sizeof(text), "(Normal) Bots only use melee (Currently: %b)", bots_melee_only);
    menu.AddItem("bots_melee", text);

    bool bots_are_robots = GetConVarBool(FindConVar("sm_bbr_enabled"));
    Format(text, sizeof(text), "Bots are robots (Currently: %b)", bots_are_robots);
    menu.AddItem("bots_robots", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_BotVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
        	case 0:
        		if (GameRules_GetProp("m_bPlayingMannVsMachine"))
                    Server_PrintToChat(param1, "Menu", "RCBots can't be added to mvm automatically yet.");
        		else
                	FakeClientCommand(param1, "menu_bots_rcbot");
            case 1:
                Voting_CreateBoolConVarVote("sm_bottaunt_enabled", "Make bots taunt on kill?");
            case 2:
                Voting_CreateBoolConVarVote("sm_bothurtvoice_enabled", "Make bots do a voice command on damage?");
            case 3:
                Voting_CreateBoolConVarVote("tf_bot_melee_only", "Make (normal) bots only use melee?");
            case 4:
                Voting_CreateBoolConVarVote("sm_bbr_enabled", "Make bots robots?");
        }
    else if (action == MenuAction_End)
        delete menu;
}