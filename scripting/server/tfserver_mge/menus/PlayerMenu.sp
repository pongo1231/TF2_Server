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

    menu.AddItem("player_pitch", "Pitch menu");
    menu.AddItem("player_kill", "Suicide");
    menu.AddItem("player_dmgvoice", "Toggle damage voice");

    menu.Display(client, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                FakeClientCommand(client, "menu_player_pitch");
            case 1:
                FakeClientCommand(client, "kill");
            case 2:
                FakeClientCommand(client, "menu_player_dmgvoice");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}