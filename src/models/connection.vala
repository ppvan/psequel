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
using Gee;

namespace Sequelize {

    public class Connection : Object {

        public static ArrayList<Connection> connections;

        public string name { get; set; default = ""; }
        public string host { get; set; default = ""; }
        public string port { get; set; default = ""; }
        public string user { get; set; default = ""; }
        public string password { get; set; default = ""; }
        public string database { get; set; default = ""; }
        public bool use_ssl { get; set; default = false; }

        public Connection (string name = "New Connection") {
            this._name = name;
        }

        public Postgres.Database connect_db () {

            var db = Postgres.connect_db (this.conninfo ());
            if (db.get_status () == Postgres.ConnectionStatus.OK) {
                int version = db.get_server_version ();
                print ("Postgres version: %d\n", version);

                string query = "SELECT NOW();";
                var results = db.exec (query);
                var now = results.get_value (0, 0);
                print ("Now: %s\n", now);

                //
            } else {
                var err_msg = db.get_error_message ();
                stderr.printf ("%s\n", err_msg);
            }

            return db;
        }

        public string conninfo () {
            var ts = @"host=$host port=$port dbname=$database user=$user password=$password connect_timeout=10";
            return ts.dup ();
        }
    }

    public class ResourceManager : Object {

        /**
         * Recent connections info in last sessions.
         */
        public ObservableArrayList<Connection> recent_connections;


        private static Once<ResourceManager> _instance;

        public static unowned ResourceManager instance () {
            return _instance.once (() => { return new ResourceManager (); });
        }

        private ResourceManager () {
            Object ();
        }
    }
}