#include <sourcemod>

public void OnPluginStart() {
    RegConsoleCmd("menu_credits", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Credits);
    menu.SetTitle("Credits");
    menu.AddItem("1", "Credits to:");
    menu.AddItem("2", "Server and some of the plugins by pongo1231");
    menu.AddItem("3", "RCBots by Cheeseh");
    menu.AddItem("4", "Radio by Fragradio");
    menu.AddItem("5", "x10 by Wllu");
    menu.AddItem("6", "");
    menu.AddItem("7", "");
    menu.AddItem("7", "Contact:");
    menu.AddItem("8", "Our steam group: steamcommunity.com/groups/scammersservers");
    menu.AddItem("9", "Or personal:");
    menu.AddItem("11", "E-Mail: pongo1999712@gmail.com");
    menu.AddItem("12", "Steam: steamcommunity.com/id/pongo1231");
    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_Credits(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_End)
        delete menu;
}