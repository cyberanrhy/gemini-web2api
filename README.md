# Gemini Web2API

OpenAI-compatible proxy for [Gemini](https://gemini.google.com) Web API.

Translate standard `/v1/chat/completions` requests to Gemini internal `StreamGenerate` endpoint. Bypasses Google's anti-bot protections via cookie-based authentication.

## Features

- OpenAI-compatible `/v1/chat/completions` endpoint
- Streaming (SSE) and non-streaming modes
- Multiple Gemini models: `gemini-3.5-flash`, `gemini-3.5-flash-thinking`, `gemini-flash-lite`, `gemini-pro`, `gemini-auto`
- Tool calling (function calling) support
- OpenAI Responses API (`/v1/responses`) for Codex CLI compatibility
- Google AI native API (`:generateContent`, `:streamGenerateContent`)
- Cookie-based auth (no API key required)
- Rate-limit retry with automatic xsrf token recovery
- CORS enabled

## Prerequisites

- Python 3.10+
- `requests` library
- Active Gemini session (cookies from logged-in browser)

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/gemini-web2api.git
cd gemini-web2api
pip install requests httpx
```

## Quick Start

### 1. Export cookies

1. Log in to [Gemini](https://gemini.google.com/app) in Firefox
2. Install extension [cookies.txt](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/)
3. Export cookies in **Netscape format**
4. Save as `cookie.txt` in the project directory

### 2. Init session

The proxy needs an xsrf token from Gemini. Run:

```bash
python3 -c "
from gemini_web2api import gemini_init, load_config, CONFIG
import json
with open('config.json') as f: CONFIG.update(json.load(f))
CONFIG['cookie_file'] = 'cookie.txt'
gemini_init()
print('xsrf_token:', CONFIG.get('xsrf_token'))
"
```

Or configure the `xsrf_token` manually (extract from `SNlM0e` in the HTML source of `gemini.google.com/app`).

### 3. Configure

```bash
cp config.json.example config.json
```

### 4. Run

```bash
bash start.sh
```

Or directly:

```bash
python3 gemini_web2api.py --cookie-file cookie.txt
```

Server starts on `http://0.0.0.0:8081`.

## API

### `GET /v1/models`

Returns available Gemini models.

### `POST /v1/chat/completions`

OpenAI-compatible chat completions endpoint.

**Request:**

```json
{
  "model": "gemini-3.5-flash",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"}
  ],
  "stream": false
}
```

**Response (non-streaming):**

```json
{
  "id": "chatcmpl-xxx",
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "Hi! How can I help?"
    }
  }]
}
```

**Streaming:** Server-Sent Events with `[DONE]` termination.

### `POST /v1/responses`

OpenAI Responses API compatible (for Codex CLI).

## Usage with OpenCode / AI SDK

```json
{
  "provider": {
    "gemini": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Gemini Local",
      "options": {
        "baseURL": "http://localhost:8081/v1",
        "apiKey": "sk-proxy",
        "timeout": 120000,
        "headerTimeout": 60000,
        "chunkTimeout": 110000
      },
      "models": {
        "gemini-3.5-flash": { "name": "Gemini 3.5 Flash" },
        "gemini-3.5-flash-thinking": { "name": "Gemini 3.5 Flash Thinking" },
        "gemini-flash-lite": { "name": "Gemini Flash Lite" }
      }
    }
  }
}
```

## Models

| ID | Description |
|---|---|
| `gemini-3.5-flash` | Fast general-purpose model |
| `gemini-3.5-flash-thinking` | Deep thinking, longest output (~20k chars) |
| `gemini-flash-lite` | Lightweight fast model |
| `gemini-pro` | Pro model alias |
| `gemini-auto` | Auto model selection |

## Cookie Refresh Script

For convenience, you can create a script to open Gemini for cookie export:

```bash
#!/bin/bash
firefox "https://gemini.google.com/app"
echo "After login, export cookies via cookies.txt extension"
echo "Save to: cookie.txt"
read -p "Press Enter when done..."
echo "Done"
```

## Troubleshooting / FAQ

### Q: 401 / 403 Forbidden
Cookies expired. Export fresh cookies from Gemini and restart.

### Q: "SNlM0e" not found
Run `gemini_init()` to refresh the xsrf token, or extract it manually from the page source.

### Q: Rate limited (1150/1152 or e:3/e:4/e:8)
The proxy retries automatically with delays. If persistent, wait a few minutes.

### Q: e:33 / e:37 (CAPTCHA required)
Open Gemini in your browser, solve the CAPTCHA, then restart the proxy.

### Q: e:38 / e:40 / e:49 / e:52 (session invalid)
Session expired. Export fresh cookies.

### Q: Model not working?
Check `gemini_bl` in config.json matches the current version on Gemini's page.

### Q: Proxy works locally but not over network?
By default the server binds `0.0.0.0`. Set `api_keys` in config for security.

### Q: Can I use this with curl?

```bash
curl -X POST http://localhost:8081/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemini-3.5-flash","messages":[{"role":"user","content":"Hello"}],"stream":true}'
```

## Files

```
gemini-web2api/
├── gemini_web2api.py      # Proxy server
├── config.json.example    # Configuration template
├── start.sh               # Start script
├── cookie.txt             # Netscape cookies (gitignored)
├── config.json            # Active config (gitignored)
├── README.md
└── LICENSE
```

## License

MIT
