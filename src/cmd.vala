namespace Psequel {
    public static void main(string []args) {

        ThreadPool<Worker> background = null;
        try {
            // Don't change the max_thread because libpq did not support many query with 1 connection.
            background = new ThreadPool<Worker>.with_owned_data ((worker) => {
                worker.run();
            }, 1, false);
        } catch (ThreadError err) {
            debug(err.message);
            assert_not_reached();
        }

        var sql_service = new SQLService(background);


        print("Hello world");
    }
}