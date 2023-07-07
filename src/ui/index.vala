

namespace Sequelize {

    [GtkTemplate (ui = "/me/ppvan/sequelize/gtk/index.ui")]
    public class IndexView : Gtk.Box {

        [GtkChild]
        private unowned Gtk.ListBox connections;

        [GtkChild]
        private unowned Gtk.Box sidebar;

        // horizontal

        public IndexView () {
            for (int i = 0; i < 10; i++) {
                var label = new Gtk.Label ("Local Host " + i.to_string ());
                // connections is Gtk.ListBox
                connections.append (label);
            }
        }

        construct {
            connections.selected_rows_changed.connect ((row) => {
                var label = row as Gtk.Label;
                print (label.get_label ());
                // output: (null)
            });
        }
    }
}