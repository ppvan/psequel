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


        public ConnectionViewModel connection_viewmodel {get; construct;}
        public QueryViewModel query_viewmodel {get; construct;}
        public SchemaViewModel schema_viewmodel {get; construct;}


        public Window (Application app, ConnectionViewModel conn_vm, SchemaViewModel schema_vm, QueryViewModel query_viewmodel) {
            Object (
                application: app,
                connection_viewmodel: conn_vm,
                schema_viewmodel: schema_vm,
                query_viewmodel: query_viewmodel
            );
        }

        construct {
            debug ("[CONTRUCT] %s", this.name);

            with (ResourceManager.instance ()) {
                settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
                settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
            }

            navigate_to (BaseViewModel.CONNECTION_VIEW);

            connection_viewmodel.navigate_to.connect (navigate_to);
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

        [GtkCallback]
        public async void on_connect_db (Connection conn) {
            debug ("Window connect");
            connection_viewmodel.is_connectting = true;
            try {
                yield schema_viewmodel.connect_db (conn);
                navigate_to (BaseViewModel.QUERY_VIEW);
            } catch (PsequelError err) {
                create_dialog ("Connection Error", err.message).present ();
            }

            connection_viewmodel.is_connectting = false;
        }

        [GtkCallback]
        public void on_request_logout () {
            navigate_to (BaseViewModel.CONNECTION_VIEW);
        }

        [GtkChild]
        private unowned Gtk.Stack stack;

        [GtkChild]
        private unowned Adw.ToastOverlay overlay;
    }
}