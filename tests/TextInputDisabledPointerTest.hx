// Run (HashLink/SDL, needs a display), from the repository root, with the classpaths of haxeui-core, heaps, format and hlsdl:
// haxe -cp . -cp tests -cp <haxeui-core> -cp <heaps> -cp <format> -cp <hlsdl>/libs/sdl -D haxeui-core -D heaps -D hlsdl -D haxeui-heaps -D resourcesPath=<an empty directory> --main TextInputDisabledPointerTest -hl test.hl && hl test.hl
// A click on a TextField whose interactivity is disabled must give the focus neither to the field nor to the heaps scene;
// focus by code still works, and once interactivity is enabled again a click focuses the field. Disabling it in the middle
// of a selection drag ends the drag.
import haxe.ui.Toolkit;
import haxe.ui.components.TextField;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;

class TextInputDisabledPointerTest extends hxd.App {
    var frame = 0;
    var field:TextField;
    var other:TextField;
    var caretBeforeDisable = -1;

    static function fail(msg:String) {
        Sys.println("FAIL: " + msg);
        Sys.exit(1);
    }

    override function init() {
        Toolkit.init({root: s2d});
        // one root: haxeui keeps a focus per root component
        var root = new VBox();
        root.left = 20;
        root.top = 20;
        field = new TextField();
        field.width = 200;
        field.text = "hello world";
        root.addComponent(field);
        other = new TextField();
        other.width = 200;
        other.text = "other";
        root.addComponent(other);
        Screen.instance.addComponent(root);
    }

    function sceneInput(f:TextField):h2d.TextInput {
        return @:privateAccess f.getTextInput().textInput;
    }

    // A pointer event at a fraction of the width of the field's text, through the window as SDL delivers it.
    function pointer(kind:hxd.Event.EventKind, f:TextField, at:Float) {
        var b = sceneInput(f).getBounds();
        hxd.Window.getInstance().event(new hxd.Event(kind, b.x + b.width * at, b.y + b.height / 2));
    }

    // A full click (push and release) on the middle of the field's text.
    function click(f:TextField) {
        pointer(EMove, f, 0.5);
        pointer(EPush, f, 0.5);
        pointer(ERelease, f, 0.5);
    }

    function expectFocus(f:TextField, name:String, focused:Bool, when:String) {
        if (f.focus != focused) fail(name + (focused ? " has no" : " has the") + " haxeui focus " + when);
        if (sceneInput(f).hasFocus() != focused) fail(name + (focused ? " has no" : " has the") + " heaps scene focus " + when);
    }

    override function update(dt:Float) {
        frame++;
        switch (frame) {
            case 10:
                other.focus = true; // haxeui focuses the first field of a new root
                @:privateAccess field.disableInteractivity(true);
            case 12:
                click(field);
            case 16:
                expectFocus(field, "the disabled field", false, "after a click on it");
                expectFocus(other, "the other field", true, "after a click on the disabled one");
                if (sceneInput(field).cursorIndex >= 0) fail("a click on the disabled field placed the caret");
                field.focus = true;
            case 20:
                expectFocus(field, "the disabled field", true, "after focus = true");
                click(other);
            case 24:
                expectFocus(other, "the enabled field", true, "after a click on it");
                expectFocus(field, "the disabled field", false, "after a click on the other one");
                @:privateAccess field.disableInteractivity(false);
                click(field);
            case 28:
                expectFocus(field, "the field enabled again", true, "after a click on it");
                pointer(EPush, field, 0.05); // start a selection drag
            case 30:
                pointer(EMove, field, 0.5);
            case 32:
                if (sceneInput(field).cursorIndex <= 0) fail("the selection drag did not move the caret");
                caretBeforeDisable = sceneInput(field).cursorIndex;
                @:privateAccess field.disableInteractivity(true); // mid-drag
                pointer(EMove, field, 0.95);
                pointer(ERelease, field, 0.95);
            case 36:
                if (sceneInput(field).cursorIndex != caretBeforeDisable) fail("the selection drag went on after interactivity was disabled");
                Sys.println("ok");
                Sys.exit(0);
            default:
        }
    }

    static function main() {
        new TextInputDisabledPointerTest();
    }
}
