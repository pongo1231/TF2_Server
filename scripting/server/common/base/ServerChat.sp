#include <sourcemod>

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
   CreateNative("Server_PrintToChat", Server_PrintToChat);
   CreateNative("Server_PrintToChatAll", Server_PrintToChatAll);
   return APLRes_Success;
}

public int Server_PrintToChat(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    char tag[16];
    GetNativeString(2, tag, sizeof(tag));
    char text[128];
    GetNativeString(3, text, sizeof(text));

    PrintToChat(client, "\x03[%s]\x04 %s", tag, text);
}

public int Server_PrintToChatAll(Handle plugin, int numParams) {
    char tag[16];
    GetNativeString(1, tag, sizeof(tag));
    char text[128];
    GetNativeString(2, text, sizeof(text));

    PrintToChatAll("\x03[%s]\x04 %s", tag, text);
}