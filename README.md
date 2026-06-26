# Sublime Text URL handler

A URL handler for **Sublime Text 4** on macOS.

Implements a Sublime Text variant of the [TextMate URL scheme](http://blog.macromates.com/2007/the-textmate-url-scheme/).

Made using JavaScript for Automation.  Originally written for Mac OS Sierra 10.12.6, and still works with Tahoe (26.5) as of July 2026.

## Installation

- Download the [latest release](https://github.com/inopinatus/sublime_url/releases/latest).
- Extract SublimeUrl.app and place in your user Applications directory.

## Uninstallation

Just delete the app.

## How to use

### Handling Ruby on Rails errors

This utility was developed specifically for use with the [Better Errors](https://github.com/charliesome/better_errors) gem although it should work with anything that follows the specified URL format.  See the [Better Errors Wiki](https://github.com/charliesome/better_errors/wiki) for more information.  To configure it explicitly, I suggest:

```ruby
# config/environments/development.rb
Rails.application.configure do
  # ...
  if defined?(BetterErrors)
    BetterErrors.editor = :sublime
  end
end
```

### Everything else

Have your debugging tool/exception handling produce URLs in the following format:  
`subl://open?url={{encoded_file_url}}&line={{line}}&column={{column}}`

`url` is required and the file must exist or an error is given.  `line` and `column` are optional, with graceful fallback when omitted. Encode `url` with [`application/x-www-form-urlencoded` serialization](https://url.spec.whatwg.org/#urlencoded-serializing).

Examples:
- `file:///path/to/model.rb`, line 19:  
  `subl://open?url=file%3A%2F%2F%2Fpath%2Fto%2Fmodel.rb&line=19`
- `file:///path/to/C++ examples/main.cc`, line 127, column 4:  
  `subl://open?url=file%3A%2F%2F%2Fpath%2Fto%2FC%2B%2B+examples%2Fmain.cc&line=127&column=4`

## Troubleshooting

**`subl://` links stop working after moving or replacing the app.**
macOS LaunchServices may still point at the old copy — re-register it:

```
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/SublimeUrl.app
```

**"Sublime Text not found" alert.**
Install Sublime Text, then open it once so macOS registers the app with LaunchServices.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/inopinatus/sublime_url.

Useful make targets:

```
make            # default, assemble build/SublimeUrl.app
make build      # as above
make package    # produce a notarised release zip (but see below)
make clean      # remove build/
make hooks      # install the pre-commit check
```

The default build is ad-hoc signed. Building a release package requires an Apple codesigning ID that can notarise it in `SIGN_IDENTITY` e.g.

`SIGN_IDENTITY="Developer ID Application: You (TEAMID)" make package`

Ad-hoc and self-signed identities can't be notarized, so without this, make targets `verify`, `notarize` and `package` will fail.

### Release-time handy commands

| Command | Description |
| ------- | ----------- |
| `security find-identity -v -p codesigning` | list current codesigning identities
| `xcrun notarytool store-credentials SublimeUrl --apple-id you@example.com --team-id TEAMID` | save a one-time app password for notarising SublimeUrl |
| `xcrun notarytool history --keychain-profile SublimeUrl` | review submission history |

## History

#### Version 1.2
Decode urlencoded serialization correctly, locate Sublime Text via LaunchServices, add behavioural guards, switch to reproducible build from source, and notarize the release.

#### Version 1.1
Update to resolve misbehaviour when the column parameter is not defined. Fix from [Matthias Portzel](https://github.com/MatthiasPortzel).

#### Version 1.0
This project was written from scratch as a drop-in replacement for the *Subl* handler by [Dave Houlbrooke](https://github.com/dhoulb) which has since been retired.

## License

This code is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
