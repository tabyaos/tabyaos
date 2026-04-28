package runner

import "context"

// Report is a generic compliance report result.
type Report struct {
	Tool    string `json:"tool"`
	Version string `json:"version"`
	// RawJSON contains the tool's native JSON output.
	RawJSON []byte `json:"raw_json"`
}

// RunKubeBench executes kube-bench against the current node and returns
// the JSON report. Requires kube-bench to be installed and the caller
// to have sufficient privileges to read kubelet config.
func RunKubeBench(_ context.Context) (Report, error) {
	panic("not implemented: RunKubeBench — install kube-bench and implement exec wrapper")
}
