package discord.utils.events;

/**
 * This batch of classes is from
 * https://github.com/openfl/openfl-native/blob/master/flash/events/EventDispatcher.hx
 * 
 * It is worth noting this class has zero references to `openfl.utils.WeakRef`, 
 * so *Weak references* don't work here.
 */

typedef Function = Dynamic->Void;

interface IEventDispatcher {
	public function addEventListener(type:String, listener:Function, useCapture:Bool = false, priority:Int = 0):Void;
	public function dispatchEvent(event:Event):Bool;
	public function hasEventListener(type:String):Bool;
	public function removeEventListener(type:String, listener:Function, useCapture:Bool = false):Void;
	public function willTrigger(type:String):Bool;
}

enum EventPhase {
	CAPTURING_PHASE;
	AT_TARGET;
	BUBBLING_PHASE;
}

class EventDispatcher implements IEventDispatcher {
	@:noCompletion private var __eventMap:EventMap;
	@:noCompletion private var __target:IEventDispatcher;

	public function new(target:IEventDispatcher = null):Void {
		__target = (target == null ? this : target);
		__eventMap = null;
	}

	public function addEventListener(type:String, listener:Function, useCapture:Bool = false, priority:Int = 0):Void {
		if (__eventMap == null) {
			__eventMap = new EventMap();
		}

		var list = __eventMap.get(type);

		if (list == null) {
			list = new ListenerList();
			__eventMap.set(type, list);
		}

		list.push(new Listener(listener, useCapture, priority));
		list.sort(__sortEvents);
	}

	public function dispatchEvent(event:Event):Bool {
		if (__eventMap == null) {
			return false;
		}

		if (event.target == null) {
			event.target = __target;
		}

		if (event.currentTarget == null) {
			event.currentTarget = __target;
		}

		var list = __eventMap.get(event.type);
		var capture = (event.eventPhase == EventPhase.CAPTURING_PHASE);

		if (list != null) {
			var index = 0;
			var length = list.length;

			var listItem, listener;

			while (index < length) {
				listItem = list[index];
				listener = ((listItem != null && listItem.listener != null) ? listItem : null);

				if (listener == null) {
					list.splice(index, 1);
					length--;
				} else {
					if (listener.useCapture == capture) {
						listener.dispatchEvent(event);

						if (event.__getIsCancelledNow()) {
							return true;
						}
					}

					index++;
				}
			}

			return true;
		}

		return false;
	}

	public function hasEventListener(type:String):Bool {
		if (__eventMap == null) {
			return false;
		}

		var list = __eventMap.get(type);

		if (list != null) {
			for (item in list) {
				if (item != null)
					return true;
			}
		}

		return false;
	}

	public function removeEventListener(type:String, listener:Function, capture:Bool = false):Void {
		if (__eventMap == null || !__eventMap.exists(type)) {
			return;
		}

		var list = __eventMap.get(type);
		var item;

		for (i in 0...list.length) {
			if (list[i] != null) {
				item = list[i];
				if (item != null && item.is(listener)) {
					list[i] = null;
					return;
				}
			}
		}
	}

	public function toString():String {
		return "[object " + Type.getClassName(Type.getClass(this)) + "]";
	}

	public function willTrigger(type:String):Bool {
		if (__eventMap == null) {
			return false;
		}
		return __eventMap.exists(type);
	}

	@:noCompletion public function __dispatchCompleteEvent():Void {
		dispatchEvent(new Event(Event.COMPLETE));
	}

	@:noCompletion private static inline function __sortEvents(a:Listener, b:Listener):Int {
		if (a == null || b == null) {
			return 0;
		}

		var al = a;
		var bl = b;

		if (al == null || bl == null) {
			return 0;
		}

		if (al.priority == bl.priority) {
			return al.id == bl.id ? 0 : (al.id > bl.id ? 1 : -1);
		} else {
			return al.priority < bl.priority ? 1 : -1;
		}
	}
}

class Listener {
	public var id:Int;
	public var listener:Function;
	public var priority:Int;
	public var useCapture:Bool;

	private static var __id = 1;

	public function new(listener:Function, useCapture:Bool, priority:Int) {
		this.listener = listener;
		this.useCapture = useCapture;
		this.priority = priority;
		id = __id++;
	}

	public function dispatchEvent(event:Event):Void {
		listener(event);
	}

	public function is(listener:Function) {
		return this.listener == listener;
	}
}

class Event {
	public static var COMPLETE = "complete";

	public var bubbles(get, never):Bool;
	public var cancelable(get, never):Bool;
	public var currentTarget(get, set):Dynamic;
	public var eventPhase(get, never):EventPhase;
	public var target(get, set):Dynamic;
	public var type(get, never):String;

	@:noCompletion private var __bubbles:Bool;
	@:noCompletion private var __cancelable:Bool;
	@:noCompletion private var __currentTarget:Dynamic;
	@:noCompletion private var __eventPhase:EventPhase;
	@:noCompletion private var __isCancelled:Bool;
	@:noCompletion private var __isCancelledNow:Bool;
	@:noCompletion private var __target:Dynamic;
	@:noCompletion private var __type:String;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		__type = type;
		__bubbles = bubbles;
		__cancelable = cancelable;
		__isCancelled = false;
		__isCancelledNow = false;
		__target = null;
		__currentTarget = null;
		__eventPhase = EventPhase.AT_TARGET;
	}

	public function clone():Event {
		return new Event(type, bubbles, cancelable);
	}

	public function isDefaultPrevented():Bool {
		return (__isCancelled || __isCancelledNow);
	}

	public function stopImmediatePropagation():Void {
		if (cancelable) {
			__isCancelled = true;
			__isCancelledNow = true;
		}
	}

	public function stopPropagation():Void {
		if (cancelable) {
			__isCancelled = true;
		}
	}

	public function toString():String {
		return "[Event type=" + type + " bubbles=" + bubbles + " cancelable=" + cancelable + "]";
	}

	@:noCompletion public function __getIsCancelled():Bool {
		return __isCancelled;
	}

	@:noCompletion public function __getIsCancelledNow():Bool {
		return __isCancelledNow;
	}

	@:noCompletion public function __setPhase(value:EventPhase):Void {
		__eventPhase = value;
	}

	// Getters & Setters
	private function get_bubbles():Bool {
		return __bubbles;
	}

	private function get_cancelable():Bool {
		return __cancelable;
	}

	private function get_currentTarget():Dynamic {
		return __currentTarget;
	}

	private function set_currentTarget(value:Dynamic):Dynamic {
		return __currentTarget = value;
	}

	private function get_eventPhase():EventPhase {
		return __eventPhase;
	}

	private function get_target():Dynamic {
		return __target;
	}

	private function set_target(value:Dynamic):Dynamic {
		return __target = value;
	}

	private function get_type():String {
		return __type;
	}
}

typedef ListenerList = Array<Listener>;
typedef EventMap = haxe.ds.StringMap<ListenerList>;
