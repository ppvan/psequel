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

        public static Container? temp;
        public Container containter { get; construct; }

        const ActionEntry[] ACTIONS = {
            { "import", import_connection },
            { "export", export_connection },

            { "run-query", run_query },
        };

        public NavigationService navigation { get; private set; }
        public ConnectionViewModel connection_viewmodel { get; construct; }
        public QueryViewModel query_viewmodel { get; private set; }


        public Window (Application app, Container container) {
            Object (
                    application: app,
                    containter: container
            );
        }

        construct {
            this.navigation = autowire<NavigationService> ();
            this.connection_viewmodel = autowire<ConnectionViewModel> ();
            this.query_viewmodel = autowire<QueryViewModel> ();

            debug ("[CONTRUCT] %s", this.name);
            Application.settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
            Application.settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
            this.add_action_entries (ACTIONS, this);
        }

        public void add_toast (Adw.Toast toast) {
            overlay.add_toast (toast);
        }

        // Actions:
        public void run_query () {
            if (query_viewmodel == null) {
                return;
            }

            query_viewmodel.run_selected_query.begin ();
        }

        public void import_connection () {
            open_file_dialog.begin ("Import connections");
        }

        public void export_connection () {
            save_file_dialog.begin ("Export connections");
        }

        private async void open_file_dialog (string title = "Open File") {
            var filter = new Gtk.FileFilter ();
            filter.add_pattern ("*.json");

            var filters = new ListStore (typeof (Gtk.FileFilter));
            filters.append (filter);

            var window = (Window) get_parrent_window (this);

            var file_dialog = new Gtk.FileDialog () {
                modal = true,
                initial_folder = File.new_for_path (Environment.get_home_dir ()),
                title = title,
                initial_name = "connections",
                default_filter = filter,
                filters = filters
            };

            uint8[] contents;

            try {
                var file = yield file_dialog.open (window, null);

                yield file.load_contents_async (null, out contents, null);

                var json_str = (string) contents;
                var conns = ValueConverter.deserialize_connection (json_str);
                connection_viewmodel.import_connections (conns);

                var toast = new Adw.Toast (@"Loaded $(conns.length ()) connections") {
                    timeout = 3,
                };
                window.add_toast (toast);
            } catch (Error err) {
                debug (err.message);

                var toast = new Adw.Toast (err.message) {
                    timeout = 3,
                };
                window.add_toast (toast);
            }
        }

        private async void save_file_dialog (string title = "Save to file") {

            var filter = new Gtk.FileFilter ();
            filter.add_suffix ("json");

            var filters = new ListStore (typeof (Gtk.FileFilter));
            filters.append (filter);

            var file_dialog = new Gtk.FileDialog () {
                modal = true,
                initial_folder = File.new_for_path (Environment.get_home_dir ()),
                title = title,
                initial_name = "connections",
                default_filter = filter,
                filters = filters,
            };

            unowned var conns = connection_viewmodel.export_connections ();
            var content = ValueConverter.serialize_connection (conns);
            var bytes = new Bytes.take (content.data);  // Move data to byte so it live when out scope
            var window = (Window) get_parrent_window (this);

            try {
                var file = yield file_dialog.save (window, null);

                yield file.replace_contents_bytes_async (bytes, null, false, FileCreateFlags.NONE, null, null);

                var toast = new Adw.Toast ("Data saved successfully.") {
                    timeout = 2,
                };
                window.add_toast (toast);
            } catch (Error err) {
                debug (err.message);

                var toast = new Adw.Toast (err.message) {
                    timeout = 3,
                };
                window.add_toast (toast);
            }
        }

        [GtkChild]
        private unowned Adw.ToastOverlay overlay;
    }
}