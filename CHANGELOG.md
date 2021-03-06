# Change Log

All notable changes to this project will be documented in this file (at least to the extent possible, I am not infallible sadly).
This project adheres to [Semantic Versioning](http://semver.org/).

## 2.1.2

This release adds the base for locale-awareness in Timex, including one locale ("ru"), support for formatting datetimes
in another locale, and functions which return names of things will now use the default locale. To configure Timex's default
locale, put the following in config.exs:

```elixir
config :timex, default_locale: "ru" # or whatever locale you want
```

### Added
- The ability to configure a default locale (the default is "en" if no config is provided) for formatting/translation of strings
- The ability to format a string using a given locale, otherwise the default locale is used
- Translations for the "ru" locale, more to come
- Locale awareness throughout the core API, so functions such as `day_name` will return the day name in the configured locale,
  if translations for that locale were provided
- `Timex.lformat`, and `Timex.lformat!` variants of the formatting functions, which take a locale to use in formatting
- Added a relative time formatter, which functions very similarily to Moment.js's relative time formatting
  You can use it with `Timex.format!` or `Timex.format`, by providing :relative as the formatter, and using the `{relative}` token in your
  format string. NOTE: The relative formatter does not support other tokens, only `{relative}` for now, if it seems like there
  is a use case where `{relative}` should support other tokens, I'll consider adding that.
- Added `Timex.from_now`, which takes:
  - A single Convertable, which returns the relative time between that date/time value and now
  - Two Convertables, which returns the relative time between the first date/time value, and the reference date (provided as the 2nd)
  - Two variants of the above which also take a locale as the last argument, and results in the string being translated to that locale
### Changed
- All functions which return strings, and all formatting functions, will use the default locale for translation, which is "en" unless another was configured, or one was provided if the function takes a locale as an argument.

## 2.1.1

### Added
- Implementations of the Inspect protocol for Date, DateTime, AmbiguousDateTime, TimezoneInfo, and AmbiguousTimezoneInfo
### Changed
- When inspecting any Timex types, the compact view will be used, pass structs: false to view the raw data structures if needed.

## 2.1.0

### Added
- Two new protocols, `Timex.Comparable` and `Timex.Convertable`, implementing these two for your own date/time types
  will allow you to use the Timex API with your own types, just be aware that only Dates, DateTimes, or AmbiguousDateTimes
  will be returned as date/time representations, but it should be trivial to add a function in your implementation to
  convert back.
- Basic Julian calendar implementation, which allows you to get the Julian date for a given Convertable, see
  `Timex.to_julian/1`, you can also get the day of the week number for a Julian date, via `Timex.Calendar.Julian`
- `to_julian` function to the `Timex.Convertable` protocol
- `Timex.timezones` to get a list of all valid timezones
### Changed
- **POTENTIALLY BREAKING** The `{Zname}` format token was formatting with the abbreviation, which is incorrect. It
  has been changed to format with the full name, use `{Zabbr}` if you want the abbreviation.
- Moved comparison and diffing behaviour into a new protocol, `Timex.Comparable`, which allows you to now
  provide your own implementations for comparing other date or datetime types against Timex ones. This
  makes the API more flexible, and also cleaned up the code quite a bit.
- Modified Timex API to accept Comparables for just about all functions
- Added implementations of `Timex.Comparable` for `Tuple`, `Date`, `DateTime`, `AmbiguousDateTime`
- Added implementations of `Timex.Convertable` for `Map` and `Atom`. The former will accept any map with either
  DateTime-like keys (i.e. year/month/day/hour/minute/etc.) as strings or atoms, or any Date-like keys (year/month/day),
  as strings or atoms. The latter will accept only two atoms which represent Dates/DateTimes right now, :epoch, and :zero.
- Modified `Timex.Comparable` to take any `Timex.Convertable`
## Fixed
- A number of performance enhancements due to refactoring for `Convertable` and `Comparable`, particularly with diffing
- The `%Z` strftime format token was formatting timezones as abbreviations, which is not round-trippable due to timezone
  ambiguity. This token now formats using the full timezone name, which is valid according to the strftime standard.
- The `{Zname}` token had the same problem as above, and has been fixed to use the full name

## 2.0.0

**READ THIS**: This release contains breaking changes from the previous API. The changes are easy to make,
and the compiler will catch almost all of them. See the Migrating section of the README for details on migrating
to 2.0

### Added
- New `Date` type, which is basically the same as `DateTime`, but without time/timezone, which works with
  most all API functions that work with DateTimes, except those which are specific to time or timezones.
  Functions which take a Date or DateTime and options which can manipulate both date and time properties,
  like `set` or `shift` will work as you'd expect with Date values and time-based properties (setting a time
  property will change nothing, shifting will work for values which represent at least a day, sub-day values will not
  change the Date).
