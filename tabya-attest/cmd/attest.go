package cmd

import (
	"context"
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/tabyaos/tabya-attest/internal/bundle"
	"github.com/tabyaos/tabya-attest/internal/runner"
)

var attestCmd = &cobra.Command{
	Use:   "attest",
	Short: "Run compliance checks and produce a signed evidence bundle",
	Long: `attest runs kube-bench and InSpec against the current node,
collects the results, and produces a Cosign-signed evidence bundle.

The bundle is written to the --output directory and contains:
  - kube-bench-results.json
  - inspec-report.json
  - evidence-manifest.json  (SHA-256 digests of all artifacts)
  - cosign.bundle           (keyless signature over the manifest)`,
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx := context.Background()
		outputDir, _ := cmd.Flags().GetString("output")
		inspecProfile, _ := cmd.Flags().GetString("inspec-profile")

		fmt.Fprintln(os.Stderr, "→ Running kube-bench...")
		kbReport, err := runner.RunKubeBench(ctx)
		if err != nil {
			return fmt.Errorf("kube-bench failed: %w", err)
		}

		fmt.Fprintln(os.Stderr, "→ Running InSpec...")
		inspecReport, err := runner.RunInspec(ctx, inspecProfile)
		if err != nil {
			return fmt.Errorf("inspec failed: %w", err)
		}

		fmt.Fprintln(os.Stderr, "→ Signing evidence bundle...")
		bundlePath, err := bundle.Sign(ctx, outputDir, kbReport, inspecReport)
		if err != nil {
			return fmt.Errorf("bundle signing failed: %w", err)
		}

		fmt.Fprintf(os.Stderr, "✓ Evidence bundle written to: %s\n", bundlePath)
		return nil
	},
}

func init() {
	rootCmd.AddCommand(attestCmd)
	attestCmd.Flags().StringP("inspec-profile", "p", "tabyaos-baseline", "InSpec profile to run")
}
