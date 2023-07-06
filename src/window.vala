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

namespace Hellowolrd {
    [GtkTemplate (ui = "/me/ppvan/helloworld/ui/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Gtk.TextView textviewer;

        [GtkChild]
        private unowned Gtk.Button open_button;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            var open_action = new SimpleAction ("open", null);
            open_action.activate.connect (this.open_action);
            this.add_action (open_action);
        }

        private void open_action (Variant? parameter) {
            var filechooser = new Gtk.FileChooserNative ("Open File", null, Gtk.FileChooserAction.OPEN, "_Open", "_Cancel") {
                transient_for = this
            };
            filechooser.response.connect ((dialog, response) => {
                // If the user selected a file...
                if (response == Gtk.ResponseType.ACCEPT) {
                    // ... retrieve the location from the dialog and open it
                    this.open_file (filechooser.get_file ());
                }
            });
            filechooser.show ();
        }

        private void open_file (File file) {
            file.load_contents_async.begin (null, (object, result) => {
                print ("Begin reading some file");

                string display_name;
                // Query the display name for the file
                try {
                    FileInfo? info = file.query_info ("standard::display-name", FileQueryInfoFlags.NONE);
                    display_name = info.get_attribute_string ("standard::display-name");
                } catch (Error e) {
                    display_name = file.get_basename ();
                }


                uint8[] contents;
                try {
                    file.load_contents_async.end (result, out contents, null);
                } catch (Error e) {
                    stderr.printf ("Uable to open %s: %s", file.peek_path (), e.message);
                }

                var contents_str = (string) contents;
                if (!contents_str.validate ()) {
                    stderr.printf ("Unable to load content of %s as UTF8", file.peek_path ());
                }

                Gtk.TextBuffer buffer = this.textviewer.buffer;

                // Set the text using the contents of the file
                buffer.text = (string) contents;

                // Reposition the cursor so it's at the start of the text
                Gtk.TextIter start;
                buffer.get_start_iter (out start);
                buffer.place_cursor (start);


                this.title = display_name;
            });
        }
    }
}