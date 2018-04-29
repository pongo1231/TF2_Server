#include <sourcemod>
#include <server/serverchat>

public void OnPluginStart() {
    RegConsoleCmd("menu", MenuOpen);
    AddCommandListener(Listener_ShowMenu, "jointeam");
    AddCommandListener(Listener_ShowMenu, "joinclass");
}

public Action MenuOpen(int client, int args) {
    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Welcome, %s!\nYou can open this menu anytime via /menu.", client_name);
    menu.AddItem("main_player", "Player settings");
    menu.AddItem("main_redirect", "Other servers");
    menu.AddItem("main_credits", "Credits");
    menu.Display(client, 20);

    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select) {
        switch (item) {
            case 0:
                FakeClientCommand(client, "menu_player");
            case 1:
                FakeClientCommand(client, "menu_redirect");
            case 2:
                FakeClientCommand(client, "menu_credits");
        }
    } else if (action == MenuAction_End)
        delete menu;
}

public Action Listener_ShowMenu(int client, const char[] command, int args) {
    char string_args[16];
    GetCmdArgString(string_args, sizeof(string_args));

    if (!StrEqual(string_args, "spectate"))
        FakeClientCommand(client, "menu");
}