#include <sourcemod>
#include <server/serverchat>

public void OnClientSayCommand_Post(int client, const char[] cmd, const char[] s_args) {
	char first_char[2];
	strcopy(first_char, sizeof(first_char), s_args);
	if (StrEqual(first_char, "!") && strlen(s_args) > 1 && GetCommandFlags(s_args[1]) != INVALID_FCVAR_FLAGS) {
		Server_PrintToChat(client, "Warning", "Please consider using a '/' instead of '!' as prefix, as this will make the chat message not show up in chat.");
		char suggestion[512];
		Format(suggestion, sizeof(suggestion), "Try the following instead: /%s", s_args[1]);
		Server_PrintToChat(client, "Warning", suggestion);
	}
}