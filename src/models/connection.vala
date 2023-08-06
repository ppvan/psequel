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

namespace Psequel {

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

            builder.append (host != DEFAULT ? host : "127.0.0.1");
            builder.append (port != DEFAULT ? @":$port" : ":5432");
            builder.append (database != DEFAULT ? @"/$database" : "/postgres");
            builder.append (use_ssl ? "?sslmode=require" : "?sslmode=disable");


            return builder.free_and_steal ();
        }

        /**
         * Convert connection to JSON string.
         */
        public Connection clone () {
            return (Connection)Json.gobject_deserialize (typeof (Connection), Json.gobject_serialize (this));
        }

        public static Connection? deserialize (string json) {

            try {
                var conn = (Connection)Json.gobject_from_data (typeof (Connection), json);

                return conn;
            } catch (Error err) {
                debug (err.message);

                return null;
            }
        }

        public static string serialize (Connection conn) {
            return Json.gobject_to_data (conn, null);
        }

    }

}