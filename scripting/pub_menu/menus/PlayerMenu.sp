#include <sourcemod>
#include <server/serverchat>

public void OnPluginStart() {
    RegConsoleCmd("menu_player", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    if (GetClientTeam(client) == 1) {
        Server_PrintToChat(client, "Menu", "You can't open the player settings as a spectator.");
        return Plugin_Stop;
    }

    Menu menu = new Menu(Handle_PlayerMenu);
    menu.SetTitle("Player settings");

    menu.AddItem("player_taunts", "Taunt menu");
    menu.AddItem("player_fp", "Perspective to first person");
    menu.AddItem("player_tp", "Perspective to third person");
    menu.AddItem("player_kill", "Suicide");
    menu.AddItem("player_robot", "Toggle robot");
    menu.AddItem("player_friendly", "Toggle friendly (Only toggleable in spawn)");
    menu.AddItem("player_radio", "Radio settings");

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_PlayerMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
            case 0:
                FakeClientCommand(param1, "sm_taunt");
            case 1:
                FakeClientCommand(param1, "fp");
            case 2:
                FakeClientCommand(param1, "tp");
            case 3:
                FakeClientCommand(param1, "kill");
            case 4:
                FakeClientCommand(param1, "sm_robot");
            case 5:
                FakeClientCommand(param1, "sm_friendly");
            case 6:
                FakeClientCommand(param1, "sm_radio");
        }
    else if (action == MenuAction_End)
        delete menu;
}