- New `AmbiguousDateTime` type which is returned instead of `DateTime` when the datetime in question falls in
  an ambiguously defined timezone period. This type contains two fields, `:before` and `:after` which contain
  the `DateTime` values to choose from. This handles cases where previously an error would likely have been thrown,
  or the behaviour would've been undefined.
- Timex.date and Timex.datetime, which are the equivalent of the old Date.from, except produce a Date or DateTime respectively.
  The `from` API still exists in the Date and DateTime modules, and is present in the Timex API for easier migration, but will
  be deprecated in the future.
- New `from_erl`, `from_timestamp`, `from_microseconds`, `from_milliseconds`, `from_seconds`, `from_days` functions to
  replace the old `from` API, and to match the `Time` API more closely.
- to_date/to_datetime/to_unix/to_timestamp/to_gregorian_seconds conversions in Timex.Convertable (old Timex.Date.Convert protocol)
- before?/after?/between? functions to Timex module
- format/format!/format_time/format_time!/parse/parse! API to Timex module
- week_of_month/1 and /3 to get the week index of the month a date occurs in
- `Timex.diff(this, other, :calendar_weeks)` - get the diff between two dates in terms of weeks on the calendar,
  in other words, the diff is done based on the start of the earliest date's week, and the end of the latest date's week
### Changed
- **BREAKING** All non-bang functions in the API now return error tuples of the form `{:error, term}` instead of raising exceptions
- **BREAKING** All DateTime-related APIs can now return an `AmbiguousDateTime`, which must be handled by choosing which DateTime to use.
- **BREAKING** All Timezone lookups can now return an `AmbiguousTimezoneInfo` struct, which must be handled by choosing which TimezoneInfo to use.
- **BREAKING** DateTime.ms is now DateTime.millisecond
- **BREAKING** Date module API has moved to Timex module
- Date and DateTime modules now contain their respective implementations of the Timex API, all shared functions
  have moved to the Timex module. You can work with Date or DateTimes either through the Timex API, or through the
  API exposed in the Date and DateTime modules. It is recommended to use Timex though.
- **BREAKING** Renamed Timex.Date.Convert to Timex.Convertable
- **BREAKING** `diff/3` now returns the same value no matter which order the arguments are given. Use `compare/3` to get the ordering
### Deprecated
- `Timex.from` (old `Date.from`) variants. Use `Timex.date`, `Timex.datetime`, `Date.from_<type>`, or `DateTime.from_<type>` instead.
- `DateTime.from`. Use `Timex.datetime`, `DateTime.from_erl`, `DateTime.from_<type>`
- `to_usecs`, `to_msecs`, `to_secs`, and `to_mins` in favor of `to_microseconds`, `to_milliseconds`, `to_seconds`, and `to_minutes`
- Abbreviated unit names like `secs` or `mins`, `sec` or `min`, in favor of their full names (i.e. `seconds`, `minutes`, etc.)
### Removed
- DateConvert/DateFormat aliases
### Fixed
- Shifting datetimes is now far more accurate than it was previously, and handles timezone changes, ambiguous timezone periods, and non-existent time periods (such as those during a timezone change like DST).
- Diffing by weeks, months, and years is now much more precise
- Humanized Time formatter now pluralizes units correctly

## 1.0.2

**BREAKING**: If you previously depended on parsing of timezone abbreviations for non-POSIX zones,
for example, CEST, you will need to update your code to manually map that abbreviation to a valid zone
name. Timezone abbreviations are only supported if they are POSIX timezones in the Olson timezone database.

### Added
- Added CHANGELOG
- Add Date.from clause to handle Phoenix datetime_select changeset
### Changed
- Timezone abbreviation handling is now only valid for POSIX/Olson timezone names.
- Some small optimizations
### Deprecated
- N/A
### Removed
- Timezone abbreviation handling for non-POSIX/Olson timezone names
### Fixed
- Timezone abbreviation handling (was previously non-deterministic/incorrect)
- Disable tzdata's auto-update during compilation
- Usage of imperative if
