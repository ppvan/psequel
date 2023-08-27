namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/table-structure-view.ui")]
    public class TableStructureView : Gtk.Box {
        public TableStructureViewModel tablestructure_viewmodel { get; private set; }

        public Gtk.FilterListModel columns { get; private set; }
        public Gtk.FilterListModel indexes { get; private set; }
        public Gtk.FilterListModel fks { get; private set; }
        public Gtk.StringFilter filter { get; private set; }

        public TableStructureView() {
            Object();
        }

        construct {
            this.tablestructure_viewmodel = Window.temp.find_type (typeof (TableStructureViewModel)) as TableStructureViewModel;

            this.filter = new Gtk.StringFilter (null);
            filter.expression = new Gtk.PropertyExpression (typeof (BaseType), null, "table");
            filter.match_mode = Gtk.StringFilterMatchMode.EXACT;
            this.columns = new Gtk.FilterListModel (this.tablestructure_viewmodel.columns, filter);
            this.indexes = new Gtk.FilterListModel (this.tablestructure_viewmodel.indexes, filter);
            this.fks = new Gtk.FilterListModel (this.tablestructure_viewmodel.foreign_keys, filter);
            filter.search = "";

            tablestructure_viewmodel.notify["selected-table"].connect (() => {
                var table = tablestructure_viewmodel.selected_table;
                debug ("Notify Table: %s", table.name);
                debug ("Filter: %s", filter.search);
                debug ("columns: %u", columns.get_n_items ());

                filter.search = table.name;
            });
        }
    }
}