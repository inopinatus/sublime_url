#!/bin/bash

SCPTDIR=SublimeUrl.app/Contents/Resources/Scripts
DECOMPILER=/usr/bin/osadecompile

$DECOMPILER "${SCPTDIR}/jsHandler.scpt" > "src/jsHandler.scpt.js"
$DECOMPILER "${SCPTDIR}/main.scpt" > "src/main.scpt.script"
