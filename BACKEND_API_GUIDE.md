# SmartSiddur Backend API Guide for iOS

**Last Updated**: 2026-02-12
**Backend Version**: 1.0.0
**Status**: ✅ Production Deployed

---

## Overview

The SmartSiddur backend has been migrated to **Supabase Edge Functions** with a new TypeScript-based prayer generation system. This replaces the previous Android-only Java generators with a universal API that both iOS and Android can consume.

### What Changed

1. **New Prayer Generation API**: Server-side TypeScript prayer generators
2. **Unified Content Database**: 2,634 prayer content entries with multi-language support
3. **RESTful Edge Functions**: Two endpoints for single and batch prayer generation
4. **Multi-Language Support**: Hebrew, French, German, Spanish titles and labels

---

## 🔗 API Endpoints

**Base URL**: `https://dekdhfjyukihnggfftui.supabase.co`

### 1. Generate Single Prayer

```
POST /functions/v1/generate-prayer
```

Generates a single prayer (Shacharit, Mincha, Arvit, etc.) for a specific date and location.

### 2. Generate Prayer Batch

```
POST /functions/v1/generate-prayer-batch
```

Generates multiple prayers in a single request (useful for pre-loading multiple days or prayer types).

---

## 📋 Request Format

### Generate Prayer Request

```json
{
  "prayer_type": "arvit",
  "date": "2026-02-12",
  "nusach": "chabad",
  "tfila_mode": "regular",
  "location": {
    "latitude": 31.7683,
    "longitude": 35.2137,
    "elevation": 0,
    "timezone_id": "Asia/Jerusalem",
    "country_code": "IL",
    "is_in_israel": true
  },
  "settings": {
    "is_woman": false,
    "is_avel": false,
    "no_tahanun": false,
    "is_vanenu": false,
    "nachem_always": false,
    "tal_preference": false,
    "is_mizrochnik": false,
    "mukaf_mode": "purim",
    "sick_name": "",
    "pasuk": "",
    "language": "fr"
  }
}
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prayer_type` | string | ✅ | Prayer type (see Prayer Types below) |
| `date` | string | ✅ | ISO 8601 date (YYYY-MM-DD) |
| `nusach` | string | ✅ | `"edot"`, `"sfarad"`, `"ashkenaz"`, `"chabad"` |
| `tfila_mode` | string | ✅ | `"regular"`, `"yahid"`, `"chazan"` |
| `location` | object | ✅ | Location information |
| `settings` | object | ✅ | User preferences and settings |

#### Prayer Types

```
shacharit, mincha, arvit, mazon, omer, al_mita, chatzot,
havdala, hanuka, levana, haderech, blessings, threefold,
mila, sheva_brachot, maaser, hala, lag_baomer, ilanot,
kinot, slihot, nedarim, asher_yatzar, ushpizin,
torah_reading, musaf
```

#### Location Object

```json
{
  "latitude": 31.7683,
  "longitude": 35.2137,
  "elevation": 0,
  "timezone_id": "Asia/Jerusalem",
  "country_code": "IL",
  "is_in_israel": true
}
```

#### Settings Object

