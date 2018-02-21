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
    menu.SetTitle("Bot settings");

    char text[128];

    Format(text, sizeof(text), "RCBot settings");
    menu.AddItem("bots_enable", text);

    Format(text, sizeof(text), "All bots do a voice command on damage (Currently: %b)", GetConVarBool(FindConVar("sm_bothurtvoice_enabled")));
    menu.AddItem("bots_hurt", text);

    Format(text, sizeof(text), "All bots are robots (Currently: %b)", GetConVarBool(FindConVar("sm_bbr_enabled")));
    menu.AddItem("bots_robots", text);

    Format(text, sizeof(text), "Robots do a custom taunt on kill (Currently: %b)", GetConVarBool(FindConVar("sm_bottaunt_enabled")));
    menu.AddItem("bots_taunt", text);

    Format(text, sizeof(text), "Robots only use melee (Currently: %b)", GetConVarBool(FindConVar("tf_bot_melee_only")));
    menu.AddItem("mvm_bots_melee", text);

    Format(text, sizeof(text), "Robots are blind (WARNING: Resets mission on change) (Currently: %b)", GetConVarBool(FindConVar("nb_blind")));
    menu.AddItem("mvm_bots_can_attack", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_BotVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
        	case 0:
                FakeClientCommand(param1, "menu_bots_rcbot");
            case 1:
                Voting_CreateBoolConVarVote("sm_bothurtvoice_enabled", "Make bots do a voice command on damage?");
            case 2:
                Voting_CreateBoolConVarVote("sm_bbr_enabled", "Make all bots robots?");
            case 3:
                Voting_CreateBoolConVarVote("sm_bottaunt_enabled", "Make robots do a custom taunt on kill?");
            case 4:
                Voting_CreateBoolConVarVote("tf_bot_melee_only", "Make robots use melee only?");
            case 5:
                Voting_CreateBoolConVarVote("sm_mvm_blindrobots", "Make robots blind? (WARNING: Resets mission on change)");
        }
    else if (action == MenuAction_End)
        delete menu;
}