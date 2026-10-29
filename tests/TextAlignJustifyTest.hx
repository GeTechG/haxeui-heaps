// Run (HashLink/SDL, needs a display), from the repository root, with the classpaths of haxeui-core, heaps, format and hlsdl:
// haxe -cp . -cp tests -cp <haxeui-core> -cp <heaps> -cp <format> -cp <hlsdl>/libs/sdl -D haxeui-core -D heaps -D hlsdl -D haxeui-heaps -D resourcesPath=<an empty directory> --main TextAlignJustifyTest -hl test.hl && hl test.hl
// `text-align: justify` gives the text of a label the alignment Justify. With a fixed width its wrapped lines are stretched
// to the width of the label; with an auto width it is laid out and placed as `text-align: left`.
import haxe.ui.Toolkit;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;

class TextAlignJustifyTest extends hxd.App {
    static inline var TEXT = "The quick brown fox jumps over the lazy dog and keeps on running far away";
    static inline var WIDTH = 160;

    var frame = 0;
    var fixedLeft:Label;
    var fixedJustify:Label;
    var autoLeft:Label;
    var autoJustify:Label;

    static function fail(msg:String) {
        Sys.println("FAIL: " + msg);
        Sys.exit(1);
    }

    function label(root:VBox, align:String, fixedWidth:Bool, text:String):Label {
        var l = new Label();
        if (fixedWidth) {
            l.width = WIDTH;
        }
        l.wordWrap = fixedWidth;
        l.text = text;
        l.customStyle.textAlign = align;
        root.addComponent(l);
        return l;
    }

    override function init() {
        Toolkit.init({root: s2d});
        var root = new VBox();
        root.left = 20;
        root.top = 20;
        fixedLeft = label(root, "left", true, TEXT);
        fixedJustify = label(root, "justify", true, TEXT);
        autoLeft = label(root, "left", false, "short line");
        autoJustify = label(root, "justify", false, "short line");
        Screen.instance.addComponent(root);
    }

    function sprite(l:Label):h2d.Text {
        return @:privateAccess l.getTextDisplay().sprite;
    }

    override function update(dt:Float) {
        frame++;
        if (frame < 5) return;

        var left = sprite(fixedLeft);
        var justify = sprite(fixedJustify);
        if (justify.textAlign != h2d.Text.Align.Justify) fail("text-align: justify gives " + justify.textAlign);
        if (left.textAlign != h2d.Text.Align.Left) fail("text-align: left gives " + left.textAlign);
        if (justify.maxWidth != WIDTH) fail("the fixed-width label's text has maxWidth " + justify.maxWidth + ", expected " + WIDTH);
        if (justify.textHeight != left.textHeight || justify.textHeight < justify.font.lineHeight * 2) {
            fail("the text does not wrap onto the same several lines as with left: " + justify.textHeight + " vs " + left.textHeight);
        }
        // textWidth is the widest line: a stretched line ends exactly at maxWidth, a left-aligned one before it
        if (Math.abs(justify.textWidth - WIDTH) > 1) fail("the first wrapped line is " + justify.textWidth + " wide, expected " + WIDTH);
        if (left.textWidth >= WIDTH - 1) fail("the left-aligned text already fills the width (" + left.textWidth + "), the test proves nothing");
        if (justify.x != left.x) fail("the justified text is placed at x " + justify.x + ", the left-aligned one at " + left.x);

        var aLeft = sprite(autoLeft);
        var aJustify = sprite(autoJustify);
        if (aJustify.textAlign != h2d.Text.Align.Justify) fail("auto width: text-align: justify gives " + aJustify.textAlign);
        if (aJustify.textWidth != aLeft.textWidth || aJustify.x != aLeft.x || autoJustify.width != autoLeft.width) {
            fail("auto width: justify is laid out as " + aJustify.textWidth + " at " + aJustify.x + ", left as " + aLeft.textWidth + " at " + aLeft.x);
        }

        Sys.println("OK");
        Sys.exit(0);
    }

    static function main() {
        new TextAlignJustifyTest();
    }
}
