#include <sourcemod>

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    CreateNative("Server_PrintToChat", Server_PrintToChat);
    CreateNative("Server_PrintToChatAll", Server_PrintToChatAll);
    return APLRes_Success;
}

public int Server_PrintToChat(Handle plugin, int numParams, bool log_to_server) {
    int client = GetNativeCell(1);
    char tag[16];
    GetNativeString(2, tag, sizeof(tag));
    char text[128];
    GetNativeString(3, text, sizeof(text));

    PrintToChat(client, "\x03[%s]\x04 %s", tag, text);

    if (GetNativeCell(4)) {
        char client_name[64];
        GetClientName(client, client_name, sizeof(client_name));
        char server_text[256];
        Format(server_text, sizeof(server_text), "(%s) [%s] %s", client_name, tag, text);
        PrintToServer(server_text);
    }
}

public int Server_PrintToChatAll(Handle plugin, int numParams) {
    char tag[16];
    GetNativeString(1, tag, sizeof(tag));
    char text[128];
    GetNativeString(2, text, sizeof(text));

    PrintToChatAll("\x03[%s]\x04 %s", tag, text);

    if (GetNativeCell(3)) {
        char server_text[256];
        Format(server_text, sizeof(server_text), "[%s] %s", tag, text);
        PrintToServer(server_text);
    }
}
