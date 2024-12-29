#include <sourcemod>
#include <server/serverchat>

public void OnPluginStart() {
    RegConsoleCmd("menu_ranking", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Stats menu");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);
    menu.AddItem("ranking_rank_top7", "Top 7 players");
    menu.AddItem("ranking_rank_self", "Your ranking");
    
    for (int client = 1; client < MaxClients + 1; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            char player_name[64];
            GetClientName(client, player_name, sizeof(player_name));

            if (!StrEqual(player_name, client_name)) {
                menu.AddItem(player_name, player_name);
            }
        }
    }

    menu.Display(client, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select) {
        if (item == 0)
            FakeClientCommand(client, "top7");
        else if (item == 1)
            FakeClientCommand(client, "rank");
        else {
            char player_name[64];
            GetMenuItem(menu, item, player_name, sizeof(player_name));
            FakeClientCommand(client, "rank %s", player_name);
        }
    } else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}
