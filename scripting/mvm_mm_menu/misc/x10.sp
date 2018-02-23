/**
*   NOTE: Unused!
*/

#include <sourcemod>
#include <tf2items>
#include <tf2attributes>
#include <tf2idb>

public int TF2Items_OnGiveNamedItem_Post(int client, char[] classname, int iItemDefinitionIndex, int itemLevel, int itemQuality, int entityIndex) {
        int slot = view_as<int>(TF2IDB_GetItemSlot(iItemDefinitionIndex));
        if (slot < 3) {
            int aid[TF2IDB_MAX_ATTRIBUTES];
            float values[TF2IDB_MAX_ATTRIBUTES];
            int attribNum = TF2IDB_GetItemAttributes(iItemDefinitionIndex, aid, values);

            for (int i = 0; i < attribNum; i++) {
                    int attribIndex = aid[i];
                    if (values[i] != 1 && values[i] != 0) {
                        TF2Attrib_SetByDefIndex(entityIndex, attribIndex, values[i]);
                        TF2Attrib_ClearCache(entityIndex);
                    }
            }
        }
}