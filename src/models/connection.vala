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

namespace Sequelize.Models {

    public class Connection : Object {
        private string error;

        public string name { get; set; default = ""; }
        public string host { get; set; default = "localhost"; }
        public string port { get; set; default = "5432"; }
        public string user { get; set; default = "postgres"; }
        public string password { get; set; default = ""; }
        public string database { get; set; default = ""; }
        public bool use_ssl { get; set; default = false; }

        public Connection () {
            this.error = "";
        }

        private void require (string field, string msg) {

            if (field.length == 0 && this.error.length == 0) {
                this.error = msg;
            }
        }

        public bool valid () {
            this.error = "";
            require (name, "Connection name required.");
            require (host, "Host required.");
            require (user, "Username required.");

            return this.error == "";
        }

        public string get_error () {
            return this.error;
        }

        public void to_string () {
            stdout.printf (
                           "Name: '%s'\nHost: '%s'\nPort: %s\nUser: '%s'\nPassword: '%s'\nDatabase: '%s'\n",
                           name, host, port, user, password, database
            );
        }
    }
}