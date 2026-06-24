package haxe.ui.backend;

import h2d.TextInput;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.UIEvent;
import hxd.Event;
import hxd.Key;

class TextInputImpl extends TextDisplayImpl {

    var textInput: TextInput;

    public function new() {
        super();
    }

    private override function createText() {
        textInput = new TextInput(hxd.res.DefaultFont.get());
        textInput.lineBreak = false;
        textInput.onChange = onChange;
        textInput.onClick = function(e) {
            cast(parentComponent, InteractiveComponent).focus = true;
        }
        return textInput;
    }

    // we're actually going to override this function so that it always returns
    // h2d.Text.Align.Left - this is because heaps text input doesnt seem to like
    // center aligned text (or right aligned), for now will simply turn it off
    /*private override function getAlign(align:String):h2d.Text.Align {
        return h2d.Text.Align.Left;
    }*/

    // While a text input is focused at the haxeui level, the underlying h2d.TextInput must hold the heaps scene
    // focus (h2d.SceneEvents.currentFocus) so that ETextInput (character) events are routed to it. A single
    // deferred textInput.focus() is fragile: it can land on a frame before the input is laid out / in the scene,
    // and a later stray EPush elsewhere blurs the scene focus without the haxeui side knowing. So we record the
    // wanted-focus state and re-assert it every frame (via a recurring Timer, driven by the same backend update
    // tick as all timers) until the input is blurred, keeping the haxeui<->heaps focus binding in sync.
    static var focusedInputs:Array<TextInputImpl> = [];
    static var focusTimer:haxe.ui.util.Timer = null;
    var wantsFocus:Bool = false;

    public override function focus() {
        wantsFocus = true;
        if (focusedInputs.indexOf(this) == -1) {
            focusedInputs.push(this);
        }
        startFocusTimer();
        reconcileFocus();
    }

    public override function blur() {
        unregisterFocus();
        @:privateAccess textInput.interactive.blur();
    }

    // haxeui-core tears a component down via Component.disposeComponent() -> getTextInput().dispose() WITHOUT
    // blurring it first, so a field destroyed while focused would otherwise stay in focusedInputs forever and
    // keep the shared per-frame focusTimer running. Release the focus state here too. (The base
    // TextBase.dispose() only nulls parentComponent, so super.dispose() must still run.)
    public override function dispose() {
        unregisterFocus();
        super.dispose();
    }

    // Clear this input's wanted-focus state and stop the shared reconcile timer once nothing wants focus.
    // Shared by blur() (normal defocus) and dispose() (component torn down while focused).
    private function unregisterFocus() {
        wantsFocus = false;
        focusedInputs.remove(this);
        if (focusedInputs.length == 0 && focusTimer != null) {
            focusTimer.stop();
            focusTimer = null;
        }
    }

    // A single recurring (per-frame) reconcile that re-asserts scene focus for every input that still wants it; it
    // runs only while at least one input is focused, and is stopped on the last blur. Driven by the same backend
    // update tick as all haxeui timers, so no other backend wiring is needed.
    private static function startFocusTimer() {
        if (focusTimer != null) {
            return;
        }
        focusTimer = new haxe.ui.util.Timer(0, function() {
            for (input in focusedInputs.copy()) {
                input.reconcileFocus();
            }
        });
    }

    // Ensure the underlying h2d.TextInput holds the heaps scene focus while this input wants focus. A no-op when
    // it already is the scene focus, or until it has been added to a scene (events system), so the binding
    // self-heals after a dropped focus or a stray blur instead of silently dropping character input.
    private function reconcileFocus() {
        if (!wantsFocus || textInput.getScene() == null) {
            return;
        }
        if (!textInput.hasFocus()) {
            textInput.focus();
        }
    }

