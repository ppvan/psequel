using Postgres;

namespace Psequel {
/** Main entry poit of application, exec query and return result.
 *
 * Do any thing relate to database, wrapper of libpq
 */
public class SQLService : Object {
    public int query_limit { get; set; default = 100; }
    public int query_timeout { get; set; }

    private Settings settings;

    public SQLService(ThreadPool <Worker> background) {
        Object();
        this.background = background;
        this.settings   = autowire <Settings> ();

        settings.bind("query-limit", this, "query-limit", SettingsBindFlags.GET);
        settings.bind("query-timeout", this, "query-timeout", SettingsBindFlags.GET);
    }

    /** Select info from a table. */
    public async Relation select(BaseTable table, int page, int size = query_limit) throws PsequelError {
        string schema_name   = active_db.escape_identifier(table.schema.name);
        string escape_tbname = active_db.escape_identifier(table.name);
        int    offset        = page * size;
        int    limit         = size;

        string stmt  = @"SELECT * FROM $schema_name.$escape_tbname LIMIT $limit OFFSET $offset";
        var    query = new Query(stmt);
        return(yield exec_query(query));
    }

    /** Make a connection to database and active connection. */
    public async void connect_db(Connection conn) throws PsequelError {
        var    connection_timeout = settings.get_int("connection-timeout");
        var    query_timeout      = settings.get_int("query-timeout");
        string db_url             = conn.connection_string(connection_timeout, query_timeout);
        debug("Connecting to %s", db_url);
        TimePerf.begin();
        SourceFunc callback = connect_db.callback;
        try {
            var worker = new Worker("connect database", () => {
                    active_db = Postgres.connect_db(db_url);

                    // Jump to yield
                    Idle.add((owned) callback);
                });
            background.add(worker);

            yield;
            TimePerf.end();
            check_connection_status();
        } catch (ThreadError err) {
            debug(err.message);
            assert_not_reached();
        }
    }

    public async Relation exec_query(Query query) throws PsequelError {
        int64 begin  = GLib.get_real_time();
        var   result = yield exec_query_internal(query.sql);

        check_query_status(result);

        int64 end = GLib.get_real_time();

        return(new Relation.with_fetch_time((owned)result, end - begin));
    }

    public Relation make_empty_relation() {
        var res = active_db.make_empty_result(ExecStatus.TUPLES_OK);
        return(new Relation((owned)res));
    }

    public async Relation exec_query_params(Query query) throws PsequelError {
        assert(query.params != null);

        var result = yield exec_query_params_internal(query.sql, query.params);

        // check query status
        check_query_status(result);

        var table = new Relation((owned)result);

        return(table);
    }

    private void check_connection_status() throws PsequelError {
        var status = active_db.get_status();
        switch (status)
        {
        case Postgres.ConnectionStatus.OK:
            // Success
            break;

        case Postgres.ConnectionStatus.BAD:
            var err_msg = active_db.get_error_message();
            throw new PsequelError.CONNECTION_ERROR(err_msg);

        default:
            debug("Programming error: %s not handled", status.to_string());
            assert_not_reached();
        }
    }

    private void check_query_status(Result result) throws PsequelError {
        var status = result.get_status();

        switch (status)
        {
        case ExecStatus.TUPLES_OK, ExecStatus.COMMAND_OK, ExecStatus.COPY_OUT:
            // success
            break;

        case ExecStatus.FATAL_ERROR:
            var err_msg = result.get_error_message();
            debug("Fatal error: %s", err_msg);
            throw new PsequelError.QUERY_FAIL(err_msg.dup());

        case ExecStatus.EMPTY_QUERY:
            debug("Empty query");
            throw new PsequelError.QUERY_FAIL("Empty query");

        default:
            warning("Programming error: %s not handled", status.to_string());
            assert_not_reached();
        }
    }

    private async Result exec_query_internal(string query) throws PsequelError {
        debug("Exec: %s", query);
        TimePerf.begin();

        // Boilerplate
        SourceFunc callback = exec_query_internal.callback;
        Result result = null;
        try {
            // Important line.
            var worker = new Worker("exec query", () => {
                    // Important line.
                    result = active_db.exec(query);
                    Idle.add((owned) callback);
                });

            background.add(worker);

            yield;
            TimePerf.end();

            return((owned)result);
        } catch (ThreadError err) {
            warning(err.message);
            assert_not_reached();
        }
    }

    private async Result exec_query_params_internal(string query, List <string> params) throws PsequelError {
        debug("Exec Param: %s", query);
        TimePerf.begin();

        SourceFunc callback = exec_query_params_internal.callback;
        Result result       = null;
        var    params_array = ValueConverter.list_to_array <string>(params);


        try {
            var worker = new Worker("exec query params", () => {
                    result = active_db.exec_params(query, (int)params.length(), null, params_array, null, null, 0);
                    // Jump to yield
                    Idle.add((owned) callback);
                });
            background.add(worker);

            yield;

            // worker.get_result ();

            TimePerf.end();

            return((owned)result);
        } catch (ThreadError err) {
            warning(err.message);
            assert_not_reached();
        }
    }

    private Database active_db;
    private unowned ThreadPool <Worker> background;
}
}
