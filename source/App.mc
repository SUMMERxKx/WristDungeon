// App.mc — WristDungeonApp: entry point, trig table init

import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

using WristDungeon as C;

class WristDungeonApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        _buildTrigTables();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new MenuView();
        var delegate = new MenuDelegate(view);
        return [view, delegate];
    }

    // ── Pre-compute sin/cos lookup tables (0°–359°) ──────────────────────────
    // Stored in C.sinTable / C.cosTable — avoids Math.sin() in the render loop.
    hidden function _buildTrigTables() as Void {
        for (var i = 0; i < 360; i++) {
            var rad = i.toFloat() * Math.PI / 180.0;
            C.sinTable[i] = Math.sin(rad).toFloat();
            C.cosTable[i] = Math.cos(rad).toFloat();
        }
    }

}
