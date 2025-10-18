package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import states.GameState;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;
import utils.GameSaveManager;

class SaveSelectState extends FlxState {
    var font:flixel.text.FlxBitmapFont;

    
    var slotContainers:Array<FlxGroup> = [];
    var slotModes:Array<String> = []; 
    var slotRects:Array<{x:Int,y:Int,w:Int,h:Int}> = [];
    var slotBoxes:Array<FlxSprite> = [];

    
    var nameEntryActive:Bool = false;
    var nameEntrySlot:Int = -1;
    var nameEntryGroup:FlxGroup;
    var nameEntryText:FlxBitmapText;
    var nameEntryValue:String = "";
    var cursorBlink:Float = 0;
    
    
    var blockButtonsUntil:Float = 0;

    override public function create() {
        super.create();

        var starfield = new Starfield();
        add(starfield);

        var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
        font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

        var title = new FlxBitmapText(0, 0, "Select Save Slot", font);
        title.scale.set(1.2, 1.2);
        title.updateHitbox();
        title.x = (FlxG.width - title.textWidth * title.scale.x) / 2;
        title.y = 25;
        title.color = 0xFFFFFF00;
        add(title);

        var top = 90;
        var slotHeight = 100;
        var gap = 20;
        for (i in 0...3) {
            var group = new FlxGroup();
            slotContainers.push(group);
            slotModes.push("view");
            slotRects.push({x:0,y:0,w:0,h:0});
            slotBoxes.push(null);
            add(group);
            buildSlotView(i + 1, top + i * (slotHeight + gap), slotHeight);
        }

        
        var backW = 140; var backH = 38;
        var backX = (FlxG.width - backW) / 2;
		var backY = FlxG.height - backH - 30;
        var backBtn = new TextButton(backX, backY, Main.tongue.get("$GENERAL_BACK", "ui"), font, backW, backH);
        backBtn.setCallback(() -> FlxG.switchState(() -> new MainMenuState()));
        add(backBtn);
    }

    function clearGroup(g:FlxGroup) {
        for (m in g.members) if (m != null) remove(m);
        g.clear();
    }

    function buildSlotView(slot:Int, y:Int, h:Int) {
        var g = slotContainers[slot - 1];
        clearGroup(g);

        var x = 50;
        var w = FlxG.width - 100;

        var box = new FlxSprite(x, y);
        box.makeGraphic(w, h, FlxColor.fromRGB(30, 30, 40, 200));
        add(box); g.add(box);
        slotBoxes[slot - 1] = box;

        slotRects[slot - 1] = {x:x, y:y, w:w, h:h};

        if (!GameSaveManager.exists(slot)) {
            var t = new FlxBitmapText(0, 0, "New Save", font);
            t.scale.set(1.0, 1.0);
            t.updateHitbox();
            t.x = x + (w - t.textWidth * t.scale.x) / 2;
            t.y = y + (h - t.height * t.scale.y) / 2;
            t.color = 0xFFAAAAAA;
            add(t); g.add(t);
            slotModes[slot - 1] = "view";
            return;
        }

        var data = GameSaveManager.loadData(slot);
        var username = data != null ? data.username : "Unknown";
        var timeStr = data != null ? GameSaveManager.formatDuration(data.playTimeSeconds) : "00:00";

        var slotLabel = new FlxBitmapText(x + 12, y + 10, 'Slot ' + slot, font);
        slotLabel.scale.set(0.75, 0.75);
        slotLabel.updateHitbox();
        slotLabel.color = 0xFFFFFF00;
        add(slotLabel); g.add(slotLabel);

        var userLabel = new FlxBitmapText(x + 12, y + h - 28, username, font);
        userLabel.scale.set(0.9, 0.9);
        userLabel.updateHitbox();
        userLabel.color = 0xFFFFFFFF;
        add(userLabel); g.add(userLabel);

        var timeLabel = new FlxBitmapText(0, 0, timeStr, font);
        timeLabel.scale.set(0.75, 0.75);
        timeLabel.updateHitbox();
        timeLabel.x = x + w - (timeLabel.textWidth * timeLabel.scale.x) - 12;
        timeLabel.y = y + 10;
        timeLabel.color = 0xFFAAAAAA;
        add(timeLabel); g.add(timeLabel);

        slotModes[slot - 1] = "view";
    }

