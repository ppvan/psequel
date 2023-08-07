namespace Psequel {

    /* View here is database view (virtual tables), not UI */
    public class ViewViewModel : BaseViewModel {
        public ObservableList<View> views { get; set; default = new ObservableList<View> (); }
        public View? current_view { get; set; }

        public ViewStructureViewModel viewstructure_viewmodel {get; set;}
        public ViewDataViewModel viewdata_viewmodel {get; set;}


        public ViewViewModel (Schema schema, SQLService service) {
            Object ();
            views.append_all (schema.views);

            this.notify["current-view"].connect (() => {
                viewstructure_viewmodel = new ViewStructureViewModel (current_view);
                viewdata_viewmodel = new ViewDataViewModel (current_view, service);
            });
        }
    }
}