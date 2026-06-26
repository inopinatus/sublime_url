# SublimeUrl build targets
#
#   make            assemble + re-seal a signed app
#   make build      identical to above
#   make verify     assert that app is signed for distribution (Developer ID)
#   make notarize   submit to Apple and staple the ticket into the bundle
#   make package    produce the release .zip
#   make clean      remove build/
#   make hooks      install the git pre-commit check
#
# The build is ad-hoc signed, unless a signing identity is supplied:
#
#   make SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" package
#

SHELL := /bin/bash

APP       := build/SublimeUrl.app
CONTENTS  := $(APP)/Contents
RES       := $(CONTENTS)/Resources
SCRIPTS   := $(RES)/Scripts

APPLET    := $(CONTENTS)/MacOS/applet
SKELETON  := build/.skeleton.stamp
SIGNREQ   := build/.sign-request
SEAL      := $(CONTENTS)/_CodeSignature/CodeResources
NOTARIZED := build/.notarized.stamp
SUBMIT    := build/.submit.zip

VERSION   := $(shell /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' src/Info.plist)
RELEASE   := build/SublimeUrl-v$(VERSION).zip

LSREGISTER ?= /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

NOTARY_PROFILE ?= SublimeUrl

SIGN_IDENTITY ?=
ifeq ($(strip $(SIGN_IDENTITY)),)
  IDENTITY     := -
  ENTITLEMENTS :=
  SIGN_OPTS    :=
else
  IDENTITY     := $(SIGN_IDENTITY)
  ENTITLEMENTS := src/entitlements.plist
  SIGN_OPTS    := --options runtime --timestamp --entitlements $(ENTITLEMENTS)
endif

.DEFAULT_GOAL := build
.DELETE_ON_ERROR:
.PHONY: build verify notarize package clean hooks help FORCE

# ---- assemble -------------------------------------------------------------
$(SKELETON): src/main.applescript
	@mkdir -p $(@D)
	@rm -rf $(APP)
	osacompile -o $(APP) $<
	@rm -f $(CONTENTS)/Info.plist $(RES)/applet.icns
	@test -x $(APPLET)
	@touch $@

$(SCRIPTS)/url-handler.scpt: src/url-handler.jxa.js $(SKELETON)
	@mkdir -p $(@D)
	osacompile -l JavaScript -o $@ $<

# Our bundle metadata and icon.
$(CONTENTS)/Info.plist: src/Info.plist $(SKELETON)
	@mkdir -p $(@D)
	cp $< $@

$(RES)/sublime_url.icns: src/sublime_url.icns $(SKELETON)
	@mkdir -p $(@D)
	cp $< $@

# ---- seal -----------------------------------------------------------------
$(SIGNREQ): FORCE
	@mkdir -p $(@D)
	@req='$(IDENTITY) $(SIGN_OPTS)'; [ "$$req" = "$$(cat $@ 2>/dev/null)" ] || printf '%s\n' "$$req" >$@

$(SEAL): $(SCRIPTS)/url-handler.scpt $(CONTENTS)/Info.plist $(RES)/sublime_url.icns $(ENTITLEMENTS) $(SIGNREQ) $(SKELETON)
	codesign --force $(SIGN_OPTS) --sign "$(IDENTITY)" $(APP)
	@echo "signed $(APP) ($$(lipo -archs $(APPLET)))"

build: $(SEAL)

# ---- verify & notarize ----------------------------------------------------
define VERIFY_APP
codesign --verify --strict --verbose=2 $(APP)
@info="$$(codesign -dvv $(APP) 2>&1)"; printf '%s\n' "$$info"; ok=1; \
case "$$info" in *Signature=adhoc*) echo "  ✗ ad-hoc signature cannot be notarized"; ok=0;; esac; \
printf '%s\n' "$$info" | grep -q 'Authority=Developer ID Application:' || { echo "  ✗ not signed with a Developer ID Application identity"; ok=0; }; \
printf '%s\n' "$$info" | grep -q '(runtime)'                           || { echo "  ✗ hardened runtime not enabled"; ok=0; }; \
printf '%s\n' "$$info" | grep -q 'Timestamp='                          || { echo "  ✗ no secure timestamp"; ok=0; }; \
[ "$$ok" = 1 ] || { echo "verify: $(APP) is not distributable"; exit 1; }
@echo "  ✓ $(APP): Developer ID, hardened, timestamped"
endef

verify: $(SEAL)
	$(VERIFY_APP)

$(NOTARIZED): $(SEAL)
	$(VERIFY_APP)
	ditto -c -k --keepParent $(APP) $(SUBMIT)
	xcrun notarytool submit $(SUBMIT) --keychain-profile "$(NOTARY_PROFILE)" --wait
	xcrun stapler staple $(APP)
	xcrun stapler validate $(APP)
	spctl -a -vvv -t exec $(APP)
	@rm -f $(SUBMIT)
	@touch $@

notarize: $(NOTARIZED)

# ---- package --------------------------------------------------------------
$(RELEASE): $(NOTARIZED) Makefile
	ditto --norsrc -c -k --keepParent $(APP) $@
	@echo "packaged $@ ($$(du -h $@ | cut -f1))"

package: $(RELEASE)

# ---- housekeeping ---------------------------------------------------------
clean:
	-[ -e "$(APP)" ] && "$(LSREGISTER)" -u "$(APP)"
	$(RM) -r build

hooks: bin/pre-commit.sh
	install $< .git/hooks/pre-commit

help:
	@echo 'targets: build (default), verify, notarize, package, clean, hooks'

FORCE:
