#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_server_silly", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_ServerVoteMenu);
    menu.SetTitle("Silly settings");

    char text[128];

    bool always_crits = GetConVarBool(FindConVar("sm_alwayscrits_enabled"));
    Format(text, sizeof(text), "Always crits (Currently: %b)", always_crits);
    menu.AddItem("silly_always_crits", text);

    bool friendly_fire = GetConVarBool(FindConVar("mp_friendlyfire"));
    Format(text, sizeof(text), "Friendly fire (Currently: %b)", friendly_fire);
    menu.AddItem("silly_friendly_fire", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_ServerVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
            case 0:
                Voting_CreateBoolConVarVote("sm_alwayscrits_enabled", "Enable always crits? (Silly)");
            case 1:
                if (GameRules_GetProp("m_bPlayingMannVsMachine"))
                    Server_PrintToChat(param1, "Menu", "Can't set friendly fire in MvM.");
                else
                    Voting_CreateBoolConVarVote("mp_friendlyfire", "Enable friendly fire? (Silly)");
        }
    else if (action == MenuAction_End)
        delete menu;
}