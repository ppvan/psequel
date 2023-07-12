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

    public class Connection : Object, Json.Serializable {

        // public static ArrayList<Connection> connections;
        public const string DEFAULT = "";

        public string name { get; set; default = DEFAULT; }
        public string host { get; set; default = DEFAULT; }
        public string port { get; set; default = DEFAULT; }
        public string user { get; set; default = DEFAULT; }
        public string password { get; set; default = DEFAULT; }
        public string database { get; set; default = DEFAULT; }
        public bool use_ssl { get; set; default = false; }


        public Connection (string name = "New Connection") {
            this._name = name;
        }

        public Postgres.Database connect_db () {

            var conn_info = this.build_conninfo ();
            var db = Postgres.connect_db (conn_info);

            print ("%s\n", conn_info);

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

        public string build_conninfo () {
            var builder = new StringBuilder ();
            if (host != DEFAULT) {
                builder.append (@"host=$host");
            } else {
                builder.append ("host=localhost");
            }

            builder.append (" ");

            if (port != DEFAULT) {
                builder.append (@"port=$port");
            } else {
                builder.append ("port=5432");
            }

            builder.append (" ");

            if (database != DEFAULT) {
                builder.append (@"dbname=$database");
            } else {
                builder.append ("dbname=postgres");
            }

            builder.append (" ");

            if (user != DEFAULT) {
                builder.append (@"user=$user");
            } else {
                builder.append ("user=postgres");
            }

            builder.append (" ");

            if (password != DEFAULT) {
                builder.append (@"password=$password");
            } else {
                builder.append ("password=''");
            }

            return builder.free_and_steal ();
        }

        /**
         * Convert connection to JSON string.
         */
        // public string stringify () {
        //// var Json.Bui
        // }
    }

    public class ResourceManager : Object {

        /**
         * Recent connections info in last sessions.
         */
        public ObservableArrayList<Connection> recent_connections { get; set; }

        /**
         * Application setting.
         */
        public Settings settings { get; set; }

        public string serialize_data {
            get;
            set;
        }


        private static Once<ResourceManager> _instance;

        public static unowned ResourceManager instance () {
            return _instance.once (() => { return new ResourceManager (); });
        }

        private ResourceManager () {
            Object ();
        }

        public string stringify (bool pretty = true) {
            var root = build_json ();
            return Json.to_string (root, pretty);
        }

        public void save_user_data () {
            settings.set_string ("data", stringify (false));
        }

        public void load_user_data () {

            print ("Load data\n");

            var parser = new Json.Parser ();
            recent_connections = new ObservableArrayList<Connection> ();

            try {
                var buff = settings.get_string ("data");
                parser.load_from_data (buff);
                var root = parser.get_root ();
                var obj = root.get_object ();
                var conns = obj.get_array_member ("recent_connections");

                conns.foreach_element ((array, index, node) => {
                    var conn = (Connection) Json.gobject_deserialize (typeof (Connection), node);
                    recent_connections.add (conn);
                });

                print (root.type_name ());
            } catch (Error err) {
                debug (err.message);
            }
        }

        /**
         * Load all resource from file.
         * If path is not exist or error, default everything like new install.
         * Because this can't violate singleton, it will init the properties data only.
         */
        public void load_from_file (string file_path) {
        }

        private Json.Node build_json () {
            var builder = new Json.Builder ();
            builder.begin_object ();
            builder.set_member_name ("recent_connections");
            builder.begin_array ();

            foreach (var conn in recent_connections) {
                builder.add_value (Json.gobject_serialize (conn));
            }

            builder.end_array ();
            builder.end_object ();

            return builder.get_root ();
        }
    }
}