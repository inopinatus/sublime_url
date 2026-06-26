ObjC.import('AppKit')

const sublimeTextBundleIds = ['com.sublimetext.4', 'com.sublimetext.3']
const app = Application.currentApplication();
app.includeStandardAdditions = true;

function findSublimeTextBinary() {
	const fileManager = $.NSFileManager.defaultManager

	for (let i = 0; i < sublimeTextBundleIds.length; i++) {
		const bundleId = sublimeTextBundleIds[i]
		const appURL = $.NSWorkspace.sharedWorkspace.URLForApplicationWithBundleIdentifier(bundleId)
		if (appURL.isNil()) continue

		const sublURL = appURL.URLByAppendingPathComponent('Contents/SharedSupport/bin/subl')
		const subl = ObjC.unwrap(sublURL.path)
		if (fileManager.isExecutableFileAtPath(subl)) return subl
	}

	throw 'Sublime Text not found'
}

function run(argv) {
	try {
		// Parse the interesting components
		const url = argv[0]["URL"]
		const query = url.split('?', 2)[1];
		if (!query) throw `Malformed URL (no query): ${url}`;
		const paramPairs = query.split('&').map(arg => arg.split('='))
		const params = paramPairs.reduce((acc, [key, ...value]) => { acc[key] = decodeURIComponent(value.join('=').replace(/\+/g, ' ')); return acc; }, {})
		if (!params.url) throw "Missing required 'url' parameter";
		const file = params.url.replace(/^file:\/\//, "");
		if (file[0] !== '/') throw `Not an absolute file path: ${params.url}`;

		// Test file existence
		let isDirectory = Ref();
		const fileExists = $.NSFileManager.defaultManager.fileExistsAtPathIsDirectory(file, isDirectory);
		if (!fileExists || isDirectory[0]) throw `File not found: ${file}`;
		const sublimeTextBinary = findSublimeTextBinary()

		// Safely call the binary using Foundation framework
		let task = $.NSTask.alloc.init
		task.launchPath = sublimeTextBinary
		let column = params.column;
		let line = params.line || (column ? 1 : undefined); // normalize line to 1 if column is present
		let path = [file, line, column].filter(v => v).join(":");
		task.arguments = [path]
		task.launch
	} catch (e) {
		app.displayAlert(e.message || e)
	}
}
