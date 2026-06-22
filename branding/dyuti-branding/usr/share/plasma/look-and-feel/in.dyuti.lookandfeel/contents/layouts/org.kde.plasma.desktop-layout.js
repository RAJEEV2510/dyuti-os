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
    desktop.writeConfig("Image", "file:///usr/share/backgrounds/dyuti/dyuti-default.svg");
}

var panel = new Panel;
panel.location = "bottom";
panel.height = Math.round(gridUnit * 2.4);

// Application launcher (full-screen menu feels modern; swap to kickoff if preferred)
var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "start-here-kde-symbolic");

// Pinned + running apps
panel.addWidget("org.kde.plasma.icontasks");

// Spacer pushes the tray to the right
panel.addWidget("org.kde.plasma.marginsseparator");

// System tray + clock
panel.addWidget("org.kde.plasma.systemtray");
var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);

// Show-desktop pip at the very end
panel.addWidget("org.kde.plasma.showdesktop");
