#include <sourcemod>

public void OnPluginStart() {
    RegConsoleCmd("menu_credits", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Credits");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);
    menu.AddItem("1", "Credits:");
    menu.AddItem("2", "Server by pongo1231 / Ducky");
    menu.AddItem("3", "");
    menu.AddItem("4", "");
    menu.AddItem("5", "");
    menu.AddItem("6", "");
    menu.AddItem("7", "");
    menu.AddItem("7", "Contact:");
    menu.AddItem("8", "Our steam group: steamcommunity.com/groups/duckyservers");
    menu.AddItem("9", "Or personal:");
    menu.AddItem("11", "E-Mail: pongo12310@gmail.com");
    menu.AddItem("12", "Steam: steamcommunity.com/id/pongo1231");
    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Cancel)
        FakeClientCommand(client, "menu");
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}
