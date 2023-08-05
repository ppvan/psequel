namespace Psequel {

    /* View here is database view (virtual tables), not UI */
    public class ViewViewModel : BaseViewModel {
        public ObservableList<View> tables { get; set; default = new ObservableList<View> (); }
        public View? current_view { get; set; }

        public ViewViewModel () {
            Object ();
        }
    }
}