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
		db.Query(T_DataBaseCreated, "CREATE TABLE IF NOT EXISTS stats_scores(steam_id VARCHAR(64), score INT, rank INT)");
	}
}

public void T_DataBaseCreated(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0])
		LogError("PLAYERDB FATAL ERROR: %s", error);
	else
		CreateTimer(60.0, Timer_UpdateScores, _, TIMER_REPEAT);

	delete results;
}

public Action Timer_UpdateScores(Handle timer) {
	UpdateScores();
	UpdateRankings();
}

void UpdateScores() {
	char query[256];
	Format(query, sizeof(query), "SELECT * FROM stats_killing");
	db.Query(T_Scores_FetchData, query);
}

public void T_Scores_FetchData(Database m_db, DBResultSet results, const char[] error, any nothing) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	while (SQL_FetchRow(results)) {
		char steam_id[64];
		SQL_FetchString(results, 0, steam_id, sizeof(steam_id));
		int deaths = SQL_FetchInt(results, 1);
		int kills = SQL_FetchInt(results, 2);
		int assists = SQL_FetchInt(results, 3);

		char query[256];
		Format(query, sizeof(query), "SELECT * FROM stats_scores WHERE steam_id='%s'", steam_id);
		ArrayList data = CreateArray(8); // Don't truncate the player's name
		PushArrayString(data, steam_id);
		PushArrayCell(data, kills + assists / 2 - deaths);
		db.Query(T_Scores_CheckFirstTimeInsert, query, data);
	}

	delete results;
}

public void T_Scores_CheckFirstTimeInsert(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	if (SQL_GetRowCount(results) == 0) {
		char query[256];
		char steam_id[64];
		GetArrayString(data, 0, steam_id, sizeof(steam_id));
		Format(query, sizeof(query), "INSERT INTO stats_scores values('%s', 0, 999999999)", steam_id);
		db.Query(T_Scores_UpdateData, query, data);
	} else
		T_Scores_UpdateData(null, null, "", data);

	delete results;
}

public void T_Scores_UpdateData(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	char steam_id[64];
	GetArrayString(data, 0, steam_id, sizeof(steam_id));
	int score = GetArrayCell(data, 1);

	char query[256];
	Format(query, sizeof(query), "UPDATE stats_scores SET score=%i WHERE steam_id='%s'", score, steam_id);
	db.Query(T_Dummy, query, true);

	delete results;
}

void UpdateRankings() {
	char query[256];
	Format(query, sizeof(query), "SELECT * FROM stats_scores ORDER BY score DESC");
	db.Query(T_Ranking_UpdateData, query);
}

public void T_Ranking_UpdateData(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	int rank = 1;
	while (SQL_FetchRow(results)) {
		char steam_id[64];
		SQL_FetchString(results, 0, steam_id, sizeof(steam_id));

		char query[256];
		Format(query, sizeof(query), "UPDATE stats_scores SET rank=%i WHERE steam_id='%s'", rank, steam_id);
		db.Query(T_Dummy, query, true);
		rank++;
	}

	delete results;
}

public void T_Dummy(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0] && data)
		LogError("PLAYERDB ERROR: %s", error);

	delete results;
}