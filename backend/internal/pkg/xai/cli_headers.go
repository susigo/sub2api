package xai

import "net/http"

// Free/Build cli-chat-proxy rejects requests without a Grok CLI client version
// (HTTP 426: "Your Grok CLI version (none) is outdated...").
// Keep these aligned with official grok-shell / CPA xai auth headers.
const (
	DefaultCLIClientVersion    = "0.2.93"
	DefaultCLIClientIdentifier = "grok-shell"
	DefaultCLIUserAgent        = "grok-shell/" + DefaultCLIClientVersion + " (linux; x86_64)"
	DefaultCLITokenAuth        = "xai-grok-cli"
)

// ApplyCLIClientHeaders sets the headers required by cli-chat-proxy.grok.com.
func ApplyCLIClientHeaders(header http.Header) {
	if header == nil {
		return
	}
	header.Set("User-Agent", DefaultCLIUserAgent)
	header.Set("x-grok-client-version", DefaultCLIClientVersion)
	header.Set("x-grok-client-identifier", DefaultCLIClientIdentifier)
	header.Set("x-xai-token-auth", DefaultCLITokenAuth)
	header.Set("x-authenticateresponse", "authenticate-response")
}
