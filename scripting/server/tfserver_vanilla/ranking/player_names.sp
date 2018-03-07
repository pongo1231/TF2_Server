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
		db.Query(T_DataBaseCreated, "CREATE TABLE IF NOT EXISTS stats_names(steam_id VARCHAR(64), player_name VARCHAR(64))");
	}
}

public void T_DataBaseCreated(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0])
		LogError("PLAYERDB FATAL ERROR: %s", error);
	else
		CreateTimer(300.0, Timer_UpdateNames, _, TIMER_REPEAT);
}

public Action Timer_UpdateNames(Handle timer) {
	for (int i = 1; i < GetMaxClients() + 1; i++)
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			char player_name[64];
			GetClientName(i, player_name, sizeof(player_name));
			char player_name_safe[64];
			SQL_EscapeString(db, player_name, player_name_safe, sizeof(player_name_safe));
			UpdateName(GetSteamAccountID(i), player_name_safe);
		}

}

void UpdateName(int steam_id, const char[] name) {
	char query[256];

	Format(query, sizeof(query), "SELECT * FROM stats_names WHERE steam_id='%i'", steam_id);
	ArrayList data = CreateArray(8); // Don't truncate the player's name
	PushArrayCell(data, steam_id);
	PushArrayString(data, name);
	db.Query(T_CheckFirstTimeInsert, query, data);
}

public void T_CheckFirstTimeInsert(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	if (SQL_GetRowCount(results) == 0) {
		char query[256];
		char name[64];
		GetArrayString(data, 1, name, sizeof(name));
		Format(query, sizeof(query), "INSERT INTO stats_names values('%i', '%s')", GetArrayCell(data, 0), name);
		db.Query(T_ProceedUpdate, query, data);
	} else
		T_ProceedUpdate(null, null, "", data);
}

public void T_ProceedUpdate(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	char query[256];
	char name[64];
	GetArrayString(data, 1, name, sizeof(name));
	Format(query, sizeof(query), "UPDATE stats_names SET player_name = '%s' WHERE steam_id='%i'", name, GetArrayCell(data, 0));
	db.Query(T_Dummy, query, true);
}

public void T_Dummy(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0] && data)
		LogError("PLAYERDB ERROR: %s", error);
}