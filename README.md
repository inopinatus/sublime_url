# Sublime Text URL handler

A URL handler for **Sublime Text 3** on Mac OSX. Made using JavaScript for Automation. Tested on Mac OS Sierra 10.12.6.  Implements a Sublime Text variant of the [TextMate URL scheme](http://blog.macromates.com/2007/the-textmate-url-scheme/).

## Installation

- Download the current release: [SublimeUrl-1.0.zip](https://github.com/inopinatus/sublime_url/releases/download/v1.0/SublimeUrl-v1.0.zip)
- Extract SublimeUrl.app and place in your user **Applications** directory.
- Run once to register the handler (this app isn't signed, so you'll probably have to right-click and select "Open").

## Uninstallation

Just delete the app.

## How to use

Have your debugging tool/exception handling produce URLs in the following format:  
`subl://open?url=file://{{file}}&line={{line}}&column={{column}}`

Examples:
- `subl://open?url=file:///path/to/file.js&line=19&column=4`
- `subl://open?url=file:///path/to/other.css&line=127`

`url` is required and the file must exist or an error is given.  SublimeUrl expects to find Sublime Text in `/Applications/Sublime Text.app`.

## Sublime Text and Ruby on Rails errors

This add-on was developed specifically for use with the [Better Errors](https://github.com/charliesome/better_errors) gem although it should work with anything that follows the specified URL format.  See the [Better Errors Wiki](https://github.com/charliesome/better_errors/wiki) for more information.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/inopinatus/sublime_url.

## History

#### Version 1.0
This project was written from scratch as a drop-in replacement for the *Subl* handler by [Dave Houlbrooke](https://github.com/dhoulb) which has since been retired.

## License

This code is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
