#include <sourcemod>
#include <server/serverchat>

public void OnPluginStart() {
    RegConsoleCmd("menu_ranking", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Stats menu\nNOTE: Currently in beta, includes bots, ranking can be reset anytime until full release.");
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
            FakeClientCommand(client, "rank");
        else {
            char item_text[64];
            menu.GetItem(item, item_text, sizeof(item_text));
            FakeClientCommand(client, "rank %s", item_text);
        }
    } else if (action == MenuAction_End)
        delete menu;
}