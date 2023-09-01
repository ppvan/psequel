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

namespace Psequel {


    public enum ApplicationStyle {
        SYSTEM = 0,
        LIGHT,
        DARK
    }
    // public string APP_ID = "me.ppvan.Psequel";

    public class Application : Adw.Application {

        /*
         * Static field for easy access in other places.
         * If need to create many application instance (rarely happens) reconsider this approach.
         */
        public static Application app;
        public static Settings settings;
        public static ThreadPool<Worker> background;

        public int color_scheme { get; set; }
        public const int MAX_COLUMNS = 100;

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

            this.set_accels_for_action ("app.new-window", { "<Ctrl><Shift>n" });
            this.set_accels_for_action ("app.quit", { "<primary>q" });
            this.set_accels_for_action ("app.preferences", { "<primary>comma" });

            this.set_accels_for_action ("win.import", { "<Ctrl><Shift>o" });
            this.set_accels_for_action ("win.export", { "<Ctrl><Shift>e" });
            this.set_accels_for_action ("win.run-query", { "<Ctrl>Return" });
        }

        public override void activate () {
            base.activate ();

            var window = new_window ();
            window.present ();
        }

        public override void startup () {
            base.startup ();
            GtkSource.init ();
            set_up_logging ();
            debug ("Begin to load resources");

            Application.app = this;
            Application.settings = new Settings (this.application_id);
            settings.bind ("color-scheme", this, "color_scheme", SettingsBindFlags.GET);
            this.notify["color-scheme"].connect (update_color_scheme);

            try {

                // Don't change the max_thread because libpq did not support many query with 1 connection.
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

        public void update_color_scheme () {
            switch (this.color_scheme) {
            case ApplicationStyle.SYSTEM:
                style_manager.color_scheme = Adw.ColorScheme.DEFAULT;
                break;
            case ApplicationStyle.DARK:
                style_manager.color_scheme = Adw.ColorScheme.FORCE_DARK;
                break;
            case ApplicationStyle.LIGHT:
                style_manager.color_scheme = Adw.ColorScheme.FORCE_LIGHT;
                break;
            default:
                assert_not_reached ();
            }
        }

        public void on_something () {
            debug ("DO something");
            debug ("Dark: %b", style_manager.dark);
            if (style_manager.dark) {
                style_manager.color_scheme = Adw.ColorScheme.FORCE_LIGHT;
            } else {
                style_manager.color_scheme = Adw.ColorScheme.FORCE_DARK;
            }

            // style_manager.dark = !style_manager.dark;
        }

        public static int main (string[] args) {
            ensure_types ();
            var app = new Psequel.Application ();

            return app.run (args);
        }

        /* register needed types, allow me to ref a template inside a template */
        private static void ensure_types () {

            typeof (Psequel.StyleSwitcher).ensure ();
            typeof (Psequel.ConnectionViewModel).ensure ();
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
            typeof (Psequel.ViewDataView).ensure ();
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

            var preference = new PreferencesWindow () {
                transient_for = this.active_window,
                modal = true,
                application = this,
            };

            preference.present ();
        }

        /**
         * Create a window and inject resources.
         *
         * Because child widget is created before window, signals can only be connect when window is init.
         * This result to another event to notify window is ready and widget should setup signals
         */
        private Window new_window () {

            // give temp access because window is not created yet
            Window.temp = create_viewmodels ();
            var window = new Window (this, Window.temp);
            // Window.temp = null;

            return window;
        }

        private Container create_viewmodels () {
            var container = new Container ();

            // services
            var sql_service = new SQLService (Application.background);
            var schema_service = new SchemaService (sql_service);
            var repository = new ConnectionRepository (Application.settings);
            var navigation = new NavigationService ();
            var export = new ExportService ();

            // viewmodels
            var conn_vm = new ConnectionViewModel (repository, sql_service, navigation);
            var sche_vm = new SchemaViewModel (schema_service);
            var table_vm = new TableViewModel (sql_service);
            var view_vm = new ViewViewModel (sql_service);
            var table_structure_vm = new TableStructureViewModel (sql_service);
            var view_structure_vm = new ViewStructureViewModel (sql_service);
            var table_data_vm = new TableDataViewModel (sql_service);
            var view_data_vm = new ViewDataViewModel (sql_service);
            var query_history_vm = new QueryHistoryViewModel (sql_service);
            var query_vm = new QueryViewModel (query_history_vm);

            container.register (sql_service);
            container.register (schema_service);
            container.register (export);
            container.register (repository);
            container.register (navigation);
            container.register (conn_vm);
            container.register (sche_vm);
            container.register (table_vm);
            container.register (view_vm);
            container.register (table_structure_vm);
            container.register (view_structure_vm);
            container.register (table_data_vm);
            container.register (view_data_vm);
            container.register (query_history_vm);
            container.register (query_vm);

            // events
            conn_vm.subcribe (Event.ACTIVE_CONNECTION, sche_vm);

            sche_vm.subcribe (Event.SCHEMA_CHANGED, table_vm);
            sche_vm.subcribe (Event.SCHEMA_CHANGED, view_vm);
            sche_vm.subcribe (Event.SCHEMA_CHANGED, table_structure_vm);
            sche_vm.subcribe (Event.SCHEMA_CHANGED, view_structure_vm);

            table_vm.subcribe (Event.SELECTED_TABLE_CHANGED, table_structure_vm);
            table_vm.subcribe (Event.SELECTED_TABLE_CHANGED, table_data_vm);

            view_vm.subcribe (Event.SELECTED_VIEW_CHANGED, view_structure_vm);
            view_vm.subcribe (Event.SELECTED_VIEW_CHANGED, view_data_vm);


            return container;
        }
    }
}