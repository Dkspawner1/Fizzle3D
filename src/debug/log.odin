package debug

import "core:fmt"
import "core:time"

LogLevel :: enum
{
    TRACE,
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    CRITICAL,
}

COLOR_RESET :: "\x1b[0m"
COLOR_TRACE :: "\x1b[36m"
COLOR_DEBUG :: "\x1b[34m"
COLOR_INFO :: "\x1b[32m"
COLOR_WARN :: "\x1b[33m"
COLOR_ERROR :: "\x1b[31m"
COLOR_CRITICAL :: "\x1b[35m"


Logger :: struct
{
    level: LogLevel,
    colored : bool,
}

g_logger := Logger{
    level = LogLevel.DEBUG,
    colored = true,
}

level_to_string :: proc(level: LogLevel) -> string {
    switch level {
    case :
        return "UNKNOWN"

    case .TRACE:
        return "TRACE"
    case .DEBUG:
        return "DEBUG"
    case .INFO:
        return "INFO "
    case .WARNING:
        return "WARN "
    case .ERROR:
        return "ERROR"
    case .CRITICAL:
        return "CRIT "

    }
    return "UNKNOWN"
}



level_to_color :: proc(level: LogLevel) -> string {
    if !g_logger.colored {
        return ""
    }
    switch level {
    case .TRACE:
        return COLOR_TRACE
    case .DEBUG:
        return COLOR_DEBUG
    case .INFO:
        return COLOR_INFO
    case .WARNING:
        return COLOR_WARN
    case .ERROR:
        return COLOR_ERROR
    case .CRITICAL:
        return COLOR_CRITICAL
    }
    return COLOR_RESET
}


get_basename :: proc(path: string) -> string {
    for i := len(path) - 1; i >= 0; i -= 1 {
        if path[i] == '/' || path[i] == '\\' {
            return path[i + 1:]
        }
    }
    return path
}

Logger_Initialize :: proc(level: LogLevel) {
    g_logger.level = level
    g_logger.colored = true
    fmt.println(
    fmt.tprintf(
    "%s[Logger] Logger initialized with level: %s%s",
    level_to_color(.INFO),
    level_to_string(level),
    COLOR_RESET,
    ),
    )
}

Logger_Shutdown :: proc() {
    fmt.println(
    fmt.tprintf(
    "%s[Logger] Logger shutdown%s",
    level_to_color(.INFO),
    COLOR_RESET,
    ),
    )
}
Logger_Log :: proc(level: LogLevel, category: string, format_str: string, args: ..any) {
    if level < g_logger.level {
        return
    }

    now := time.now()
    time_buf: [32]u8
    time_str := time.time_to_string_hms(now, time_buf[:])
    basename := get_basename(category)

    fmt.printf(
    "%s%s %s [%s]%s ",
    level_to_color(level),
    time_str,
    level_to_string(level),
    basename,
    COLOR_RESET,
    )
    fmt.printfln(format_str, ..args)
}

trace :: proc(format_str: string, args: ..any, location := #caller_location) {
    Logger_Log(.TRACE, location.file_path, format_str, ..args)
}

debug :: proc(format_str: string, args: ..any, location := #caller_location) {
    Logger_Log(.DEBUG, location.file_path, format_str, ..args)
}

info :: proc(format_str: string, args: ..any, location := #caller_location) {
    Logger_Log(.INFO, location.file_path, format_str, ..args)
}

warning :: proc(format_str: string, args: ..any, location := #caller_location) {
    Logger_Log(.WARNING, location.file_path, format_str, ..args)
}

error :: proc(format_str: string, args: ..any, location := #caller_location) {
    Logger_Log(.ERROR, location.file_path, format_str, ..args)
}

critical :: proc(format_str: string, args: ..any, location := #caller_location) {
    Logger_Log(.CRITICAL, location.file_path, format_str, ..args)
}
