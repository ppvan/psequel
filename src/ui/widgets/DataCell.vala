using Gdk;


namespace Psequel {


    [GtkTemplate(ui = "/me/ppvan/psequel/gtk/datacell.ui")]
    public class DataCell : Adw.Bin {


        private Relation.Row current_row;
        private int current_index;

        const ActionEntry[] ACTION_ENTRIES = {
            { "copy", on_cell_copy },
            { "edit", on_cell_edit },
            { "delete", on_cell_delete },
        };




        public DataCell() {
            Object();
        }

        construct {
            var action_group = new SimpleActionGroup();
            action_group.add_action_entries(ACTION_ENTRIES, this);
            this.insert_action_group("schema", action_group);
        }


        public void bind_data(Psequel.Relation.Row row, int index) {
            this.current_row = row;
            this.current_index = index;
            this.label.label = row[index];
        }

        [GtkCallback]
        public void on_right_clicked() {
            popover.popup();
        }



        // [GtkAction]
        private void on_cell_copy () {
            //  viewmodel.dupplicate_connection (viewmodel.selected_connection);
            debug ("on_cell_copy");

            var primary = Gdk.Display.get_default ();
            var clipboard = primary.get_clipboard ();

            clipboard.set_text (this.current_row[current_index]);

        }

        // [GtkAction]
        private void on_cell_delete () {
            //  viewmodel.active_connection.begin (viewmodel.selected_connection);
            debug ("on_cell_delete");

        }

        private void on_cell_edit () {
            //  viewmodel.active_connection.begin (viewmodel.selected_connection);
            debug ("on_cell_edit");

        }

        [GtkChild]
        private unowned Gtk.Label label;

        [GtkChild]
        private unowned Gtk.PopoverMenu popover;
    }
}