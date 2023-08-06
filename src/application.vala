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

        /*
         * Static field for easy access in other places.
         * If need to create many application instance (rarely happens) reconsider this approach.
         */
        public static Application app;
        public static Settings settings;
        public static ThreadPool<Worker> background;

        public const int MAX_COLUMNS = 100;

        private PreferencesWindow preference;


        public Application () {
            Object (application_id: "me.ppvan.psequel", flags: ApplicationFlags.DEFAULT_FLAGS);
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "new-window", this.on_new_window },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.quit", { "<primary>q" });
        }

        public override void activate () {
            base.activate ();

            var window = new_window ();
            window.present ();
        }

        public override void startup () {
            base.startup ();
            set_up_logging ();
            debug ("Begin to load resources");

            Application.app = this;
            Application.settings = new Settings (this.application_id);
            try {
                background = new ThreadPool<Worker>.with_owned_data ((worker) => {
                    worker.run ();
                }, 1, false);

            } catch (ThreadError err) {
                debug (err.message);
                return_if_reached ();
            }
            debug ("Resources loaded");
        }

        public override void shutdown () {
            base.shutdown ();
        }

        public static int main (string[] args) {
            ensure_types ();
            GtkSource.init ();
            var app = new Psequel.Application ();

            return app.run (args);
        }

        /* register needed types, allow me to ref a template inside a template */
        private static void ensure_types () {
            typeof (ConnectionViewModel).ensure ();
            typeof (Psequel.SchemaView).ensure ();
            typeof (Psequel.SchemaSidebar).ensure ();
            typeof (Psequel.SchemaMain).ensure ();

            typeof (Psequel.ConnectionRow).ensure ();
            typeof (Psequel.ConnectionView).ensure ();
            typeof (Psequel.ConnectionSidebar).ensure ();
            typeof (Psequel.ConnectionForm).ensure ();
            typeof (Psequel.QueryResults).ensure ();
            typeof (Psequel.QueryEditor).ensure ();
            typeof (Psequel.TableStructureView).ensure ();
            typeof (Psequel.ViewStructureView).ensure ();
            typeof (Psequel.TableDataView).ensure ();
            typeof (Psequel.TableColInfo).ensure ();
            typeof (Psequel.TableIndexInfo).ensure ();
            typeof (Psequel.TableFKInfo).ensure ();
        }

        private void on_about_action () {
            string[] developers = { "ppvan" };

            var about = new Adw.AboutWindow () {
                transient_for = this.get_active_window (),
                application_name = Config.APP_NAME,
                application_icon = Config.APP_ID,
                developer_name = "Phạm Văn Phúc",
                version = Config.VERSION,
                developers = developers,
                copyright = "© 2023 ppvan",
                license_type = Gtk.License.GPL_3_0_ONLY,
                issue_url = "https://github.com/ppvan/psequel/issues",

                developers = {
                    "ppvan https://ppvan.me",
                },
            };

            about.present ();
        }

        private void on_new_window () {
            var window = new_window ();
            window.present ();
        }

        private void on_preferences_action () {

            if (this.preference == null) {
                this.preference = new PreferencesWindow () {
                    transient_for = this.active_window,
                    modal = true,
                    application = this,
                };
            }
            this.preference.present ();
        }

        /**
         * Create a window and inject resources.
         *
         * Because child widget is created before window, signals can only be connect when window is init.
         * This result to another event to notify window is ready and widget should setup signals
         */
        private Window new_window () {

            var query_service = new QueryService (Application.background);
            var repository = new ConnectionRepository (Application.settings);
            var conn_vm = new ConnectionViewModel (repository);
            var sche_vm = new SchemaViewModel (query_service);
            var query_vm = new QueryViewModel (query_service);



            var window = new Window (this, conn_vm, sche_vm, query_vm);

            return window;
        }
    }
}