// Run (HashLink/SDL, needs a display), from the repository root, with the classpaths of haxeui-core, heaps, format and hlsdl:
// haxe -cp . -cp tests -cp <haxeui-core> -cp <heaps> -cp <format> -cp <hlsdl>/libs/sdl -D haxeui-core -D heaps -D hlsdl -D haxeui-heaps -D resourcesPath=<an empty directory> --main GlContextResetTest -hl test.hl && hl test.hl
// heaps' context-lost path (Engine.onCreate(true)) disposes every texture; a gradient background, an Image, a background
// image and ComponentGraphics.setPixels must draw the same pixels afterwards as before it.
import h3d.mat.Texture;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import haxe.ui.components.Canvas;
import haxe.ui.components.Image;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

class GlContextResetTest extends hxd.App {
    static inline var SIZE = 32;

    var frame = 0;
    var probes:Array<{name:String, x:Int, y:Int}> = [];
    var before:Array<Int>;

    static function fail(msg:String) {
        Sys.println("FAIL: " + msg);
        Sys.exit(1);
    }

    static function bitmap(color:Int):hxd.BitmapData {
        var bmp = new hxd.BitmapData(SIZE, SIZE);
        bmp.fill(0, 0, SIZE, SIZE, color);
        return bmp;
    }

    function place(name:String, c:Component, index:Int) {
        c.left = index * (SIZE + 8);
        c.top = 0;
        c.width = SIZE;
        c.height = SIZE;
        Screen.instance.addComponent(c);
        probes.push({name: name, x: index * (SIZE + 8) + (SIZE >> 1), y: SIZE >> 1});
    }

    override function init() {
        Toolkit.init({root: s2d});

        var gradient = new Box();
        gradient.customStyle.backgroundColor = 0xFF0000;
        gradient.customStyle.backgroundColorEnd = 0x00FF00;
        gradient.customStyle.backgroundGradientStyle = "horizontal";
        place("gradient", gradient, 0);

        var image = new Image();
        image.resource = bitmap(0xFF0000FF);
        place("image", image, 1);

        ToolkitAssets.instance.cacheImage("glContextResetTest", ToolkitAssets.instance.imageInfoFromImageData(bitmap(0xFFFFFF00)));
        var background = new Box();
        background.customStyle.backgroundImage = "glContextResetTest";
        place("background image", background, 2);

        var canvas = new Canvas();
        place("setPixels", canvas, 3);
        haxe.ui.util.Timer.delay(() -> {
            var bytes = haxe.io.Bytes.alloc(SIZE * SIZE * 4);
            for (i in 0...SIZE * SIZE) bytes.setInt32(i * 4, 0xFFFFFF00); // RGBA bytes: cyan (magenta is what heaps draws for a lost texture)
            canvas.componentGraphics.setPixels(bytes);
            bytes.fill(0, bytes.length, 0); // the caller reuses its buffer: the canvas keeps what it was given
        }, 0);
    }

    function capture():Array<Int> {
        var rt = new Texture(engine.width, engine.height, [Target]);
        s2d.drawTo(rt);
        var pixels = rt.capturePixels();
        rt.dispose();
        return [for (p in probes) pixels.getPixel(p.x, p.y) & 0xFFFFFF];
    }

    override function update(dt:Float) {
        frame++;
        switch (frame) {
            case 10:
                before = capture();
                for (i in 0...probes.length) {
                    if (before[i] == 0) fail(probes[i].name + " draws nothing before the reset");
                }
                @:privateAccess engine.onCreate(true);
            case 14:
                var after = capture();
                var failures = [for (i in 0...probes.length) if (after[i] != before[i])
                    probes[i].name + ": 0x" + StringTools.hex(before[i], 6) + " before the reset, 0x" + StringTools.hex(after[i], 6) + " after"];
                if (failures.length > 0) fail(failures.join("; "));
                Sys.println("ok");
                Sys.exit(0);
            default:
        }
    }

    static function main() {
        new GlContextResetTest();
    }
}
