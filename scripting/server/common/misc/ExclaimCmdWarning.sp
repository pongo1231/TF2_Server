#include <sourcemod>
#include <server/serverchat>

public void OnClientSayCommand_Post(int client, const char[] cmd, const char[] sArgs) {
	char first_char[2];
	strcopy(first_char, sizeof(first_char), sArgs);
	if (StrEqual(first_char, "!")) {
		Server_PrintToChat(client, "Warning", "Please consider using a '/' instead of '!' as prefix, as this will make the chat message not show up in chat.");
		char suggestion[512];
		Format(suggestion, sizeof(suggestion), "Try the following instead: /%s", sArgs[1]);
		Server_PrintToChat(client, "Warning", suggestion);
	}
}