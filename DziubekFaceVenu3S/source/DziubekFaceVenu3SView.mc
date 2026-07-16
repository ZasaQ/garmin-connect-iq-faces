import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Activity;

class DziubekFaceVenu3SView extends WatchUi.WatchFace {

    const DAY_NAMES = ["Nd", "Pon", "Wt", "Śr", "Czw", "Pt", "Sob"]; 
    
    var stepsIcon;
    var heartIcon;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        stepsIcon = WatchUi.loadResource(Rez.Drawables.IconBolt);
        heartIcon = WatchUi.loadResource(Rez.Drawables.IconHeart);
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else if (Application.Properties.getValue("UseMilitaryFormat")) {
            timeFormat = "$1$$2$";
            hours = hours.format("%02d");
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        dc.drawText(centerX, height * 0.15, Graphics.FONT_NUMBER_MEDIUM, timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var steps = ActivityMonitor.getInfo().steps;
        if (steps == null) { steps = 0; }
        var stepsText = steps.toString();
        var stepsX = width * 0.05; 
        
        dc.drawText(stepsX, centerY, Graphics.FONT_MEDIUM, stepsText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
        var stepsTextWidth = dc.getTextWidthInPixels(stepsText, Graphics.FONT_MEDIUM);
        var iconStepsX = stepsX + (stepsTextWidth / 2) + 5; 
        var iconStepsY = centerY - 15;
        
        dc.drawBitmap(iconStepsX, iconStepsY, stepsIcon);

        var hr = getHeartRate();
        var hrText = (hr == null) ? "--" : hr.toString();
        var hrX = width * 0.85; 
        
        dc.drawText(hrX, centerY, Graphics.FONT_MEDIUM, hrText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            
        var hrTextWidth = dc.getTextWidthInPixels(hrText, Graphics.FONT_MEDIUM);
        var iconHrX = hrX + (hrTextWidth / 2) + 5;
        var iconHrY = centerY - 15; 
        
        dc.drawBitmap(iconHrX, iconHrY, heartIcon);

        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT); 
        var dayName = DAY_NAMES[now.day_of_week - 1];
        var dateString = Lang.format("$1$, $2$.$3$", [dayName, now.day, now.month]);

        dc.drawText(centerX, height * 0.90, Graphics.FONT_TINY, dateString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function getHeartRate() as Number or Null {
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null && activityInfo.currentHeartRate != null) {
            return activityInfo.currentHeartRate;
        }
        var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
        var sample = hrHistory.next();
        if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            return sample.heartRate;
        }
        return null;
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

}