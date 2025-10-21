package managers;

import managers.DialogueManager;

class DialogueBuilder
{
	public static function buildAllDialogues():Void
	{
		buildNoteCollectionDialogues();
		buildBoundingBoxDialogues();
	}
	
	private static function buildNoteCollectionDialogues():Void
	{
		var dialogueManager = DialogueManager.getInstance();
		
		var locKey = "$NOTE_COLLECTED";
		var treeId = "note_collected";
		
		var tree:DialogueTree = {
			id: treeId,
			startId: "1",
			lines: [
				"1" => {
					speaker: "System",
					text: locKey,
					nextId: "end"
				}
			]
		};
		
		dialogueManager.registerDialogue(tree);
	}
	
	private static function buildBoundingBoxDialogues():Void
	{
		var dialogueManager = DialogueManager.getInstance();
		
		var collectAllNotesText = Main.tongue.get("$COLLECT_ALL_NOTES", "dialog");
		
		var tree:DialogueTree = {
			id: "collect_all_notes",
			startId: "1",
			lines: [
				"1" => {
					speaker: "System",
					text: collectAllNotesText,
					nextId: "end"
				}
			]
		};
		
		dialogueManager.registerDialogue(tree);
	}
}
