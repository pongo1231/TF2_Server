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
    menu.AddItem("ranking_rank_top7", "Top 7 players");
    menu.AddItem("ranking_rank_self", "Your ranking");
    
    for (int i = 1; i < GetMaxClients(); i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            char player_name[64];
            GetClientName(i, player_name, sizeof(player_name));

            if (!StrEqual(player_name, client_name)) {
                menu.AddItem(player_name, player_name);
            }
        }
    }

    menu.Display(client, 20);

    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select) {
        if (item == 0)
            FakeClientCommand(client, "top7");
        else if (item == 1)
            FakeClientCommand(client, "rank");
    } else if (action == MenuAction_End)
        delete menu;
}