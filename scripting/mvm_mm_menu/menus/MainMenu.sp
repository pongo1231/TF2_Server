#include <sourcemod>
#include <server/serverchat>

public void OnPluginStart() {
    RegConsoleCmd("menu", MenuOpen);
    AddCommandListener(Listener_JoinTeam, "jointeam");
    AddCommandListener(Listener_JoinTeam, "joinclass");
}

public Action MenuOpen(int client, int args) {
    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    Menu menu = new Menu(Handle_MainMenu);
    menu.SetTitle("Welcome, %s!\nYou can open this menu anytime via /menu.", client_name);
    menu.AddItem("main_player", "Player settings");
    menu.AddItem("main_server", "Server settings");
    menu.AddItem("main_bots", "Bot settings");
    menu.AddItem("main_mvm", "MvM settings");
    menu.AddItem("main_credits", "Credits");
    menu.Display(client, 20);

    return Plugin_Handled;
}

public int Handle_MainMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        switch (param2) {
            case 0:
                FakeClientCommand(param1, "menu_player");
            case 1:
                FakeClientCommand(param1, "menu_server");
            case 2:
                FakeClientCommand(param1, "menu_bots");
            case 3:
                FakeClientCommand(param1, "menu_mvm");
            case 4:
                FakeClientCommand(param1, "menu_credits");
        }
    } else if (action == MenuAction_End)
        delete menu;
}

public Action Listener_JoinTeam(int client, const char[] command, int args) {
    char string_args[16];
    GetCmdArgString(string_args, sizeof(string_args));

    if (!StrEqual(string_args, "spectate"))
        FakeClientCommand(client, "menu");
}