namespace Psequel {
    public void set_up_logging () {
        var debug_domain = Environment.get_variable ("G_MESSAGES_DEBUG");

        switch (debug_domain) {
        case Config.G_LOG_DOMAIN, "all":
            Log.set_handler (Config.G_LOG_DOMAIN, LogLevelFlags.LEVEL_DEBUG | LogLevelFlags.LEVEL_WARNING, log_function);
            break;
        default:
            break;
        }
    }

    private void log_function (string? domain, LogLevelFlags level, string message) {
        switch (level) {
        case LogLevelFlags.LEVEL_DEBUG:
            print ("[DEBUG] %s\n", message);
            break;
        case LogLevelFlags.LEVEL_WARNING:
            print ("[WARN] %s\n", message);
            break;

        default:
            assert_not_reached ();
        }
    }
}