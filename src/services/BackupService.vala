using GLib;

namespace Psequel {
public class BackupService : Object {
    public BackupService() {
    }

    public async void backup_db(File dest, Connection conn) throws GLib.Error {
        //  var flags      = SubprocessFlags.NONE;
        var flags      = SubprocessFlags.STDERR_PIPE;
        var subprocess = new Subprocess.newv({ "pg_dump", conn.backup_connection_string(), "-f", dest.get_path() }, flags);

        // Wait for the subprocess to finish asynchronously
        yield subprocess.wait_async();

        string ?stderr_buf = null;

        // Get the exit status
        int exit_status = subprocess.get_exit_status();

        if (exit_status != 0)
        {
            yield subprocess.communicate_utf8_async(null, null, null, out stderr_buf);

            throw new PsequelError.BACKUP_ERROR(stderr_buf);
        }
    }
}
}