| Field | Type | Description |
|-------|------|-------------|
| `is_woman` | boolean | Is the user a woman (affects certain prayers) |
| `is_avel` | boolean | Is the user a mourner (adds special prayers) |
| `no_tahanun` | boolean | Skip Tachanun prayer |
| `is_vanenu` | boolean | Add Va'anenu (fast day) |
| `nachem_always` | boolean | Always add Nachem (not just Tisha B'Av) |
| `tal_preference` | boolean | User preference for Tal |
| `is_mizrochnik` | boolean | Eastern (Mizrachi) custom |
| `mukaf_mode` | string | `"purim"`, `"shushan"`, `"both"` |
| `sick_name` | string | Name for Mi Shebeirach (optional) |
| `pasuk` | string | Custom verse (optional) |
| `language` | string | UI language: `"he"`, `"fr"`, `"de"`, `"es"`, `"en"` |
| `mazon_variant` | string? | `"regular"`, `"guest"`, `"wedding"`, `"brit_mila"` |
| `threefold_type` | string? | `"mezonot"`, `"gefen"`, `"fruits"` |

---

## 📤 Response Format

```json
{
  "prayer_type": "arvit",
  "generated_for_date": "2026-02-12",
  "items": [
    {
      "id": "arvit.barechu",
      "title": "Béni soit Hashem",
      "text": "<small>Le Hazan Dit:</small> בָּרְכוּ...",
      "expand": "none",
      "show_title": true,
      "sort_order": 2
    }
  ],
  "menu": [
    {
      "index": 5,
      "title": "Shéma"
    }
  ],
  "metadata": {
    "jewish_date": "25 Shevat 5786",
    "is_shabbat": false,
    "is_yom_tov": false,
    "is_chol_hamoed": false,
    "is_rosh_chodesh": false,
    "is_taanis": false,
    "yom_tov_name": null,
    "parsha": null,
    "omer_day": null,
    "content_version": 1
  }
}
```

### Response Fields

#### Prayer Item

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique content key (e.g., `"arvit.barechu"`) |
| `title` | string | Localized title (language-dependent) |
| `text` | string | Hebrew prayer text with HTML formatting |
| `expand` | string | `"expanded"`, `"collapsed"`, `"none"` |
| `show_title` | boolean | Whether to display the title |
| `sort_order` | number | Display order |

#### Menu Entry

| Field | Type | Description |
|-------|------|-------------|
| `index` | number | Index into `items` array |
| `title` | string | Localized menu title |

#### Metadata

Contains Jewish calendar information and prayer context.

---

## 🌍 Multi-Language Support

The API supports localized **titles** and **UI labels** (not the prayer text itself, which remains in Hebrew).

### Supported Languages

- **Hebrew** (`he`) - Default
- **French** (`fr`) - 719 translations
- **German** (`de`) - 719 translations
- **Spanish** (`es`) - 719 translations
- **English** (`en`) - Partial (transliterations)

### Example: French

**Request:**
```json
{
  "settings": {
    "language": "fr",
    ...
  }
}
```

**Response titles:**
- `"Béni soit Hashem"` (Barechu)
- `"Bénédiction du Soir"` (Evening Blessing)
- `"Bénédiction de la Torah"` (Torah Blessing)
- `"Shéma"` (Shema)

**UI Labels:**
- `"Le Hazan Dit:"` (The Cantor says)
- `"L'Assistance répond:"` (The congregation responds)

---

## 🔧 iOS Implementation Guide

### Step 1: Update Network Layer

Create a new API service for Supabase:

```swift
import Foundation

class SupabasePrayerService {
    private let baseURL = "https://dekdhfjyukihnggfftui.supabase.co"

    func generatePrayer(
        prayerType: String,
        date: Date,
        nusach: String,
        tfilaMode: String,
        location: Location,
        settings: PrayerSettings
    ) async throws -> PrayerResponse {
        let url = URL(string: "\(baseURL)/functions/v1/generate-prayer")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeneratePrayerRequest(
            prayer_type: prayerType,
            date: ISO8601DateFormatter().string(from: date).prefix(10),
            nusach: nusach,
            tfila_mode: tfilaMode,
            location: location,
            settings: settings
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PrayerServiceError.invalidResponse
        }

        return try JSONDecoder().decode(PrayerResponse.self, from: data)
    }
}
```

### Step 2: Define Data Models

```swift
struct GeneratePrayerRequest: Codable {
    let prayer_type: String
    let date: String
    let nusach: String
    let tfila_mode: String
    let location: Location
    let settings: PrayerSettings
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let timezone_id: String
    let country_code: String
    let is_in_israel: Bool
}

struct PrayerSettings: Codable {
    let is_woman: Bool
    let is_avel: Bool
    let no_tahanun: Bool
    let is_vanenu: Bool
    let nachem_always: Bool
    let tal_preference: Bool
    let is_mizrochnik: Bool
    let mukaf_mode: String
    let sick_name: String
    let pasuk: String
    let language: String
    let mazon_variant: String?
    let threefold_type: String?
}

struct PrayerResponse: Codable {
    let prayer_type: String
    let generated_for_date: String
    let items: [PrayerItem]
    let menu: [MenuEntry]
    let metadata: PrayerMetadata
}

struct PrayerItem: Codable {
    let id: String
    let title: String
    let text: String
    let expand: String
    let show_title: Bool
    let sort_order: Int
}

struct MenuEntry: Codable {
    let index: Int
    let title: String
}

struct PrayerMetadata: Codable {
    let jewish_date: String
    let is_shabbat: Bool
    let is_yom_tov: Bool
    let is_chol_hamoed: Bool
    let is_rosh_chodesh: Bool
    let is_taanis: Bool
    let yom_tov_name: String?
    let parsha: String?
    let omer_day: Int?
    let content_version: Int
}
```

### Step 3: Display Prayer Text

The `text` field contains **HTML with Hebrew text**. You'll need to render it properly:

```swift
import UIKit
import WebKit

class PrayerTextView: UIView {
    private let webView = WKWebView()

    func displayPrayerText(_ htmlText: String) {
        let styledHTML = """
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: 'Times New Roman', serif;
                    font-size: 18px;
                    direction: rtl;
                    text-align: right;
                    padding: 16px;
                }
                small {
                    font-size: 14px;
                    color: #666;
                }
            </style>
        </head>
        <body>
            \(htmlText)
        </body>
        </html>
        """

        webView.loadHTMLString(styledHTML, baseURL: nil)
    }
}
```

### Step 4: Handle User Settings

Map your existing user preferences to the new API format:

```swift
extension UserDefaults {
    func getPrayerSettings(language: String = "he") -> PrayerSettings {
        return PrayerSettings(
            is_woman: bool(forKey: "is_woman"),
            is_avel: bool(forKey: "is_avel"),
            no_tahanun: bool(forKey: "skip_tachanun"),
            is_vanenu: bool(forKey: "add_vanenu"),
            nachem_always: bool(forKey: "add_nachem"),
            tal_preference: bool(forKey: "tal_preference"),
            is_mizrochnik: bool(forKey: "is_mizrochnik"),
            mukaf_mode: string(forKey: "mukaf_mode") ?? "purim",
            sick_name: string(forKey: "sick_name") ?? "",
            pasuk: string(forKey: "pasuk") ?? "",
            language: language,
            mazon_variant: string(forKey: "mazon_variant"),
            threefold_type: string(forKey: "threefold_type")
        )
    }
}
```

---

## 🧪 Testing

### Test with cURL

```bash
curl -X POST https://dekdhfjyukihnggfftui.supabase.co/functions/v1/generate-prayer \
  -H "Content-Type: application/json" \
  -d '{
    "prayer_type": "mincha",
    "date": "2026-02-12",
    "nusach": "ashkenaz",
    "tfila_mode": "regular",
    "location": {
      "latitude": 31.7683,
      "longitude": 35.2137,
      "elevation": 0,
      "timezone_id": "Asia/Jerusalem",
      "country_code": "IL",
      "is_in_israel": true
    },
    "settings": {
      "is_woman": false,
      "is_avel": false,
      "no_tahanun": false,
      "is_vanenu": false,
      "nachem_always": false,
      "tal_preference": false,
      "is_mizrochnik": false,
      "mukaf_mode": "purim",
      "sick_name": "",
      "pasuk": "",
      "language": "he"
    }
  }'
```

### Sample Response

See `BACKEND_API_GUIDE.md` companion file: `sample_response.json`

---

## 📊 Database Structure

### Prayer Content Table

The backend uses a `prayer_content` table with:

- **2,634 prayer content entries**
- **20 sections** (amida, arvit, shacharit, etc.)
- **719 entries with translations** (fr, de, es)

#### Schema

```sql
CREATE TABLE prayer_content (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    content_key     TEXT NOT NULL UNIQUE,
    content_type    TEXT NOT NULL DEFAULT 'prayer',
    text_variants   JSONB NOT NULL DEFAULT '{}',
    translations    JSONB NOT NULL DEFAULT '{}',
    placeholders    TEXT[] NOT NULL DEFAULT '{}',
    default_expand  TEXT NOT NULL DEFAULT 'none',
    show_title      BOOLEAN NOT NULL DEFAULT TRUE,
    add_to_menu     BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    section         TEXT NOT NULL,
    version         INTEGER NOT NULL DEFAULT 1,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 🔄 Migration Path

### Phase 1: Parallel Testing (Recommended)

1. Keep existing offline generation as fallback
2. Add new API calls for testing
3. Compare outputs between old and new systems
4. Gradually increase traffic to new API

### Phase 2: Full Migration

1. Remove local generator code
2. Use API exclusively
3. Implement caching for offline support
4. Add retry logic for network failures

### Phase 3: Optimization

1. Implement batch pre-loading for upcoming days
2. Cache responses locally (CoreData/Realm)
3. Add background refresh for prayer updates
4. Monitor API performance metrics

---

## 🚨 Error Handling

### Common Errors

| Status | Error | Solution |
|--------|-------|----------|
| 400 | Invalid tfila_mode | Use lowercase: `"regular"`, `"yahid"`, `"chazan"` |
| 400 | Invalid prayer_type | Check spelling and use supported types |
| 400 | Invalid date format | Use ISO 8601: `"YYYY-MM-DD"` |
| 500 | Server error | Retry with exponential backoff |

### Retry Strategy

```swift
func generatePrayerWithRetry(
    maxRetries: Int = 3,
    ...
) async throws -> PrayerResponse {
    var lastError: Error?

    for attempt in 0..<maxRetries {
        do {
            return try await generatePrayer(...)
        } catch {
            lastError = error
            if attempt < maxRetries - 1 {
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
            }
        }
    }

    throw lastError ?? PrayerServiceError.maxRetriesExceeded
}
```

---

## 📝 Notes

### Important Considerations

1. **Hebrew Text**: Always RTL (right-to-left) layout
2. **HTML Formatting**: Use WebKit or attributed strings
3. **Offline Support**: Cache responses for offline use
4. **Performance**: Pre-load prayers for better UX
5. **Language Fallback**: If translation missing, falls back to Hebrew

### Breaking Changes from Android

1. **No Direct R.string References**: All content comes from API
2. **Server-Side Calendar**: No need for local Jewish calendar calculations
3. **Unified Nusach Handling**: Server resolves nusach variants
4. **HTML in Text**: Text includes `<br>`, `<small>`, `<font>` tags

---

## 🔗 Resources

- **API Base URL**: https://dekdhfjyukihnggfftui.supabase.co
- **Dashboard**: https://supabase.com/dashboard/project/dekdhfjyukihnggfftui
- **Test Files**: `~/git/SmartSiddur/tests/parity/`
- **Migration SQL**: `~/git/SmartSiddur/supabase/migrations/`

---

## 📞 Support

For questions or issues:
1. Check this guide first
2. Review test files in `tests/parity/`
3. Contact backend team
4. Create issue on GitHub

---

**Generated**: 2026-02-12
**Version**: 1.0.0
**Status**: Production Ready ✅
