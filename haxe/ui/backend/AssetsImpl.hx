package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import hxd.Res;
#if !haxeui_heaps_no_image_decode
import hxd.fs.BytesFileSystem.BytesFileEntry;
import hxd.res.Image;
#end

class AssetsImpl extends AssetsBase { 
    #if haxeui_heaps_no_image_decode
    /** Decodes image bytes (PNG, JPEG...) for the backend, which links no decoder under `haxeui_heaps_no_image_decode`. Unset: images load as `null`. */
    public static var decodeImage:(bytes:Bytes, callback:haxe.ui.assets.ImageInfo->Void)->Void = null;
    /** Supplies the font of a resource id under `haxeui_heaps_no_image_decode`. Unset: fonts load as `null`. */
    public static var loadFont:(resourceId:String, callback:h2d.Font->Void)->Void = null;
    #end

    /** The font of a text without a font of its own; under `haxeui_heaps_no_image_decode`, the one the host stored in the `hxd.res.DefaultFont` slot of the engine's resource cache. */
    public static function defaultFont():h2d.Font {
        #if haxeui_heaps_no_image_decode
        var font:h2d.Font = @:privateAccess h3d.Engine.getCurrent().resCache.get(hxd.res.DefaultFont);
        if (font == null) {
            throw "haxeui_heaps_no_image_decode: no default font, store one with h3d.Engine.getCurrent().resCache.set(hxd.res.DefaultFont, font)";
        }
        return font;
        #else
        return hxd.res.DefaultFont.get();
        #end
    }

    public function embedFontSupported():Bool {
        return #if (lime || flash || js) true #else false #end;
    }

    private override function getImageInternal(resourceId:String, callback:haxe.ui.assets.ImageInfo->Void) {
        try {
            var loader:hxd.res.Loader = hxd.Res.loader;
            if (loader != null) {
                if (loader.exists(resourceId)) {
                    #if haxeui_heaps_no_image_decode
                    imageFromBytes(loader.load(resourceId).entry.getBytes(), callback);
                    #else
                    var image:Image = loader.load(resourceId).toImage();
                    var size:Dynamic = image.getSize();
                    var imageInfo:haxe.ui.assets.ImageInfo = {
                        width: size.width,
                        height: size.height,
                        data: image.toBitmap()
                    };
                    callback(imageInfo);
                    #end
                } else {
                    callback(null);
                }
            } else {
                callback(null);
            }
        } catch (e:Dynamic) {
            trace(e);
            callback(null);
        }
    }

    private override function getImageFromHaxeResource(resourceId:String, callback:String->haxe.ui.assets.ImageInfo->Void) {
        var bytes = Resource.getBytes(resourceId);
        imageFromBytes(bytes, function(imageInfo) {
            callback(resourceId, imageInfo);
        });
    }

    public override function imageFromBytes(bytes:Bytes, callback:haxe.ui.assets.ImageInfo->Void) {
        if (bytes == null) {
            callback(null);
            return;
        }

        #if haxeui_heaps_no_image_decode
        if (decodeImage == null) {
            callback(null);
        } else {
            decodeImage(bytes, callback);
        }
        #else
        try {
            var entry:BytesFileEntry = new BytesFileEntry("", bytes);
            var image:Image = new Image(entry);

            var size:Dynamic = image.getSize();
            var imageInfo:haxe.ui.assets.ImageInfo = {
                width: size.width,
                height: size.height,
                data: image.toBitmap()
            };
            callback(imageInfo);
        } catch (e:Dynamic) {
            callback(null);
        }
        #end
    }

    public override function imageInfoFromImageData(imageData:ImageData):haxe.ui.assets.ImageInfo {
        var imageInfo:haxe.ui.assets.ImageInfo = {
            width: imageData.width,
            height: imageData.height,
            data: imageData
        };
        return imageInfo;
    }
    
    private override function getFontInternal(resourceId:String, callback:FontInfo->Void) {
        #if haxeui_heaps_no_image_decode
        if (loadFont == null) {
            callback(null);
            return;
        }
        loadFont(resourceId, function(font) {
            callback(font == null ? null : {
                name: resourceId,
                data: font
            });
        });
        #else
        try {
            var font = hxd.Res.loader.loadCache(resourceId, hxd.res.BitmapFont);
            callback({
                name: resourceId,
                data: font
            });
        } catch (error:Dynamic) {
            #if debug
            trace("WARNING: problem loading font '" + resourceId + "' (" + error + ")");
            #end
            callback(null);
        }
        #end
    }
}
