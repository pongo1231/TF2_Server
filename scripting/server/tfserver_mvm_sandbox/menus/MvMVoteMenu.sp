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

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("MvM settings");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    char text[128];

    Format(text, sizeof(text), "Endless Force Mode (Currently: %b)", GetConVarBool(FindConVar("tf_mvm_endless_force_on")));
    menu.AddItem("mvm_endlessforcemode", text);

    Format(text, sizeof(text), "Infinite Money (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_mvm_infinitemoney")));
    menu.AddItem("mvm_infinitemoney", text);

    menu.AddItem("mvm_killrobots", "Kill all spawned robots (use if stuck)");

    menu.AddItem("mvm_killtanks", "Kill all spawned tanks");

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                Voting_CreateYesNoConVarVote(client, "tf_mvm_endless_force_on", "Enable MvM Endless Force Mode?");
            case 1:
                Voting_CreateYesNoConVarVote(client, "sm_mvm_infinitemoney", "Enable infinite money? (Silly)");
            case 2:
                Voting_CreateYesNoCommandVote(client, "sm_slay @blue", "Kill all spawned robots? (use if stuck)");
            case 3:
                Voting_CreateYesNoCommandVote(client, "sv_cheats 1; sm_fakecmd 0 tf_mvm_tank_kill", "Kill all spawned tanks?");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}
