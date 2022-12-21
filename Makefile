PLATFORM_IOS = iOS Simulator,name=iPhone 14 Pro Max
PLATFORM_MACOS = macOS
PLATFORM_TVOS = tvOS Simulator,name=Apple TV

.PHONY: test-library
test-library:
	for platform in "$(PLATFORM_IOS)" "$(PLATFORM_MACOS)" "$(PLATFORM_TVOS)"; do \
		xcodebuild test \
			-scheme PostgREST \
			-destination platform="$$platform" \
			-derivedDataPath .deriveddata || exit 1; \
	done;

.PHONY: format
format:
	swiftformat .

.PHONY: supabase-up
supabase-up: supabase-down
	supabase start && supabase db reset

.PHONY: supabase-down
supabase-down:
	supabase stop
