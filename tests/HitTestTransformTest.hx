// Run (HashLink/SDL, needs a display), from the repository root, with the classpaths of haxeui-core, heaps, format and hlsdl:
// haxe -cp . -cp tests -cp <haxeui-core> -cp <heaps> -cp <format> -cp <hlsdl>/libs/sdl -D haxeui-core -D heaps -D hlsdl -D haxeui-heaps -D resourcesPath=<an empty directory> --main HitTestTransformTest -hl test.hl && hl test.hl
// inBounds and hitTest of a component whose root is under a rotated and scaled h2d.Object are true where Heaps draws the
// component and false where it would be drawn without the transform; the clip of a scroll view under that object is
// tested where it is drawn too. Under an identity parent the results are those of the plain rectangles.
import haxe.ui.Toolkit;
import haxe.ui.containers.ScrollView;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

class HitTestTransformTest extends hxd.App {
    var frame = 0;
    var host:h2d.Object;
    var box:Component;
    var scroll:ScrollView;
    var content:Component;
    var plain:Component;

    static function fail(msg:String) {
        Sys.println("FAIL: " + msg);
        Sys.exit(1);
    }

    function component(w:Float, h:Float):Component {
        var c = new Component();
        c.width = w;
        c.height = h;
        return c;
    }

    function addRoot(c:Component, left:Float, top:Float, parent:h2d.Object) {
        c.left = left;
        c.top = top;
        if (parent != null) parent.addChild(c);
        Screen.instance.addComponent(c);
    }

    override function init() {
        Toolkit.init({root: s2d});
        host = new h2d.Object(s2d);
        host.x = 500;
        host.y = 60;
        host.rotation = Math.PI / 2;
        host.setScale(2);

        box = component(100, 40);
        addRoot(box, 10, 20, host);

        scroll = new ScrollView();
        scroll.width = 100;
        scroll.height = 60;
        content = component(300, 300);
        scroll.addComponent(content);
        addRoot(scroll, 10, 80, host);

        plain = component(100, 40);
        addRoot(plain, 600, 400, null);
    }

    // The scene point Heaps draws the local point (lx, ly) of c at.
    function drawn(c:Component, lx:Float, ly:Float):h2d.col.Point {
        return c.localToGlobal(new h2d.col.Point(lx, ly));
    }

    // inBounds and hitTest take a scene point divided by the toolkit scale.
    function inBounds(c:Component, p:h2d.col.Point):Bool {
        return @:privateAccess c.inBounds(p.x / Toolkit.scaleX, p.y / Toolkit.scaleY);
    }

    function hitTest(c:Component, p:h2d.col.Point):Bool {
        return c.hitTest(p.x / Toolkit.scale, p.y / Toolkit.scale);
    }

    function expect(name:String, c:Component, p:h2d.col.Point, over:Bool, withHitTest:Bool = true) {
        if (inBounds(c, p) != over) fail("inBounds of " + name + " at " + p + " is " + !over);
        if (withHitTest && hitTest(c, p) != over) fail("hitTest of " + name + " at " + p + " is " + !over);
    }

    override function update(dt:Float) {
        frame++;
        if (frame < 5) return;

        // the box: its middle as drawn, and the middle of where it would be with the parent only translated
        expect("the box", box, drawn(box, 50, 20), true);
        expect("the box", box, drawn(box, 2, 2), true);
        expect("the box", box, new h2d.col.Point(host.x + 10 + 50, host.y + 20 + 20), false);
        expect("the box", box, drawn(box, 50, 45), false);

        // the scroll view's content: drawn inside the viewport, and drawn right of it (inside the content, outside the clip)
        var inside = drawn(scroll, 50, 30);
        var outside = drawn(scroll, 150, 30);
        var local = content.globalToLocal(outside.clone());
        if (local.x < 0 || local.y < 0 || local.x > content.width || local.y > content.height) {
            fail("the point right of the viewport is not on the content (" + local + "), the test proves nothing");
        }
        expect("the scroll view's content", content, inside, true, false);
        expect("the scroll view's content", content, outside, false, false);
        expect("the scroll view", scroll, inside, true);
        expect("the scroll view", scroll, outside, false);

        // under the identity scene: as before
        expect("the plain box", plain, drawn(plain, 50, 20), true);
        expect("the plain box", plain, drawn(plain, -10, 20), false);

        Sys.println("OK");
        Sys.exit(0);
    }

    static function main() {
        new HitTestTransformTest();
    }
}
