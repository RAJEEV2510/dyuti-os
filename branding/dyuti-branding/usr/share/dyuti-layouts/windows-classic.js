/* Windows Classic layout — Start menu bottom-left, task list, tray + clock right.
 * The most familiar layout for users migrating from Windows 7/10.
 */
var all = panels();
for (var i = 0; i < all.length; i++) { all[i].remove(); }

var panel = new Panel;
panel.location = "bottom";
panel.height = Math.round(gridUnit * 2.4);

var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "dyuti-logo");

panel.addWidget("org.kde.plasma.icontasks");

// Spacer pushes the tray + clock to the right edge.
panel.addWidget("org.kde.plasma.marginsseparator");

panel.addWidget("org.kde.plasma.systemtray");

var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);

panel.addWidget("org.kde.plasma.showdesktop");
