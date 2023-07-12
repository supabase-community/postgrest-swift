PLATFORM ?= iOS Simulator,name=iPhone 14 Pro Max

.PHONY: test-library
test-library:
	xcodebuild test \
		-scheme PostgREST \
		-destination platform="$(PLATFORM)"

.PHONY: format
format:
	swift format -i -r ./Sources ./Tests ./Package.swift

.PHONY: supabase-up
supabase-up: supabase-down
	supabase start && supabase db reset

.PHONY: supabase-down
supabase-down:
	supabase stop