    private function onChange() {
        _text = textInput.text;
        _htmlText = textInput.text;
        
        measureText();
        
        if (_inputData.onChangedCallback != null) {
            _inputData.onChangedCallback();
        }
        
        if (parentComponent != null) {
            parentComponent.dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }

    private override function validateDisplay() {
        super.validateDisplay();
        
        textInput.inputWidth = Math.round(textInput.maxWidth); // clip text input display to text component's width
    }

    private override function resizeFont(fontSizeValue:Int, isBitmap:Bool) {
        var temp = sprite.font.clone();
        if (isBitmap) {
            temp.resizeTo(-fontSizeValue);
        } else {
            if (temp == hxd.res.DefaultFont.get()) {
                temp = hxd.res.DefaultFont.get().clone();
            }
            temp.resizeTo(fontSizeValue);
        }
        sprite.font = temp;
        temp = null;
    }

    private override function validateStyle():Bool {
        var measureTextRequired:Bool = super.validateStyle();

        if ( _inputData.password) {
            trace("TextInput password mode isn't supported in Heaps.");
            _inputData.password = false; 
        }

        if (parentComponent.disabled) {
            textInput.canEdit = false;
        } else {
            textInput.canEdit = true;
        }
        
        return measureTextRequired;
    }
    
    private var _onKeyDown:KeyboardEvent->Void = null;
    public var onKeyDown(null, set):KeyboardEvent->Void;
    private function set_onKeyDown(value:KeyboardEvent->Void):KeyboardEvent->Void {
        _onKeyDown = value;
        if (_onKeyDown == null && _onKeyUp == null && _onKeyPress == null) {
            unregisterInernalEvents();
            return value;
        }
        registerInternalEvents();
        return value;
    }

    private var _onKeyUp:KeyboardEvent->Void = null;
    public var onKeyUp(null, set):KeyboardEvent->Void;
    private function set_onKeyUp(value:KeyboardEvent->Void):KeyboardEvent->Void {
        _onKeyUp = value;
        if (_onKeyDown == null && _onKeyUp == null && _onKeyPress == null) {
            unregisterInernalEvents();
            return value;
        }
        registerInternalEvents();
        return value;
    }

    private var _onKeyPress:KeyboardEvent->Void = null;
    public var onKeyPress(null, set):KeyboardEvent->Void;
    private function set_onKeyPress(value:KeyboardEvent->Void):KeyboardEvent->Void {
        _onKeyPress = value;
        if (_onKeyDown == null && _onKeyUp == null && _onKeyPress == null) {
            unregisterInernalEvents();
            return value;
        }
        registerInternalEvents();
        return value;
    }

    private var _internalEventsRegistered = false;
    private function registerInternalEvents() {
        if (_internalEventsRegistered) {
            return;
        }
        _internalEventsRegistered = true;
        textInput.onKeyDown = onKeyDownInternal;
        textInput.onKeyUp = onKeyUpInternal;
    }

    // heaps doesnt have a keypress event, so we'll hold onto down keys in order to dispatch the press event
    private var _downKeys:Map<Int, Bool> = new Map<Int, Bool>();
    private function unregisterInernalEvents() {
        textInput.onKeyDown = null;
        textInput.onKeyUp = null;
        _internalEventsRegistered = false;
    }

    private function onKeyDownInternal(e:Event) {
        _downKeys.set(e.keyCode, true);
        dispatchEvent(KeyboardEvent.KEY_DOWN, e.keyCode);
    }

    private function onKeyUpInternal(e:Event) {
        var hadDownKey = (_downKeys.exists(e.keyCode) && _downKeys.get(e.keyCode) == true);
        _downKeys.remove(e.keyCode);
        dispatchEvent(KeyboardEvent.KEY_UP, e.keyCode);
        if (hadDownKey) {
            dispatchEvent(KeyboardEvent.KEY_PRESS, e.keyCode);
        }
    }

    private function dispatchEvent(type:String, keyCode:Int) {
        var event = new KeyboardEvent(type);
        event.keyCode = keyCode;
        event.altKey = Key.isDown(Key.ALT);
        event.shiftKey = Key.isDown(Key.SHIFT);
        event.ctrlKey = Key.isDown(Key.CTRL); 
        switch (type) {
            case KeyboardEvent.KEY_DOWN:
                if (_onKeyDown != null) {
                    _onKeyDown(event);
                }
            case KeyboardEvent.KEY_UP:
                if (_onKeyUp != null) {
                    _onKeyUp(event);
                }
            case KeyboardEvent.KEY_PRESS:
                if (_onKeyPress != null) {
                    _onKeyPress(event);
                }
        }
    }
}