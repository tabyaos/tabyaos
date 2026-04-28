package cmd

import (
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "tabya-attest",
	Short: "Tabya compliance evidence CLI",
	Long: `tabya-attest generates, signs, and bundles kube-bench and InSpec
compliance evidence for Kubernetes worker nodes hardened with TabyaOS.

Every build produces a Cosign-signed evidence bundle containing:
  - kube-bench results (CIS Kubernetes Benchmark)
  - InSpec report (TabyaOS control verification)
  - CycloneDX SBOM reference
  - Control mapping cross-reference CSV`,
}

// Execute is the main entry point called from main.go.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().StringP("output", "o", ".", "Output directory for evidence bundle")
	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "Verbose output")
}
