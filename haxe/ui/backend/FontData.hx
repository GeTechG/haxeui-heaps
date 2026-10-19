package haxe.ui.backend;

#if haxeui_heaps_no_image_decode
typedef FontData = h2d.Font;
#else
typedef FontData = hxd.res.BitmapFont;
#end