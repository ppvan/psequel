namespace Psequel {

    [GtkTemplate (ui = "/me/ppvan/psequel/gtk/view-structure-view.ui")]
    public class ViewStructureView : Gtk.Box {
        public ViewStructureViewModel viewstructure_viewmodel {get; set;}

        public Gtk.FilterListModel columns {get; set;}
        public Gtk.FilterListModel indexes {get; set;}
        public Gtk.StringFilter filter {get; set;}

        public ViewStructureView () {
            Object ();
        }

        construct {
            this.viewstructure_viewmodel = autowire<ViewStructureViewModel> ();
            
            var expresion = new Gtk.PropertyExpression (typeof(BaseType), null, "table");
            this.filter = new Gtk.StringFilter (expresion);
            this.filter.match_mode = Gtk.StringFilterMatchMode.EXACT;

            columns = new Gtk.FilterListModel (viewstructure_viewmodel.columns, filter);
            indexes = new Gtk.FilterListModel (viewstructure_viewmodel.indexes, filter);
            filter.search = "";

            viewstructure_viewmodel.notify["selected-view"].connect (() => {
                var view = viewstructure_viewmodel.selected_view;
                filter.search = view.name;

                debug ("Notify View: %s", view.name);
                debug ("Filter: %s", filter.search);
                debug ("columns: %u", columns.get_n_items ());
            });
        }
    }
}