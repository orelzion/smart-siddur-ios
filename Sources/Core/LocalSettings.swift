import Foundation
import Observation

private func localizedLocalSettingValue(_ key: String, fallback: String) -> String {
    let value = NSLocalizedString(key, comment: "")
    return value == key ? fallback : value
}

// MARK: - Local Setting Enums

enum TfilaMode: String, CaseIterable, Sendable {
    case regular
    case yahid
    case chazan

    var displayName: String {
        switch self {
        case .regular: localizedLocalSettingValue("modes__0", fallback: "Regular")
        case .yahid: localizedLocalSettingValue("modes__1", fallback: "Yahid")
        case .chazan: localizedLocalSettingValue("modes__2", fallback: "Chazan")
        }
    }
}

enum AppTheme: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: localizedLocalSettingValue("system_managed", fallback: "System")
        case .light: localizedLocalSettingValue("theme__0", fallback: "Light")
        case .dark: localizedLocalSettingValue("theme__1", fallback: "Dark")
        }
    }
}

enum FontFamily: String, CaseIterable, Sendable {
    case frank
    case david
    case arial
    case timesNewRoman = "times_new_roman"

    var displayName: String {
        switch self {
        case .frank: "Frank Ruehl"
        case .david: "David"
        case .arial: "Arial"
        case .timesNewRoman: "Times New Roman"
        }
    }
}

enum SilentMode: String, CaseIterable, Sendable {
    case ask
    case silent
    case normal

    var displayName: String {
        switch self {
        case .ask: localizedLocalSettingValue("silent_mode__2", fallback: "Ask")
        case .silent: localizedLocalSettingValue("silent_mode__0", fallback: "Silent")
        case .normal: localizedLocalSettingValue("silent_mode__1", fallback: "Normal")
        }
    }
}

// MARK: - LocalSettings

/// Local-only settings stored in UserDefaults.
/// Per MIGRATION_SPEC Section 6.3 and 7.2:
/// These settings stay device-local for instant UI response -- no network round-trip.
@MainActor
@Observable
final class LocalSettings {
    static let shared = LocalSettings()
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Prayer Mode

    var tfilaMode: TfilaMode {
        get { TfilaMode(rawValue: defaults.string(forKey: "tfila_mode") ?? "regular") ?? .regular }
        set { defaults.set(newValue.rawValue, forKey: "tfila_mode") }
    }

    // MARK: - Temporary States

    var isAvel: Bool {
        get { defaults.bool(forKey: "is_avel") }
        set { defaults.set(newValue, forKey: "is_avel") }
    }

    var noTahanun: Bool {
        get { defaults.bool(forKey: "no_tahanun") }
        set { defaults.set(newValue, forKey: "no_tahanun") }
    }

    var isVanenu: Bool {
        get { defaults.bool(forKey: "is_vanenu") }
        set { defaults.set(newValue, forKey: "is_vanenu") }
    }

    var nachemAlways: Bool {
        get { defaults.bool(forKey: "nachem_always") }
        set { defaults.set(newValue, forKey: "nachem_always") }
    }

    // MARK: - Appearance

    var appTheme: AppTheme {
        get { AppTheme(rawValue: defaults.string(forKey: "app_theme") ?? "system") ?? .system }
        set { defaults.set(newValue.rawValue, forKey: "app_theme") }
    }

    var fontFamily: FontFamily {
        get { FontFamily(rawValue: defaults.string(forKey: "font_family") ?? "frank") ?? .frank }
        set { defaults.set(newValue.rawValue, forKey: "font_family") }
    }

    var fontSize: Float {
        get {
            let value = defaults.float(forKey: "font_size")
            return value > 0 ? value : 16.0
        }
        set { defaults.set(newValue, forKey: "font_size") }
    }

    var keepScreenAwake: Bool {
        get {
            if defaults.object(forKey: "keep_screen_awake") == nil { return true }
            return defaults.bool(forKey: "keep_screen_awake")
        }
        set { defaults.set(newValue, forKey: "keep_screen_awake") }
    }

    var portraitOnly: Bool {
        get { defaults.bool(forKey: "portrait_only") }
        set { defaults.set(newValue, forKey: "portrait_only") }
    }

    // MARK: - Display Preferences

    var respondLongPress: Bool {
        get {
            if defaults.object(forKey: "respond_long_press") == nil { return true }
            return defaults.bool(forKey: "respond_long_press")
        }
        set { defaults.set(newValue, forKey: "respond_long_press") }
    }

    var showTitles: Bool {
        get {
            if defaults.object(forKey: "show_titles") == nil { return true }
            return defaults.bool(forKey: "show_titles")
        }
        set { defaults.set(newValue, forKey: "show_titles") }
    }

    var use24hFormat: Bool {
        get {
            if defaults.object(forKey: "use_24h_format") == nil { return true }
            return defaults.bool(forKey: "use_24h_format")
        }
        set { defaults.set(newValue, forKey: "use_24h_format") }
    }

    var showZmanBar: Bool {
        get {
            if defaults.object(forKey: "show_zman_bar") == nil { return true }
            return defaults.bool(forKey: "show_zman_bar")
        }
        set { defaults.set(newValue, forKey: "show_zman_bar") }
    }

    // MARK: - Privacy & Device

    var silentMode: SilentMode {
        get { SilentMode(rawValue: defaults.string(forKey: "silent_mode") ?? "ask") ?? .ask }
        set { defaults.set(newValue.rawValue, forKey: "silent_mode") }
    }

    var allowTracking: Bool {
        get { defaults.bool(forKey: "allow_tracking") }
        set { defaults.set(newValue, forKey: "allow_tracking") }
    }
    
    // MARK: - Prayer Settings for Cache
    
    /// Current nusach setting as string for API calls
    var nusachString: String {
        get { defaults.string(forKey: "nusach_string") ?? "ashkenaz" }
        set { defaults.set(newValue, forKey: "nusach_string") }
    }
    
    /// Selected location name for prayer context
    var locationName: String? {
        get { defaults.string(forKey: "location_name") }
        set { defaults.set(newValue, forKey: "location_name") }
    }
}
