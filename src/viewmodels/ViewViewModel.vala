namespace Psequel {

    /* View here is database view (virtual tables), not UI */
    public class ViewViewModel : BaseViewModel {
        public ObservableList<View> views { get; set; default = new ObservableList<View> (); }
        public View? current_view { get; set; }

        public ObservableList<Column> columns {get; set;}

        public ViewViewModel (Schema schema) {
            Object ();

            views.append_all (schema.views);
        }
    }
}