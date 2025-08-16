package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"heimdall-cli/commands"
)

var (
	// Version information (set during build)
	Version   = "1.0.0"
	BuildTime = "unknown"
	GitCommit = "unknown"
)

// rootCmd represents the base command
var rootCmd = &cobra.Command{
	Use:   "heimdall-cli",
	Short: "Heimdall CLI - Shell configuration management",
	Long: `Heimdall CLI is a command-line tool for managing the Heimdall shell configuration.
It provides intelligent configuration management with automatic discovery, validation,
migration, and property injection capabilities.

Configuration is stored at ~/.config/heimdall/shell.json and consumed by Quickshell.`,
	Version: Version,
}

// versionCmd shows version information
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Show version information",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Heimdall CLI %s\n", Version)
		fmt.Printf("Build Time: %s\n", BuildTime)
		fmt.Printf("Git Commit: %s\n", GitCommit)
		fmt.Printf("Go Version: %s\n", "1.21")
	},
}

func init() {
	// Add commands
	rootCmd.AddCommand(commands.ConfigCmd)
	rootCmd.AddCommand(versionCmd)

	// Set version template
	rootCmd.SetVersionTemplate(`{{.Version}}`)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
