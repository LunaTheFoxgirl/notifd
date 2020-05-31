module notifd;
import std.typecons;
version(linux) {
    import ddbus;
}

/**
    A notifier that can display notifications
*/
class AppNotifier {
private:
    string icon;
    string appName;
    version(linux) {
        Connection connection;
        PathIface notifier;
    }

    version(Win32) {

    }


    Notification _notify(string icon, string appName, string title, string message) {
        version(linux) {
            return 
                Notification(
                    notifier.call!uint(
                        "Notify", 
                        appName, 
                        0u, 
                        icon, 
                        title, 
                        message, 
                        cast(string[])[], 
                        cast(Variant!string[string])null, 
                        0
                    ),
                    notifier
                );
        }
    }

    void initialize() {
        version(linux) {
            this.notifier = new PathIface(
                connection, 
                "org.freedesktop.Notifications", 
                "/org/freedesktop/Notifications", 
                "org.freedesktop.Notifications");
        }
    }

public:

    /**
        Constructs an AppNotifier
    */
    this(string appName) {
        this(appName, appName);
    }

    /**
        Constructs an AppNotifier
    */
    this(string appName, string icon) {
        this.icon = icon;
        this.appName = appName;

        version(linux) {
            this.connection = connectToBus();
        }

        this.initialize();
    }

    ~this() {
        connection.close();
    }

    /**
        Send a notification.
    */
    Notification notify(string title, string message) {
        return _notify(icon, appName, title, message);
    }

    /**
        Send a notification with a custom icon
    */
    Notification notify(string title, string message, string icon) {
        return _notify(icon, appName, title, message);
    }
}

/**
    A notification
*/
struct Notification {
version(linux):
    private {
        uint id;
        PathIface iface;
    }

    this(uint id, PathIface iface) {
        this.id = id;
        this.iface = iface;
    }

    /**
        Closes the notification
    */
    void close() {
        iface.call!DBusAny("CloseNotification", id);
    }

version(Win32):

}