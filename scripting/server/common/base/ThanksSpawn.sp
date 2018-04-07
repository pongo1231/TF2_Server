 #include <sourcemod>
 #include <tf2>
 #include <tf2_stocks>

public void TF2_OnConditionAdded(int client, TFCond condition) {
	if (condition == TFCond_SpawnOutline)
		FakeClientCommand(client, "voicemenu %i %i", GetRandomInt(0, 2), GetRandomInt(0, 8));
}