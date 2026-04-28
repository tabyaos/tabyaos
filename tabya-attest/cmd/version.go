package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// Version is set at build time via ldflags: -X github.com/tabyaos/tabya-attest/cmd.Version=v0.1.0
var Version = "dev"

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print tabya-attest version",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("tabya-attest %s\n", Version)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
