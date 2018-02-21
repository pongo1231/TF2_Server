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

    Format(text, sizeof(text), "Enable x10 (Currently: %b)", GetConVarBool(FindConVar("tf2x10_enabled")));
    menu.AddItem("silly_x10", text);

    Format(text, sizeof(text), "Always crits (Currently: %b)", GetConVarBool(FindConVar("sm_alwayscrits_enabled")));
    menu.AddItem("silly_always_crits", text);

    Format(text, sizeof(text), "Friendly fire (Currently: %b)", GetConVarBool(FindConVar("mp_friendlyfire")));
    menu.AddItem("silly_friendly_fire", text);

    Format(text, sizeof(text), "Deadly water (Currently: %b)", GetConVarBool(FindConVar("sm_deadlywater_enabled")));
    menu.AddItem("silly_deadly_water", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_ServerVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
            case 0:
                Voting_CreateBoolConVarVote("tf2x10_enabled", "Enable x10? (Silly)");
            case 1:
                Voting_CreateBoolConVarVote("sm_alwayscrits_enabled", "Enable always crits? (Silly)");
            case 2:
                if (GameRules_GetProp("m_bPlayingMannVsMachine"))
                    Server_PrintToChat(param1, "Menu", "Can't set friendly fire in MvM.");
                else
                    Voting_CreateBoolConVarVote("mp_friendlyfire", "Enable friendly fire? (Silly)");
            case 3:
                Voting_CreateBoolConVarVote("sm_deadlywater_enabled", "Enable deadly water? (Silly)");
        }
    else if (action == MenuAction_End)
        delete menu;
}