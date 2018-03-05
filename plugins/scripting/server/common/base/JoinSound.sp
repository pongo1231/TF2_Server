 #include <sourcemod>
 #include <sdktools>

public void OnPluginStart() {
	PrecacheSound("ui/duel_event.wav");
}

public void OnClientPutInServer(int client) {
	EmitSoundToClient(client, "ui/duel_event.wav");
}