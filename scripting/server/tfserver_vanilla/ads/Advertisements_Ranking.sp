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
		CreateTimer(600.0, Timer_DisplayRanking, _, TIMER_REPEAT);
	}
}

public Action Timer_DisplayRanking(Handle timer) {
	char query[256];
	for (int i = 1; i < GetMaxClients(); i++) {
		if (IsClientInGame(i) && !IsFakeClient(i)) {
			Format(query, sizeof(query), "SELECT rank,score FROM stats_scores");
			db.Query(T_DisplayRankInfo, query, i);
		}
	}
}

public void T_DisplayRankInfo(Database m_db, DBResultSet results, const char[] error, any data) {
	if (error[0]) {
		LogError("PLAYERDB ERROR: %s", error);
		return;
	}

	if (SQL_GetRowCount(results) > 0) {
		SQL_FetchRow(results);

		char text[128];
		Format(text, sizeof(text), "You are currently rank #%i with a score of %i.", SQL_FetchInt(data, 0), SQL_FetchInt(data, 1));
		Server_PrintToChat(data, "Ranking", text);
		Server_PrintToChat(data, "Ranking", "Type /rank for more info.");
		Server_PrintToChat(data, "Ranking", "Also type /top7 to see the current Top 7.");
	}
}