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

    char text[128];

    Format(text, sizeof(text), "Infinite Money (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_mvm_infinitemoney")));
    menu.AddItem("mvm_infinitemoney", text);

    menu.AddItem("mvm_destroytanks", "Destroy all spawned tanks (use if stuck)");

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                Voting_CreateYesNoConVarVote(client, "sm_mvm_infinitemoney", "Enable infinite money? (Silly)");
            case 1:
                Voting_CreateYesNoCommandVote(client, "tf_mvm_tank_kill", "Destroy all spawned tanks? (use if stuck)");
        }
    else if (action == MenuAction_End)
        delete menu;
}