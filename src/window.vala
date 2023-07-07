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

namespace Hellowolrd {
    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Gtk.Paned paned;

        [GtkChild]
        private unowned Gtk.Button open_button;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            paned.set_position (200);
            paned.accept_position.connect ((_ok) => {
                print ("Ok");
            });
        }
    }

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/box.ui")]
    public class Box : Gtk.Box {
        [GtkChild]
        private unowned Gtk.Label label;

        public Box () {
        }

        construct {
            print ("Label: %s\n", label.get_label ());
        }
    }
}