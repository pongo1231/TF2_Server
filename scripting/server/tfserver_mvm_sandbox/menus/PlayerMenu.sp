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

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Player settings");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    menu.AddItem("player_taunts", "Taunt menu");
    menu.AddItem("player_pitch", "Pitch menu");
    menu.AddItem("player_fp", "Perspective to first person");
    menu.AddItem("player_tp", "Perspective to third person");
    menu.AddItem("player_kill", "Suicide");
    menu.AddItem("player_robot", "Toggle robot");

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                FakeClientCommand(client, "sm_taunt");
            case 1:
                FakeClientCommand(client, "menu_player_pitch");
            case 2:
                FakeClientCommand(client, "fp");
            case 3:
                FakeClientCommand(client, "tp");
            case 4:
                FakeClientCommand(client, "kill");
            case 5:
                FakeClientCommand(client, "sm_robot");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
        delete menu;
    }
}