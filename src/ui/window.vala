/* window.vala
 *
 * Copyright 2023 Unknown
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using GLib;

namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/window.ui")]
    public class Window : Adw.ApplicationWindow {

        public WindowSignals signals {get; set; default = null;}
        public QueryService query_service {get; set; default = null;}

        public Window (Application app) {
            Object (application: app);
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);

            with (ResourceManager.instance ()) {
                settings.bind ("window-width", this,
                               "default-width", SettingsBindFlags.DEFAULT);
                settings.bind ("window-height", this,
                               "default-height", SettingsBindFlags.DEFAULT);
            }

            setup_signals ();
        }

        private void setup_signals () {
            // signals can only be connected after the window is ready.
            // because widget access window to get signals.
            ResourceManager.instance ().app_signals.window_ready.connect (() => {
                signals.database_connected.connect (() => {
                    navigate_to (Views.QUERY);
                });
            });
        }

        /**
         * Navigate to the stack view.
         */
        public void navigate_to (string view_name) {

            debug ("OK");

            var child = stack.get_child_by_name (view_name);

            if (child == null) {
                warning ("No such view: %s", view_name);
            } else {
                debug ("navigate_to %s", view_name);
                stack.visible_child = child;
            }
        }

        public void add_toast (Adw.Toast toast) {
            overlay.add_toast (toast);
        }

        [GtkChild]
        private unowned Gtk.Stack stack;

        [GtkChild]
        private unowned Adw.ToastOverlay overlay;
    }
}