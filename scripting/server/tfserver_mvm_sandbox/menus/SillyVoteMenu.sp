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

    Format(text, sizeof(text), "Goomba Stomping (Currently: %b)", GetConVarBool(FindConVar("goomba_enabled")));
    menu.AddItem("silly_goomba_enabled", text);

    Format(text, sizeof(text), "Enable RTD (Currently: %b)", GetConVarBool(FindConVar("sm_rtd2_enabled")));
    menu.AddItem("silly_rtd_enabled", text);

    Format(text, sizeof(text), "Enable Grappling Hook (Currently: %b)", GetConVarBool(FindConVar("tf_grapplinghook_enable")));
    menu.AddItem("silly_grappling_hook_enabled", text);

    Format(text, sizeof(text), "Enable Spells (Currently: %b)", GetConVarBool(FindConVar("sm_spells_enabled")));
    menu.AddItem("silly_spells_enabled", text);

    Format(text, sizeof(text), "Unlimited Ammo (Currently: %b)", GetConVarBool(FindConVar("sm_fia_all")));
    menu.AddItem("silly_unlimitedammo", text);

    Format(text, sizeof(text), "Huge Explosion Effects (Currently: %b)", GetConVarBool(FindConVar("sm_hugeexplosions_enabled")));
    menu.AddItem("silly_hugeexplosions", text);

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
            	Voting_CreateYesNoConVarVote(client, "goomba_enabled", "Enable goomba stomping? (Silly)");
            case 4:
                Voting_CreateYesNoConVarVote(client, "sm_rtd2_enabled", "Enable RTD? (Silly)");
            case 5:
                Voting_CreateYesNoConVarVote(client, "tf_grapplinghook_enable", "Enable Grappling Hook? (Silly)");
            case 6:
                Voting_CreateYesNoCommandVote(client, "tf_spells_enabled 1;sm_spells_enabled 1", "Enable spells? (Silly)", "tf_spells_enabled 0;sm_spells_enabled 0");
            case 7:
                Voting_CreateYesNoConVarVote(client, "sm_fia_all", "Enable unlimited ammo? (Silly)");
            case 8:
                Voting_CreateYesNoConVarVote(client, "sm_hugeexplosions_enabled", "Enable huge explosion effects? (Silly)");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu_server");
    } else if (action == MenuAction_End)
        delete menu;
}