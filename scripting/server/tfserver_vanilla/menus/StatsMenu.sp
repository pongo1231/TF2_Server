#include <sourcemod>
#include <server/serverchat>

Database db;

public void OnPluginStart() {
    Database.Connect(T_DataBaseConnect, "players-local");
    RegConsoleCmd("menu_stats", MenuOpen);
}

public void T_DataBaseConnect(Database m_db, const char[] error, any data) {
    if (m_db == null)
        LogError("PLAYERDB FATAL ERROR: %s", error);
    else
        db = m_db;
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);

    char query[256];
    Format(query, sizeof(query), "SELECT * FROM stats_killing WHERE steam_id='%i';", GetSteamAccountID(client));
    ArrayList data = CreateArray();
    PushArrayCell(data, client);
    PushArrayCell(data, menu);
    db.Query(T_GetData, query, data);
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_End)
        delete menu;
}

public void T_GetData(Database m_db, DBResultSet results, const char[] error, any data) {
    if (error[0]) {
        LogError("PLAYERDB ERROR: %s", error);
        return;
    }

    int client = GetArrayCell(data, 0);
    if (SQL_GetRowCount(results) == 0)
        Server_PrintToChat(client, "Ranking", "You have no data in the database yet!");
    else {
        Menu menu = GetArrayCell(data, 1);
        menu.SetTitle("Your stats");

        SQL_FetchRow(results);
        
        int deaths = SQL_FetchInt(results, 1);
        char deaths_text[32];
        Format(deaths_text, sizeof(deaths_text), "Your deaths: %i", deaths);
        menu.AddItem("stats_deaths", deaths_text);

        int kills = SQL_FetchInt(results, 2);
        char kills_text[32];
        Format(kills_text, sizeof(kills_text), "Your kills: %i", kills);
        menu.AddItem("stats_kills", kills_text);

        int assists = SQL_FetchInt(results, 3);
        char assists_text[32];
        Format(assists_text, sizeof(assists_text), "Your assists: %i", assists);
        menu.AddItem("stats_assists", assists_text);

        float kd_ratio = float(kills) / float(deaths);
        char kd_ratio_text[21];
        Format(kd_ratio_text, sizeof(kd_ratio_text), "Your k/d ratio: %f", kd_ratio);
        menu.AddItem("stats_kd_ratio", kd_ratio_text);

        menu.Display(client, 20);
    }
}