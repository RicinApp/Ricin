using Ricin;
using Ricin.Utils.Logger;

namespace Ricin.Utils.Logger {
  /**
  * @enum LogLevel - Defines the allowed log levels.
  **/
  public enum LogLevel {
    NONE,
    INFO,
    WARN,
    DEBUG,
    FATAL,
    ERROR,
    CRITICAL;

    public string to_string () {
      switch(this) {
        case NONE: return "NONE";
        case INFO: return "INFO";
        case WARN: return "WARN";
        case DEBUG: return "DEBUG";
        case FATAL: return "FATAL";
        case ERROR: return "ERROR";
        case CRITICAL: return "CRITICAL";
        default: return "UNKOWN";
      }
    }
  }

  /**
  * @enum LogColor - Defines the allowed colors.
  **/
  public enum LogColor {
    NORMAL,
    GREEN,
    BLUE,
    ORANGE,
    RED;

    public string to_string () {
      switch (this) {
        case NORMAL: return "\x1B[0m";
        case GREEN: return "\x1B[32m\x1B[1m";
        case BLUE: return "\x1B[34m\x1B[1m";
        case ORANGE: return "";
        case RED: return "\x1B[31m\x1B[1m";
        default: return LogColor.NORMAL.to_string ();
      }
    }
  }

  /**
  * This function handles all the logging stuffs.
  * @param {LogLevel} log_level - The logging level to apply.
  * @param {string} message - The message to display in logs.
  **/
  public static void RPrint (LogLevel log_level, string message, va_list args) {
    string prefix = log_level.to_string ();
    LogColor color_code = LogColor.NORMAL;
    bool print_to_stderr = false;
    string msg = message.vprintf (args);

    switch (log_level) {
      case LogLevel.INFO:
        color_code = LogColor.BLUE;
        print_to_stderr = false;
        break;
      case LogLevel.WARN:
        color_code = LogColor.ORANGE;
        print_to_stderr = false;
        break;
      case LogLevel.DEBUG:
        color_code = LogColor.GREEN;
        print_to_stderr = false;
        break;
      case LogLevel.FATAL:
        color_code = LogColor.RED;
        print_to_stderr = true;
        break;
      case LogLevel.ERROR:
        color_code = LogColor.RED;
        print_to_stderr = true;
        break;
      case LogLevel.CRITICAL:
        color_code = LogColor.RED;
        print_to_stderr = true;
        break;
    }

#if USE_POSIX // Allows this to run without issue on non-posix systems.
    // If text terminal, don't apply formating. (Travis, etc)
    if (Posix.isatty (stdout.fileno()) == false) {
      if (print_to_stderr) {
        stderr.puts (@"$(prefix): $(msg)\n");
      } else {
        stdout.puts (@"$(prefix): $(msg)\n");
      }
      return;
    }
#endif

    if (print_to_stderr) {
      stderr.puts (@"$(color_code.to_string ())$(prefix):$(LogColor.NORMAL.to_string ()) $(msg)\n");
    } else {
      stdout.puts (@"$(color_code.to_string ())$(prefix):$(LogColor.NORMAL.to_string ()) $(msg)\n");
    }
  }

  /**
  * Info logging.
  * @param {string} message - The message to display in logs.
  **/
  public static void RInfo (string message, ...) {
    RPrint (LogLevel.INFO, message, va_list ());
  }

  /**
  * Warning logging.
  * @param {string} message - The message to display in logs.
  **/
  public static void RWarn (string message, ...) {
    RPrint (LogLevel.WARN, message, va_list ());
  }

  /**
  * Debug logging.
  * @param {string} message - The message to display in logs.
  **/
  public static void RDebug (string message, ...) {
    RPrint (LogLevel.DEBUG, message, va_list ());
  }

  /**
  * Fatal errors logging.
  * @param {string} message - The message to display in logs.
  **/
  public static void RFatal (string message, ...) {
    RPrint (LogLevel.FATAL, message, va_list ());
  }

  /**
  * Error logging.
  * @param {string} message - The message to display in logs.
  **/
  public static void RError (string message, ...) {
    RPrint (LogLevel.ERROR, message, va_list ());
  }

  /**
  * Critical errors logging.
  * @param {string} message - The message to display in logs.
  **/
  public static void RCritical (string message, ...) {
    RPrint (LogLevel.CRITICAL, message, va_list ());
  }
}