    function buildNewName(slot:Int, y:Int, h:Int) {
        var g = slotContainers[slot - 1];
        clearGroup(g);
        var x = 50; var w = FlxG.width - 100;

        var box = new FlxSprite(x, y);
        box.makeGraphic(w, h, FlxColor.fromRGB(30, 30, 40, 200));
        add(box); g.add(box);
        slotBoxes[slot - 1] = box;

        var prompt = new FlxBitmapText(0, 0, "Enter your name:", font);
        prompt.scale.set(0.95, 0.95);
        prompt.updateHitbox();
        prompt.x = x + 12; prompt.y = y + 12;
        prompt.color = 0xFFFFFF00;
        add(prompt); g.add(prompt);

        nameEntryGroup = g;
        nameEntryActive = true;
        nameEntrySlot = slot;
        nameEntryValue = "";
        cursorBlink = 0;

        nameEntryText = new FlxBitmapText(0, 0, "", font);
        nameEntryText.scale.set(1.0, 1.0);
        nameEntryText.updateHitbox();
        nameEntryText.x = x + 12; nameEntryText.y = y + 44;
        nameEntryText.color = 0xFFFFFFFF;
        add(nameEntryText); g.add(nameEntryText);

        var hint = new FlxBitmapText(0, 0, 'ENTER to confirm  •  ESC to cancel', font);
        hint.scale.set(0.6, 0.6);
        hint.updateHitbox();
        hint.x = x + 12; hint.y = y + h - 24;
        hint.color = 0xFF888888;
        add(hint); g.add(hint);

        slotModes[slot - 1] = "newName";
    }

    function buildSlotActions(slot:Int, y:Int, h:Int) {
        var g = slotContainers[slot - 1];
        clearGroup(g);
        var x = 50; var w = FlxG.width - 100;

        var box = new FlxSprite(x, y);
        box.makeGraphic(w, h, FlxColor.fromRGB(30, 30, 40, 200));
        add(box); g.add(box);
        slotBoxes[slot - 1] = box;

        var data = GameSaveManager.loadData(slot);
        var username = data != null ? data.username : 'Player' + slot;

        var title = new FlxBitmapText(0, 0, 'Slot ' + slot + ' — ' + username, font);
        title.scale.set(0.95, 0.95);
        title.updateHitbox();
        title.x = x + 12; title.y = y + 12;
        title.color = 0xFFFFFF00;
        add(title); g.add(title);

        var btnW = 130; var btnH = 36; var gap = 10;
        var totalW = btnW * 3 + gap * 2;
        var startX = x + (w - totalW) / 2;
        var btnY = Std.int(y + h * 0.6 - btnH/2);

        var contBtn = new TextButton(startX, btnY, "Continue", font, btnW, btnH);
        contBtn.setCallback(() -> {
            if (haxe.Timer.stamp() < blockButtonsUntil) return;
            var d = GameSaveManager.loadData(slot);
            if (d == null) d = { username: username, playTimeSeconds: 0 };
            GameSaveManager.setCurrent(slot, d);
            FlxG.switchState(() -> new GameState());
        });
        add(contBtn); g.add(contBtn);

        var delBtn = new TextButton(startX + btnW + gap, btnY, "Delete", font, btnW, btnH);
        delBtn.setCallback(() -> {
            if (haxe.Timer.stamp() < blockButtonsUntil) return;
            blockButtonsUntil = haxe.Timer.stamp() + 0.15;
            buildConfirmDelete(slot, y, h);
        });
        add(delBtn); g.add(delBtn);

        var backBtn = new TextButton(startX + (btnW + gap) * 2, btnY, Main.tongue.get("$GENERAL_BACK", "ui"), font, btnW, btnH);
        backBtn.setCallback(() -> {
            if (haxe.Timer.stamp() < blockButtonsUntil) return;
            blockButtonsUntil = haxe.Timer.stamp() + 0.15;
            buildSlotView(slot, y, h);
        });
        add(backBtn); g.add(backBtn);

        slotModes[slot - 1] = "actions";
    }

