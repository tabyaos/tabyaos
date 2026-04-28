package bundle

import (
	"context"

	"github.com/tabyaos/tabya-attest/internal/runner"
)

// Sign writes the evidence bundle to outputDir and produces a Cosign keyless
// OIDC signature over the evidence manifest. Returns the path to the bundle
// directory on success.
//
// Signing uses Cosign's keyless mode (OIDC via GitHub Actions or sigstore
// OIDC provider). In air-gapped environments, pass --key to cosign sign
// with a local key — this is not yet exposed in the CLI but is planned.
func Sign(_ context.Context, outputDir string, kubebench runner.Report, inspec runner.Report) (string, error) {
	panic("not implemented: Sign — implement Cosign keyless signing and bundle manifest writer. outputDir: " + outputDir)
}
