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
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    char text[128];

    Format(text, sizeof(text), "RCBot settings");
    menu.AddItem("bots_enable", text);

    Format(text, sizeof(text), "All bots do a custom taunt on kill (Currently: %b)", GetConVarBool(FindConVar("sm_bottaunt_enabled")));
    menu.AddItem("bots_taunt", text);

    Format(text, sizeof(text), "All bots do a voice command on damage (Currently: %b)", GetConVarBool(FindConVar("sm_bothurtvoice_enabled")));
    menu.AddItem("bots_hurt", text);

    Format(text, sizeof(text), "All bots are robots (Currently: %b)", GetConVarBool(FindConVar("sm_bbr_enabled")));
    menu.AddItem("bots_robots", text);

    Format(text, sizeof(text), "Bots are panaroid (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_spyspyspyspy_enabled")));
    menu.AddItem("bots_helphelphelphelp", text);

    Format(text, sizeof(text), "Bots stick together (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_helphelphelphelp_enabled")));
    menu.AddItem("bots_spyspyspyspy", text);

    Format(text, sizeof(text), "Bots use RTD (Currently: %b)", GetConVarBool(FindConVar("sm_botrtd_enabled")));
    menu.AddItem("bots_rtd", text);

    menu.Display(client, MENU_TIME_FOREVER);
 
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
            case 5:
                Voting_CreateYesNoConVarVote(client, "sm_helphelphelphelp_enabled", "Make bots stick together? (Silly)");
            case 6:
                Voting_CreateYesNoConVarVote(client, "sm_botrtd_enabled", "Should bots be able to use RTD? (RTD has to be enabled too)");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}