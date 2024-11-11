package discord.utils;

class DateTimeDelta {
    public var days:Int;
    public var hours:Int;
    public var minutes:Int;
    public var seconds:Int;

    public function new(?days:Int = 0, ?hours:Int = 0, ?minutes:Int = 0, ?seconds:Int = 0) {
        this.days = days;
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;
        normalize();
    }

    private function normalize():Void {
        // Normalize seconds to minutes
        minutes += Std.int(seconds / 60);
        seconds %= 60;
        
        // Normalize minutes to hours
        hours += Std.int(minutes / 60);
        minutes %= 60;
        
        // Normalize hours to days
        days += Std.int(hours / 24);
        hours %= 24;
    }

    public function toSeconds():Int {
        return seconds + minutes * 60 + hours * 3600 + days * 86400;
    }

    public function add(delta:DateTimeDelta):DateTimeDelta {
        return new DateTimeDelta(
            days + delta.days,
            hours + delta.hours,
            minutes + delta.minutes,
            seconds + delta.seconds
        );
    }

    public function subtract(delta:DateTimeDelta):DateTimeDelta {
        return new DateTimeDelta(
            days - delta.days,
            hours - delta.hours,
            minutes - delta.minutes,
            seconds - delta.seconds
        );
    }

    public function toString():String {
        return '${days} days, ${hours} hours, ${minutes} minutes, ${seconds} seconds';
    }
}
