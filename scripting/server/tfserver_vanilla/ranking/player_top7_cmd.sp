#include <sourcemod>
#include <server/serverchat>

Database db;
char top_seven_steam_ids[7][64];
char top_seven_names[7][64];

public void OnPluginStart() {
    Database.Connect(T_DataBaseConnect, "players-local");
}

public void T_DataBaseConnect(Database m_db, const char[] error, any data) {
    if (m_db == null)
        LogError("PLAYERDB FATAL ERROR: %s", error);
    else {
        db = m_db;

        CreateTimer(60.0, Timer_UpdateTopSevenCache, _, TIMER_REPEAT);
        Timer_UpdateTopSevenCache(INVALID_HANDLE);

        RegConsoleCmd("top7", Command_TopSeven);
    }
}

public Action Timer_UpdateTopSevenCache(Handle timer) {
	char query[256];
	Format(query, sizeof(query), "SELECT steam_id FROM stats_scores ORDER BY rank ASC LIMIT 7");
	db.Query(T_UpdateSteamIDCache, query);
}

public void T_UpdateSteamIDCache(Database m_db, DBResultSet results, const char[] error, any nodata) {
	if (error[0]) {
        LogError("PLAYERDB ERROR: %s", error);
        return;
    }

	if (SQL_GetRowCount(results) > 0) {
		int i = 0;
		char steam_id[64];
		while (SQL_FetchRow(results)) {
			SQL_FetchString(results, 0, steam_id, sizeof(steam_id));
			top_seven_steam_ids[i] = steam_id;

			char query[256];
			Format(query, sizeof(query), "SELECT player_name FROM stats_names WHERE steam_id='%s'", steam_id);
			db.Query(T_UpdateNameCache, query, i);

			i++;
		}
    }

	delete results;
}

public void T_UpdateNameCache(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
        LogError("PLAYERDB ERROR: %s", error);
        return;
    }
	
	if (SQL_GetRowCount(results) == 0)
		top_seven_names[data] = top_seven_steam_ids[data];
	else {
		SQL_FetchRow(results);

		char player_name[64];
		SQL_FetchString(results, 0, player_name, sizeof(player_name));

		top_seven_names[data] = player_name;
    }

	delete results;
}

public Action Command_TopSeven(int client, int args) {
	ShowTopSevenMenu(client);
	return Plugin_Handled;
}

void ShowTopSevenMenu(int client) {
	Menu menu = new Menu(Handle_Menu);
	menu.SetTitle("Top 7\n(Sorted by score)");
	
	for (int i = 0; i < sizeof(top_seven_steam_ids); i++) {
		if (StrEqual(top_seven_steam_ids[i], ""))
			menu.AddItem("nothing", "");
		else
			menu.AddItem(top_seven_names[i], top_seven_names[i]);
	}

	menu.Display(client, 20);
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char item_id[64];
		GetMenuItem(menu, item, item_id, sizeof(item_id));

		if (!StrEqual(item_id, "nothing"))
			FakeClientCommand(client, "rank %s", item_id);
	} else if (action == MenuAction_End)
        delete menu;
}