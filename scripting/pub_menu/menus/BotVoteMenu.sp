#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Bot settings");

    char text[128];

    Format(text, sizeof(text), "RCBot settings");
    menu.AddItem("bots_enable", text);

    Format(text, sizeof(text), "All bots do a custom taunt on kill (Currently: %b)", GetConVarBool(FindConVar("sm_bottaunt_enabled")));
    menu.AddItem("bots_taunt", text);

    Format(text, sizeof(text), "All bots do a voice command on damage (Currently: %b)", GetConVarBool(FindConVar("sm_bothurtvoice_enabled")));
    menu.AddItem("bots_hurt", text);

    Format(text, sizeof(text), "All bots are robots (Currently: %b)", GetConVarBool(FindConVar("sm_bbr_enabled")));
    menu.AddItem("bots_robots", text);

    Format(text, sizeof(text), "Bots are panaroid (Currently: %b)", GetConVarBool(FindConVar("sm_spyspyspyspy_enabled")));
    menu.AddItem("silly_spyspyspyspy", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                FakeClientCommand(client, "menu_bots_rcbot");
            case 1:
                Voting_CreateYesNoConVarVote(client, "sm_bottaunt_enabled", "Make bots do a custom taunt on killl?");
            case 2:
                Voting_CreateYesNoConVarVote(client, "sm_bothurtvoice_enabled", "Make bots do a voice command on damage?");
            case 3:
                Voting_CreateYesNoConVarVote(client, "sm_bbr_enabled", "Make all bots robots?");
            case 4:
                Voting_CreateYesNoConVarVote(client, "sm_spyspyspyspy_enabled", "Make bots paranoid? (Silly)");
        }
    else if (action == MenuAction_End)
        delete menu;
}