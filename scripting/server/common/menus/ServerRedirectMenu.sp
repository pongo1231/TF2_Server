#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_redirect", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_VoteMenu);
    menu.SetTitle("Other servers");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    menu.AddItem("ducky.rivinshosting.com:27016", "MvM Sandbox");
    menu.AddItem("ducky.rivinshosting.com:27018", "MvM Vanilla");
    menu.AddItem("ducky.rivinshosting.com:27017", "Sandbox");
    menu.AddItem("ducky.rivinshosting.com:27015", "Vanilla");
    menu.AddItem("ducky.rivinshosting.com:27019", "MGE [all class]");
    menu.AddItem("ducky.rivinshosting.com:27020", "Freak Fortress 2");

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select) {
        char item_info[32];
        if (GetMenuItem(menu, item, item_info, sizeof(item_info)))
            DisplayAskConnectBox(client, 10.0, item_info);
    }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
        delete menu;
    }
}