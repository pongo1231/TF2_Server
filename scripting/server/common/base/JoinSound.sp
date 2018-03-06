 #include <sourcemod>
 #include <sdktools>

public void OnMapStart() {
	PrecacheSound("ui/duel_event.wav");
}

public void OnClientPutInServer(int client) {
	EmitSoundToClient(client, "ui/duel_event.wav");
}