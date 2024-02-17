using Psequel;
using GLib;


public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/connection/default", () => {
        var conn = new Connection("test-conn") {

        };
        var expect_url = "postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable";

        assert_cmpstr(conn.url_form(), CompareOperator.EQ, expect_url);
    });

    Test.add_func("/connection/user", () => {
        var conn = new Connection("test-conn") {
            user = "psequel",
            password = "psequel-pass"
        };
        var expect_url = "postgresql://psequel:psequel-pass@localhost:5432/postgres?sslmode=disable";

        assert_cmpstr(conn.url_form(), CompareOperator.EQ, expect_url);
    });

    Test.add_func("/connection/database", () => {
        var conn = new Connection("test-conn") {
            database = "psequel-test"
        };
        var expect_url = "postgresql://postgres:postgres@localhost:5432/psequel-test?sslmode=disable";

        assert_cmpstr(conn.url_form(), CompareOperator.EQ, expect_url);
    });

    Test.add_func("/connection/percent-encode", () => {
        var conn = new Connection("test-conn") {
            user = "psequel_test",
            password = "===",
            options = "options=-c synchronous_commit=off"
        };
        var expect_url = "postgresql://psequel_test:===@localhost:5432/postgres?sslmode=disable&options=-c%20synchronous_commit=off";

        assert_cmpstr(conn.url_form(), CompareOperator.EQ, expect_url);
    });

    return Test.run();
}