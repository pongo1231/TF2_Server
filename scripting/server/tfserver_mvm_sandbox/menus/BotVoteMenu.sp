#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_VoteMenu);
    menu.SetTitle("Bot settings");

    char text[128];

    Format(text, sizeof(text), "RCBot settings");
    menu.AddItem("bots_rcbots", text);

    Format(text, sizeof(text), "Robot settings");
    menu.AddItem("bots_robots", text);

    Format(text, sizeof(text), "All bots do a voice command on damage (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_bothurtvoice_enabled")));
    menu.AddItem("bots_hurt", text);

    Format(text, sizeof(text), "Bots are aggressive (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_chargebots_enabled")));
    menu.AddItem("bots_charge", text);

    Format(text, sizeof(text), "Bots use bumper cars (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_kartbots_enabled")));
    menu.AddItem("bots_bumpercart", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                FakeClientCommand(client, "menu_bots_rcbot");
            case 1:
                FakeClientCommand(client, "menu_bots_robots");
            case 2:
                Voting_CreateYesNoConVarVote(client, "sm_bothurtvoice_enabled", "Make bots do a voice command on damage? (Silly)");
            case 3:
                Voting_CreateYesNoConVarVote(client, "sm_chargebots_enabled", "Make all bots aggressive? (Silly)");
            case 4:
                Voting_CreateYesNoConVarVote(client, "sm_kartbots_enabled", "Should all newly spawned bots use bumper cars? (Silly)");
        }
    else if (action == MenuAction_End)
        delete menu;
}