    function buildConfirmDelete(slot:Int, y:Int, h:Int) {
        var g = slotContainers[slot - 1];
        clearGroup(g);
        var x = 50; var w = FlxG.width - 100;

        var box = new FlxSprite(x, y);
        box.makeGraphic(w, h, FlxColor.fromRGB(40, 20, 20, 200));
        add(box); g.add(box);
        slotBoxes[slot - 1] = box;

        var prompt = new FlxBitmapText(0, 0, "Delete this save?", font);
        prompt.scale.set(1.0, 1.0);
        prompt.updateHitbox();
        prompt.x = x + 12; prompt.y = y + 12;
        prompt.color = 0xFFFF4444;
        add(prompt); g.add(prompt);

        var warning = new FlxBitmapText(0, 0, "This cannot be undone!", font);
        warning.scale.set(0.7, 0.7);
        warning.updateHitbox();
        warning.x = x + 12; warning.y = y + 38;
        warning.color = 0xFFFFAAAA;
        add(warning); g.add(warning);

        var btnW = 130; var btnH = 36; var gap = 16;
        var totalW = btnW * 2 + gap;
        var startX = x + (w - totalW) / 2;
        var btnY = Std.int(y + h * 0.65 - btnH/2);

        var yesBtn = new TextButton(startX, btnY, "Yes, Delete", font, btnW, btnH);
        yesBtn.setCallback(() -> {
            if (haxe.Timer.stamp() < blockButtonsUntil) return;
            blockButtonsUntil = haxe.Timer.stamp() + 0.15;
            GameSaveManager.delete(slot);
            buildSlotView(slot, y, h);
        });
        add(yesBtn); g.add(yesBtn);

        var noBtn = new TextButton(startX + btnW + gap, btnY, "Cancel", font, btnW, btnH);
        noBtn.setCallback(() -> {
            if (haxe.Timer.stamp() < blockButtonsUntil) return;
            blockButtonsUntil = haxe.Timer.stamp() + 0.15;
            buildSlotView(slot, y, h);
        });
        add(noBtn); g.add(noBtn);

        slotModes[slot - 1] = "confirmDelete";
    }

