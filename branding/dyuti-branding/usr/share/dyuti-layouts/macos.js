/* macOS Style layout — a thin top bar (menu, tray, clock) plus a bottom dock.
 * Approximates the macOS feel for users who prefer it.
 */
var all = panels();
for (var i = 0; i < all.length; i++) { all[i].remove(); }

// --- top bar -----------------------------------------------------------------
var top = new Panel;
top.location = "top";
top.height = Math.round(gridUnit * 1.6);

var launcher = top.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "dyuti-logo");

// Global menu of the active window (falls back gracefully if unavailable).
top.addWidget("org.kde.plasma.appmenu");

top.addWidget("org.kde.plasma.marginsseparator");
top.addWidget("org.kde.plasma.systemtray");

var topClock = top.addWidget("org.kde.plasma.digitalclock");
topClock.currentConfigGroup = ["Appearance"];
topClock.writeConfig("showDate", true);

// --- bottom dock -------------------------------------------------------------
var dock = new Panel;
dock.location = "bottom";
dock.height = Math.round(gridUnit * 3.2);
dock.addWidget("org.kde.plasma.icontasks");
