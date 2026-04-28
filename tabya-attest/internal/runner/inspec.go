package runner

import "context"

// RunInspec executes an InSpec profile against the local node and returns
// the JSON report. Requires InSpec/Chef Inspec to be installed.
// profile is the InSpec profile path or URL (e.g. "tabyaos-baseline" or
// "https://github.com/tabyaos/tabyaos/tree/main/tests/inspec/tabyaos-baseline").
func RunInspec(_ context.Context, profile string) (Report, error) {
	panic("not implemented: RunInspec — install Chef InSpec and implement exec wrapper for profile: " + profile)
}