    override public function update(dt:Float) {
        super.update(dt);

        
        if (!nameEntryActive) {
            var mx = FlxG.mouse.x; var my = FlxG.mouse.y;
            for (i in 0...3) {
                if (slotModes[i] == "view" && slotBoxes[i] != null) {
                    var r = slotRects[i];
                    var hover = mx >= r.x && mx <= r.x + r.w && my >= r.y && my <= r.y + r.h;
                    slotBoxes[i].color = hover ? FlxColor.fromRGB(45, 45, 60) : FlxColor.fromRGB(30, 30, 40);
                }
            }

            
            if (FlxG.mouse.justPressed) {
                for (i in 0...3) {
                    var r = slotRects[i];
                    if (mx >= r.x && mx <= r.x + r.w && my >= r.y && my <= r.y + r.h) {
                        if (slotModes[i] == "view") {
                            var slot = i + 1;
                            
                            
                            for (j in 0...3) {
                                if (j != i && slotModes[j] != "view") {
                                    var otherSlot = j + 1;
                                    var otherRect = slotRects[j];
                                    buildSlotView(otherSlot, otherRect.y, otherRect.h);
                                }
                            }
                            
                            
                            blockButtonsUntil = haxe.Timer.stamp() + 0.15;
                            if (GameSaveManager.exists(slot)) {
                                buildSlotActions(slot, r.y, r.h);
                            } else {
                                buildNewName(slot, r.y, r.h);
                            }
                            break;
                        }
                    }
                }
            }
        }

        
        if (nameEntryActive) {
            cursorBlink += dt;
            var cursor = (cursorBlink % 1.0 < 0.5) ? "_" : "";
            nameEntryText.text = nameEntryValue + cursor;

            if (FlxG.keys.justPressed.ENTER) {
                var usr = StringTools.trim(nameEntryValue);
                if (usr == "") usr = 'Player' + nameEntrySlot;
                GameSaveManager.saveData(nameEntrySlot, { username: usr, playTimeSeconds: 0 });
                nameEntryActive = false;
                var r = slotRects[nameEntrySlot - 1];
                buildSlotActions(nameEntrySlot, r.y, r.h);
            } else if (FlxG.keys.justPressed.ESCAPE) {
                nameEntryActive = false;
                var r2 = slotRects[nameEntrySlot - 1];
                buildSlotView(nameEntrySlot, r2.y, r2.h);
            } else {
                
                var ch = pollTypedChar();
                if (ch != null && nameEntryValue.length < 20) {
                    nameEntryValue += ch;
                    cursorBlink = 0; 
                }
                if (FlxG.keys.justPressed.BACKSPACE && nameEntryValue.length > 0) {
                    nameEntryValue = nameEntryValue.substr(0, nameEntryValue.length - 1);
                    cursorBlink = 0;
                }
            }
        }
    }

    
    function pollTypedChar():Null<String> {
        
        if (FlxG.keys.justPressed.A) return "A";
        if (FlxG.keys.justPressed.B) return "B";
        if (FlxG.keys.justPressed.C) return "C";
        if (FlxG.keys.justPressed.D) return "D";
        if (FlxG.keys.justPressed.E) return "E";
        if (FlxG.keys.justPressed.F) return "F";
        if (FlxG.keys.justPressed.G) return "G";
        if (FlxG.keys.justPressed.H) return "H";
        if (FlxG.keys.justPressed.I) return "I";
        if (FlxG.keys.justPressed.J) return "J";
        if (FlxG.keys.justPressed.K) return "K";
        if (FlxG.keys.justPressed.L) return "L";
        if (FlxG.keys.justPressed.M) return "M";
        if (FlxG.keys.justPressed.N) return "N";
        if (FlxG.keys.justPressed.O) return "O";
        if (FlxG.keys.justPressed.P) return "P";
        if (FlxG.keys.justPressed.Q) return "Q";
        if (FlxG.keys.justPressed.R) return "R";
        if (FlxG.keys.justPressed.S) return "S";
        if (FlxG.keys.justPressed.T) return "T";
        if (FlxG.keys.justPressed.U) return "U";
        if (FlxG.keys.justPressed.V) return "V";
        if (FlxG.keys.justPressed.W) return "W";
        if (FlxG.keys.justPressed.X) return "X";
        if (FlxG.keys.justPressed.Y) return "Y";
        if (FlxG.keys.justPressed.Z) return "Z";
        
        
        if (FlxG.keys.justPressed.ZERO) return "0";
        if (FlxG.keys.justPressed.ONE) return "1";
        if (FlxG.keys.justPressed.TWO) return "2";
        if (FlxG.keys.justPressed.THREE) return "3";
        if (FlxG.keys.justPressed.FOUR) return "4";
        if (FlxG.keys.justPressed.FIVE) return "5";
        if (FlxG.keys.justPressed.SIX) return "6";
        if (FlxG.keys.justPressed.SEVEN) return "7";
        if (FlxG.keys.justPressed.EIGHT) return "8";
        if (FlxG.keys.justPressed.NINE) return "9";
        
        
        if (FlxG.keys.justPressed.SPACE) return " ";
        if (FlxG.keys.justPressed.MINUS) return "-";
        
        return null;
    }
}
