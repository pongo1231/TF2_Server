#include <sourcemod>
#include <server/serverchat>

Database db;

enum {
	UPDATE_DEATH,
	UPDATE_KILL,
	UPDATE_ASSIST
}

public void OnPluginStart() {
	Database.Connect(T_DataBaseConnect, "players-local");
}

public void T_DataBaseConnect(Database m_db, const char[] error, any data) {
	if (m_db == null)
		LogError("PLAYERDB FATAL ERROR: %s", error);
	else {
		db = m_db;
		db.Query(T_DataBaseCreated, "CREATE TABLE IF NOT EXISTS stats_killing(steam_id VARCHAR(64), deaths INT, kills INT, assists INT)");
	}
}

public void T_DataBaseCreated(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0])
		LogError("PLAYERDB FATAL ERROR: %s", error);
	else
		HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsFakeClient(victim))
		UpdateData(GetSteamAccountID(victim), UPDATE_DEATH);

	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (attacker != 0 && attacker != victim && !IsFakeClient(attacker))
		UpdateData(GetSteamAccountID(attacker), UPDATE_KILL);

	int assister = GetClientOfUserId(GetEventInt(event, "assister"));
	if (assister != 0 && !IsFakeClient(assister))
		UpdateData(GetSteamAccountID(assister), UPDATE_ASSIST);
}

void UpdateData(int steam_id, int type) {
	char query[256];

	Format(query, sizeof(query), "SELECT * FROM stats_killing WHERE steam_id='%i'", steam_id);
	ArrayList data = CreateArray();
	PushArrayCell(data, steam_id);
	PushArrayCell(data, type);
	db.Query(T_CheckFirstTimeInsert, query, data);
}

public void T_CheckFirstTimeInsert(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	if (SQL_GetRowCount(results) == 0) {
		char query[256];
		Format(query, sizeof(query), "INSERT INTO stats_killing values('%i', 0, 0, 0)", GetArrayCell(data, 0));
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
	int steam_id = GetArrayCell(data, 0);
	switch (GetArrayCell(data, 1)) {
		case UPDATE_DEATH: {
			Format(query, sizeof(query), "SELECT deaths FROM stats_killing WHERE steam_id='%i'", steam_id);
			db.Query(T_UpdateDeaths, query, steam_id);
		}
		case UPDATE_KILL: {
			Format(query, sizeof(query), "SELECT kills FROM stats_killing WHERE steam_id='%i'", steam_id);
			db.Query(T_UpdateKills, query, steam_id);
		}
		case UPDATE_ASSIST: {
			Format(query, sizeof(query), "SELECT assists FROM stats_killing WHERE steam_id='%i'", steam_id);
			db.Query(T_UpdateAssists, query, steam_id);
		}
	}
}

public void T_UpdateDeaths(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0] || !SQL_GetRowCount(results)) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	SQL_FetchRow(results);
 	int deaths = SQL_FetchInt(results, 0);

	char query[256];
	Format(query, sizeof(query), "UPDATE stats_killing SET deaths = %i WHERE steam_id='%i'", deaths + 1, data);
	db.Query(T_Dummy, query, true);
}

public void T_UpdateKills(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0] || !SQL_GetRowCount(results)) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	SQL_FetchRow(results);
 	int kills = SQL_FetchInt(results, 0);

	char query[256];
	Format(query, sizeof(query), "UPDATE stats_killing SET kills = %i WHERE steam_id='%i'", kills + 1, data);
	db.Query(T_Dummy, query, true);
}

public void T_UpdateAssists(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0] || !SQL_GetRowCount(results)) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	SQL_FetchRow(results);
 	int assists = SQL_FetchInt(results, 0);

	char query[256];
	Format(query, sizeof(query), "UPDATE stats_killing SET assists = %i WHERE steam_id='%i'", assists + 1, data);
	db.Query(T_Dummy, query, true);
}

public void T_Dummy(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0] && data)
		LogError("PLAYERDB ERROR: %s", error);
}