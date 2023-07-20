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

namespace Psequel {

    // public string APP_ID = "me.ppvan.Psequel";

    public class Application : Adw.Application {

        public Application () {
            Object (application_id: "me.ppvan.psequel", flags: ApplicationFlags.DEFAULT_FLAGS);
        }

        public override void activate () {
            base.activate ();
            var win = this.active_window;
            if (win == null) {
                win = new Psequel.Window (this);
            }
            win.present ();
        }

        public override void startup () {
            base.startup ();
            set_up_logging ();
            debug ("Begin to load resources");

            // Load recent connections
            with (ResourceManager.instance ()) {
                app = this;
                settings = new Settings (this.application_id);

                try {
                    background = new ThreadPool<Worker>.with_owned_data ((worker) => {
                        worker.run ();
                    }, ResourceManager.POOL_SIZE, false);
                } catch (ThreadError err) {
                    debug (err.message);
                    return_if_reached ();
                }

                query_service = new QueryService (background);
                table_list = new ObservableArrayList<Relation.Row> ();
                signals = new AppSignals ();

                load_user_data ();
            };

            debug ("Resources loaded");
        }

        public override void shutdown () {
            debug ("Saving resources");

            with (ResourceManager.instance ()) {
                save_user_data ();
            };

            debug ("Resources saved");

            base.shutdown ();
        }

        public static int main (string[] args) {
            ensure_types ();
            var app = new Psequel.Application ();

            return app.run (args);
        }

        /* register needed types, allow me to ref a template inside a template */
        private static void ensure_types () {
            typeof (Psequel.ConnectionView).ensure ();
            typeof (Psequel.ConnectionSidebar).ensure ();
            typeof (Psequel.ConnectionForm).ensure ();
            typeof (Psequel.QueryView).ensure ();
            typeof (Psequel.TableStructure).ensure ();
            typeof (Psequel.TableData).ensure ();
        }
    }
}