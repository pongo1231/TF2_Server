#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_server", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Server settings");

    char text[128];

    menu.AddItem("server_scramble_teams", "Scramble teams");

    Format(text, sizeof(text), "Instant respawn (Currently: %b)", GetConVarBool(FindConVar("mp_disable_respawn_times")));
    menu.AddItem("server_instant_respawn", text);

    Format(text, sizeof(text), "Random crits (Currently: %b)", GetConVarBool(FindConVar("tf_weapon_criticals")));
    menu.AddItem("server_random_crits", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                Voting_CreateYesNoCommandVote(client, "mp_scrambleteams", "Scramble teams?");
            case 1:
                Voting_CreateYesNoConVarVote(client, "mp_disable_respawn_times", "Enable instant respawn?");
            case 2:
                Voting_CreateYesNoConVarVote(client, "tf_weapon_criticals", "Enable random crits?");
        }
    else if (action == MenuAction_End)
        delete menu;
}