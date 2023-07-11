/* application.vala
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

using Gee;

namespace Sequelize {

    // public string APP_ID = "me.ppvan.sequelize";

    public class Application : Adw.Application {

        public Application () {
            Object (application_id: "me.ppvan.sequelize", flags: ApplicationFlags.DEFAULT_FLAGS);
        }

        public override void activate () {
            base.activate ();

            var win = this.active_window;
            if (win == null) {
                win = new Sequelize.Window (this);
            }
            win.present ();
        }

        public override void startup () {
            base.startup ();

            // Load recent conns if exists.
            with (ResourceManager.instance ()) {
                recent_connections = new ObservableArrayList<Connection> ();
            };
        }

        public static int main (string[] args) {
            ensure_types ();
            var app = new Sequelize.Application ();

            return app.run (args);
        }

        /* register needed types, allow me to ref a template inside a template */
        private static void ensure_types () {
            typeof (Sequelize.ConnectionView).ensure ();
            typeof (Sequelize.ConnectionSidebar).ensure ();
        }
    }
}