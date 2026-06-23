/* Dyuti Modern layout — a clean centered taskbar (Windows 11 feel, our identity).
 * Launcher + task manager are centered; system tray + clock pinned right.
 * Applied by `dyuti-layouts` via the live plasmashell scripting interface.
 */
var all = panels();
for (var i = 0; i < all.length; i++) { all[i].remove(); }

var panel = new Panel;
panel.location = "bottom";
panel.height = Math.round(gridUnit * 2.4);

// Left spacer — pushes the launcher + tasks toward the centre.
panel.addWidget("org.kde.plasma.marginsseparator");

var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "dyuti-logo");

panel.addWidget("org.kde.plasma.icontasks");

// Right spacer — keeps the tray + clock pinned to the far right.
panel.addWidget("org.kde.plasma.marginsseparator");

panel.addWidget("org.kde.plasma.systemtray");

var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);

panel.addWidget("org.kde.plasma.showdesktop");
