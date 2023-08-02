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

        private AppSignals signals;

        public Window (Application app) {
            Object (application: app);
        }

        construct {
            with (ResourceManager.instance ()) {
                settings.bind ("window-width", this,
                               "default-width", SettingsBindFlags.DEFAULT);
                settings.bind ("window-height", this,
                               "default-height", SettingsBindFlags.DEFAULT);
            }

            this.signals = ResourceManager.instance ().signals;

            signals.database_connected.connect (() => {
                navigate_to (Views.QUERY);
            });
        }

        /**
         * Navigate to the stack view.
         */
        public void navigate_to (string view_name) {
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