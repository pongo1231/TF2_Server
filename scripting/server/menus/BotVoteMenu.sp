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

    Format(text, sizeof(text), "All bots do a custom taunt on kill (Currently: %b)", GetConVarBool(FindConVar("sm_bottaunt_enabled")));
    menu.AddItem("bots_taunt", text);

    Format(text, sizeof(text), "All bots do a voice command on damage (Currently: %b)", GetConVarBool(FindConVar("sm_bothurtvoice_enabled")));
    menu.AddItem("bots_hurt", text);

    Format(text, sizeof(text), "All bots are robots (Currently: %b)", GetConVarBool(FindConVar("sm_bothurtvoice_enabled")));
    menu.AddItem("bots_robots", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_BotVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
        	case 0:
                FakeClientCommand(param1, "menu_bots_rcbot");
            case 1:
                Voting_CreateBoolConVarVote("sm_bottaunt_enabled", "Make bots do a custom taunt on killl?");
            case 2:
                Voting_CreateBoolConVarVote("sm_bothurtvoice_enabled", "Make bots do a voice command on damage?");
            case 3:
                Voting_CreateBoolConVarVote("sm_bbr_enabled", "Make all bots robots?");
        }
    else if (action == MenuAction_End)
        delete menu;
}