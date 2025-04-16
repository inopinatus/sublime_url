const sublimeTextBinary = '/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function run(argv) {
	// Parse the interesting components
	const url = argv[0]["URL"]
	const query = url.split('?', 2)[1];
	const paramPairs = query.split('&').map(arg => arg.split('=', 2))
	const params = paramPairs.reduce((acc, [key, value]) => { acc[key] = decodeURIComponent(value); return acc; }, {})
	const file = params.url.replace(/^file:\/\//, "");

	// Test file existence
	let isDirectory = Ref();
	const fileExists = $.NSFileManager.defaultManager.fileExistsAtPathIsDirectory(file, isDirectory);

	if (fileExists && isDirectory[0] !== 1) {
		// Safely call the binary using Foundation framework
		let task = $.NSTask.alloc.init
		task.launchPath = sublimeTextBinary
		let column = params.column;
		let line = params.line || (column ? 1 : undefined); // normalize line to 1 if column is present
		let path = [file, line, column].filter(v => v).join(":");
		task.arguments = [path]
		task.launch
	} else {
		app.displayAlert(`File not found: ${file}`)
	}
}

