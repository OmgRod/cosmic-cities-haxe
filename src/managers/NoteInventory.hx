package managers;

class NoteInventory
{
	private static var instance:NoteInventory;
	
	private var collectedNotes:Array<String> = [];
	
	private static inline var TOTAL_NOTES:Int = 6;
	
	public static function getInstance():NoteInventory
	{
		if (instance == null)
		{
			trace("[NoteInventory] Creating new singleton instance");
			instance = new NoteInventory();
		}
		trace("[NoteInventory] getInstance() - Current count: " + instance.getCount());
		return instance;
	}
	
	private function new()
	{
		collectedNotes = [];
		trace("[NoteInventory] Constructor called, initialized with empty array");
	}
	
	public function addNote(noteData:String):Bool
	{
		if (collectedNotes.contains(noteData))
		{
			trace("[NoteInventory] Note already collected: " + noteData);
			return false;
		}
		
		collectedNotes.push(noteData);
		trace("[NoteInventory] Added note: " + noteData);
		printInventory();
		return true;
	}
	
	public function hasNote(noteData:String):Bool
	{
		return collectedNotes.contains(noteData);
	}
	
	public function getCount():Int
	{
		return collectedNotes.length;
	}
	
	public function getTotalPossible():Int
	{
		return TOTAL_NOTES;
	}
	
	public function getCollectedNotes():Array<String>
	{
		return collectedNotes.copy();
	}
	
	public function isFull():Bool
	{
		return collectedNotes.length >= TOTAL_NOTES;
	}
	
	public function reset():Void
	{
		collectedNotes = [];
		trace("[NoteInventory] Inventory reset");
	}
	
	private function printInventory():Void
	{
		trace("=== NOTE INVENTORY ===");
		trace("Collected: " + collectedNotes.length + " / " + TOTAL_NOTES);
		trace("Notes: " + collectedNotes.join(", "));
		trace("=====================");
	}
}
