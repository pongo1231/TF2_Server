 #include <sourcemod>
 #include <sdktools>

public void OnClientPutInServer(int client) {
	EmitSoundToClient(client, "ui/vote_started.wav");
}