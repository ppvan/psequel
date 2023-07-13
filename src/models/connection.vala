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

    /**
     * Connection info. Have basic infomation to establish a connection to server.
     */
    public class Connection : Object, Json.Serializable {

        public const string DEFAULT = "";

        public string name { get; set; default = DEFAULT; }
        public string host { get; set; default = DEFAULT; }
        public string port { get; set; default = DEFAULT; }
        public string user { get; set; default = DEFAULT; }
        public string password { get; set; default = DEFAULT; }
        public string database { get; set; default = DEFAULT; }
        public bool use_ssl { get; set; default = false; }


        public Postgres.Database db;

        public Connection (string name = "New Connection") {
            this._name = name;
        }

        /**
         * build the postgres url form properties.
         *
         * Format = postgresql://[user[:password]@][host][:port][/dbname][?param1=value1&...]
         */
        public string url_form () {
            // postgresql://[user[:password]@][host][:port][/dbname][?param1=value1&...]
            var builder = new StringBuilder ("postgres://");
            if (user != DEFAULT) {
                builder.append (user);
                if (password != DEFAULT) {
                    builder.append (@":$password@");
                } else {
                    builder.append ("@");
                }
            }

            if (host != DEFAULT) {
                builder.append (host);
            }

            if (port != DEFAULT) {
                builder.append (@":$port");
            }

            if (database != DEFAULT) {
                builder.append (@"/$database");
            }

            if (use_ssl) {
                builder.append ("?sslmode=require");
            } else {
                builder.append ("?sslmode=disable");
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

    /**
     * Keep and give access to every service in application.
     * Must be initzalize before the UI class.
     */
    public class ResourceManager : Object {

        /**
         * Recent connections info in last sessions.
         */
        public ObservableArrayList<Connection> recent_connections { get; set; }

        public QueryService query_service {get; set;}

        public const int POOL_SIZE = 3;
        public ThreadPool<Worker> background;

        public Postgres.Database active_db { get; owned set; }
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

        /**
         * Load all resource from Gsetting.
         * Because this can't violate singleton, it will init the properties data only.
         */
        public void load_user_data () {
            debug ("Load user setting data");
            //  log_structured ("[debug]", LogLevelFlags.LEVEL_DEBUG, "");
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
            } catch (Error err) {
                debug (err.message);
            }

            debug ("User setting loaded");
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