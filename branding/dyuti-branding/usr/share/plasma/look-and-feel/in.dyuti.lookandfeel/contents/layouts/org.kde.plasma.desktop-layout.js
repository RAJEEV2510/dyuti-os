/* Dyuti default desktop layout.
 * A single clean bottom panel: launcher, task manager, system tray, clock.
 * Familiar for users coming from Windows; tidy enough to feel premium.
 * This runs once on first login to lay out the desktop + panel.
 */

var desktopsList = desktops();
for (var i = 0; i < desktopsList.length; i++) {
    var desktop = desktopsList[i];
    desktop.wallpaperPlugin = "org.kde.image";
    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktop.writeConfig("Image", "file:///usr/share/backgrounds/dyuti/dyuti-mountain.png");
}

var panel = new Panel;
panel.location = "bottom";
panel.height = Math.round(gridUnit * 2.4);

// Keep this layout in lock-step with dyuti-panel-setup (the first-login
// enhancement that runs when a seeded appletsrc exists). This layout.js only
// runs when there is NO appletsrc, so it must produce the same Dyuti panel order:
// launcher, search, task-view, pager, apps, <spacer>, tray, clock, show-desktop.
// Custom plasmoids are guarded so one bad widget can't abort the whole layout.
function add(t) { try { return panel.addWidget(t); } catch (e) { return null; } }

// Application launcher (Kickoff with the Dyuti logo)
var launcher = add("org.kde.plasma.kickoff");
if (launcher) { launcher.currentConfigGroup = ["General"]; launcher.writeConfig("icon", "dyuti-logo"); }

// Inline search box + Task View button (no pager — one desktop by default;
// Task View's "+" adds more on demand)
add("org.dyuti.search");
add("org.dyuti.taskview");

// Pinned + running apps
add("org.kde.plasma.icontasks");

// Expanding spacer pushes the tray to the right
var sp = add("org.kde.plasma.panelspacer");
if (sp) { sp.currentConfigGroup = ["General"]; sp.writeConfig("expanding", true); }

// System tray + clock
add("org.kde.plasma.systemtray");
var clock = add("org.kde.plasma.digitalclock");
if (clock) { clock.currentConfigGroup = ["Appearance"]; clock.writeConfig("showDate", true); }

// Show-desktop pip at the very end
add("org.kde.plasma.showdesktop");
