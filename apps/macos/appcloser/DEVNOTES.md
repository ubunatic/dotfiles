
# MacOS Service Development Notes

## Technology Options
- A) Applescript -> create plist file and use `osascript` `path/to/appname` as XML args
- B) Swift -> can we build services without XCode and without a lot of boiler plate?
- C) Other system services SDK in any lang -> needs research

If there is a Swift/Python/Go/Rust SDK that allows to code system services
without a lot of boilerplate this would be the way to go. Applescript is only a band aid.

## Requirements
- must be able to gain permissions to watch and close apps
- must be able to install, update, and run a service
- must run and compile via VSCode
- should be testable using std test frameworks
- should integerate in the std service logger
