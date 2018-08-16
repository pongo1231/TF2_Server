#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_rcbot", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("RCBot settings");

    char text[128];

    Format(text, sizeof(text), "RCBots are robots (Currently: %b)", GetConVarBool(FindConVar("sm_bbr_enabled")));
    menu.AddItem("bots_robots", text);

    Format(text, sizeof(text), "RCBot skill (Currently: %f)", GetConVarFloat(FindConVar("rcbot_anglespeed")));
    menu.AddItem("rcbots_skill", text);

    Format(text, sizeof(text), "RCBots use custom items (Currently: %b)", GetConVarBool(FindConVar("rcbot_customloadouts")));
    menu.AddItem("rcbots_cweps", text);

    Format(text, sizeof(text), "RCBots only use melee (Silly) (Currently: %b)", GetConVarBool(FindConVar("rcbot_melee_only")));
    menu.AddItem("rcbots_melee", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                Voting_CreateYesNoConVarVote(client, "sm_bbr_enabled", "Make RCBots robots?");
            case 1:
                Voting_CreateStringConVarVote(client, "rcbot_anglespeed", "Set rcbot skill (0.4 is default)", "0.01", "0.2", "0.4", "0.6", "0.8", "1.0");
            case 2:
                Voting_CreateYesNoConVarVote(client, "rcbot_customloadouts", "Should rcbots use custom items?");
            case 3:
                Voting_CreateYesNoConVarVote(client, "rcbot_melee_only", "Should rcbots use melee only? (Silly)");
        }
    else if (action == MenuAction_End)
        delete menu;
}