#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_server_silly", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Silly settings");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    char text[128];

    Format(text, sizeof(text), "Gravity (Currently: %i)", GetConVarInt(FindConVar("sv_gravity")));
    menu.AddItem("silly_gravity", text);

    Format(text, sizeof(text), "Enable x10 (Respawn to apply) (Currently: %b)", GetConVarBool(FindConVar("tf2x10_enabled")));
    menu.AddItem("silly_x10", text);

    Format(text, sizeof(text), "Always crits (Currently: %b)", GetConVarBool(FindConVar("sm_alwayscrits_enabled")));
    menu.AddItem("silly_always_crits", text);

    Format(text, sizeof(text), "Friendly fire (Currently: %b)", GetConVarBool(FindConVar("mp_friendlyfire")));
    menu.AddItem("silly_friendly_fire", text);

    Format(text, sizeof(text), "Deadly water (Currently: %b)", GetConVarBool(FindConVar("sm_deadlywater_enabled")));
    menu.AddItem("silly_deadly_water", text);

    Format(text, sizeof(text), "Goomba Stomping (Currently: %b)", GetConVarBool(FindConVar("goomba_enabled")));
    menu.AddItem("silly_goomba_enabled", text);

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
        	  case 0:
                Voting_CreateStringConVarVote(client, "sv_gravity", "Set Gravity (800 is default) (Silly)", "10", "400", "800", "1600");
            case 1:
                Voting_CreateYesNoConVarVote(client, "tf2x10_enabled", "Enable x10? (Silly) (Respawn to apply)");
            case 2:
                Voting_CreateYesNoConVarVote(client, "sm_alwayscrits_enabled", "Enable always crits? (Silly)");
            case 3:
                Voting_CreateYesNoConVarVote(client, "mp_friendlyfire", "Enable friendly fire? (Silly)");
            case 4:
                Voting_CreateYesNoConVarVote(client, "sm_deadlywater_enabled", "Enable deadly water? (Silly)");
            case 5:
                Voting_CreateYesNoConVarVote(client, "goomba_enabled", "Enable goomba stomping? (Silly)");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu_server");
    } else if (action == MenuAction_End)
        delete menu;
}