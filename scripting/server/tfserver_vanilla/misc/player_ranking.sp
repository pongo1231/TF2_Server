/**
  * NOTE: WIP
**/

#include <sourcemod>
#include <server/serverchat>

Database db;

public void OnPluginStart() {
	char error[255];
	db = SQL_DefConnect(error, sizeof(error));
	 
	if (db == null)
		PrintToServer("PLAYERDB FATAL ERROR: %s", error);
	else 
		HookEvent("player_death", Event_PlayerDeath);
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	int victim = GetEventInt(event, "userid");
	int attacker = GetEventInt(event, "attacker");
	if (victim == attacker || attacker <= 0)
		return Plugin_Continue;

	attacker = GetClientOfUserId(attacker);
	if (IsFakeClient(attacker))
		return Plugin_Continue;

	char attacker_name[64];
	GetClientName(attacker, attacker_name, sizeof(attacker_name));

	UpdateKills(attacker);
	Server_PrintToChat(attacker, "Ranking", "Added 1 kill.");

	char full_points_text[128];
	Format(full_points_text, sizeof(full_points_text), "You have %i kills.", GetPlayerKills(attacker_name));
	Server_PrintToChat(attacker, "Ranking", full_points_text);

	return Plugin_Continue;

}

void UpdateKills(int client) {
	char name[64];
	GetClientName(client, name, sizeof(name));

	char query[256];

	// First time killing
	Format(query, sizeof(query), "INSERT OR IGNORE INTO kills values('%s',0);", name);
	if (!SQL_FastQuery(db, query)) {
		char error[255];
		SQL_GetError(db, error, sizeof(error));
		PrintToServer("PLAYERDB ERROR: %s", error);
	}

	Format(query, sizeof(query), "UPDATE kills SET kills = %i WHERE name='%s';", GetPlayerKills(name) + 1, name);
	if (!SQL_FastQuery(db, query)) {
		char error[255];
		SQL_GetError(db, error, sizeof(error));
		PrintToServer("PLAYERDB ERROR: %s", error);
	}
}

int GetPlayerKills(char[] name) {
	DBResultSet hQuery;
	char query[256];
 
	Format(query, sizeof(query), "SELECT kills FROM kills WHERE name = '%s';", name);
 
	if ((hQuery = SQL_Query(db, query)) == null)
	{
		return 0;
	}
 
 	SQL_FetchRow(hQuery);
 	int kills = SQL_FetchInt(hQuery, 0);

	delete hQuery;
	return kills;
}