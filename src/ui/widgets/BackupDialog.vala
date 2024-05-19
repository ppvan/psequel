namespace Psequel {
[GtkTemplate(ui = "/me/ppvan/psequel/gtk/backup-dialog.ui")]
public class BackupDialog : Adw.Dialog {
    public static string[] FORMATS = {
        "plain",
        "custom",
        "directory",
        "tar"
    };

    public static string[] SECTIONS = {
        "everything",
        "schema only",
        "data only",
    };


    public string format { get;  set; default = "plain"; }
    public string section { get;  set; default = "everything"; }
    public bool clean { get;  set; default = false; }
    public bool create { get; set; default = false; }

    public Gtk.StringList formats { get;  set; default = new Gtk.StringList(BackupDialog.FORMATS); }
    public Gtk.StringList sections { get; set; default = new Gtk.StringList(BackupDialog.SECTIONS); }

    public signal void on_backup(string[] options);


    public BackupDialog() {
        Object();
    }

    construct {
        format_row.notify["selected-item"].connect((item) => {
                this.format = (format_row.selected_item as Gtk.StringObject)?.string;
            });

        section_row.notify["selected-item"].connect((item) => {
                this.section = (section_row.selected_item as Gtk.StringObject)?.string;
            });
    }

    public bool is_choose_directory() {
        return this.format == "directory";
    }

    public string get_extension() {
        if (this.format == "plain") {
            return ".sql";
        } else if (this.format == "custom") {
            return ".dump";
        } else if (this.format == "directory") {
            return "";
        } else if (this.format == "tar") {
            return ".tar";
        }

        return ".dump";
    }


    [GtkCallback]
    private void on_do_backup_click() {
        var vec = new Vec<string>();
        vec.append("--format");
        vec.append(this.format);
        
        if (section == "everything") {
            // add not thing
        } else if (section == "schema only") {
            vec.append("--schema-only");
        } else if (section == "data only") {
            vec.append("--data-only");
        } else {
            debug ("Invalid section: %s", section);
        }

        if (clean) {
            vec.append("--clean");
        }

        if (create) {
            vec.append("--create");
        }

        on_backup(vec.as_array());
    }

    [GtkChild]
    private unowned Adw.ComboRow format_row;

    [GtkChild]
    private unowned Adw.ComboRow section_row;
}
}
