#include <sourcemod>
#include <server/serverchat>

public void OnPluginStart() {
    RegConsoleCmd("menu_ranking", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Ranking menu", client_name);
    menu.AddItem("ranking_pstats", "Your stats");
    menu.AddItem("ranking_soon", "More soon!");
    menu.Display(client, 20);

    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select) {
        switch (item) {
            case 0:
                FakeClientCommand(client, "menu_stats");
        }
    } else if (action == MenuAction_End)
        delete menu;
}