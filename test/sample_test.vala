namespace Psequel {

    //  https://github.com/jorchube/vest

    public static int main (string[] args) {

        var mainloop = new MainLoop();

        try {

            var background = new ThreadPool<Worker>.with_owned_data ((worker) => {
                worker.run ();
            }, 1, false);
    
            var sql = new SQLService(background);
            var conn = new Connection ("test");

            sql.connect_db.begin (conn, (obj, res) => {

                try {

                    sql.connect_db.end (res);

                } catch(PsequelError err) {
                    print(err.message);
                }

                mainloop.quit();
            });


    
        } catch(ThreadError err) {
            print ("Unknown eror: %s\n", err.message);
            return 1;
        }

        mainloop.run ();

        return 0;
    }
}