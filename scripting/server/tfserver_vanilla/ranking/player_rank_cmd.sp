#include <sourcemod>
#include <server/serverchat>

Database db;

public void OnPluginStart() {
    Database.Connect(T_DataBaseConnect, "players-local");
}

public void T_DataBaseConnect(Database m_db, const char[] error, any data) {
    if (m_db == null)
        LogError("PLAYERDB FATAL ERROR: %s", error);
    else {
        db = m_db;
        RegConsoleCmd("rank", Command_Rank);
    }
}

public Action Command_Rank(int client, int args) {
    //int args_size = GetCmdArgs();

	char player_name[64];
	if (args == 0)
    	GetClientName(client, player_name, sizeof(player_name));
	else
    	GetCmdArgString(player_name, sizeof(player_name));

	char player_name_safe[64];
	SQL_EscapeString(db, player_name, player_name_safe, sizeof(player_name_safe));
	ShowRankMenu(client, player_name_safe);

	return Plugin_Handled;
}

void ShowRankMenu(int client, const char[] target_player) {
	char query[256];
	Format(query, sizeof(query), "SELECT * FROM stats_names WHERE player_name='%s'", target_player);
	ArrayList data = CreateArray(8); // Don't truncate the player's name
	PushArrayCell(data, client);
	PushArrayString(data, target_player);
	db.Query(T_GetData, query, data);
}

public void T_GetData(Database m_db, DBResultSet results, const char[] error, any data) {
	int client = GetArrayCell(data, 0);

	if (error[0]) {
        LogError("PLAYERDB ERROR: %s", error);
        Server_PrintToChat(client, "Ranking", "Error while fatching player.");
        return;
    }
	
	if (SQL_GetRowCount(results) == 0)
        Server_PrintToChat(client, "Ranking", "Player is not in the database yet!");
	else {
		SQL_FetchRow(results);

		char query[256];
		Format(query, sizeof(query), "SELECT * FROM stats_killing WHERE steam_id='%i'", SQL_FetchInt(results, 0));
		db.Query(T_ShowData, query, data);
    }
}

public void T_ShowData(Database m_db, DBResultSet results, const char[] error, any data) {
	int client = GetArrayCell(data, 0);
	
	if (error[0]) {
        LogError("PLAYERDB ERROR: %s", error);
        Server_PrintToChat(client, "Ranking", "Error while fetching player.");
        return;
    }

	if (SQL_GetRowCount(results) == 0)
        Server_PrintToChat(client, "Ranking", "Player has no stats yet!");
	else {
		Menu menu = new Menu(Handle_Menu);
		char target_player[64];
		GetArrayString(data, 1, target_player, sizeof(target_player));
		char title[64];
		Format(title, sizeof(title), "%s's stats", target_player);
		menu.SetTitle(title);

		SQL_FetchRow(results);

		int kills = SQL_FetchInt(results, 2);
		char kills_text[32];
		Format(kills_text, sizeof(kills_text), "Kills: %i", kills);
		menu.AddItem("stats_kills", kills_text);

		int deaths = SQL_FetchInt(results, 1);
		char deaths_text[32];
		Format(deaths_text, sizeof(deaths_text), "Deaths: %i", deaths);
		menu.AddItem("stats_deaths", deaths_text);

		int assists = SQL_FetchInt(results, 3);
		char assists_text[32];
		Format(assists_text, sizeof(assists_text), "Assists: %i", assists);
		menu.AddItem("stats_assists", assists_text);

		menu.AddItem("nothing", "");

		float kd_ratio = float(kills) / float(deaths);
		char kd_ratio_text[32];
		Format(kd_ratio_text, sizeof(kd_ratio_text), "K/D ratio: %f", kd_ratio);
		menu.AddItem("stats_kd_ratio", kd_ratio_text);

		menu.Display(client, 20);
    }
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_End)
        delete menu;
}