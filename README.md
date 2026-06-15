<img src="/cyberanrhy/gemini-web2api/raw/main/preview.jpg" alt="Gemini Web2API screenshot" style="max-width: 100%;">

# Gemini Web2API

OpenAI-compatible proxy for [Gemini](https://gemini.google.com) Web API.

Converts standard `/v1/chat/completions` requests to Gemini internal `StreamGenerate` endpoint. Works via cookie-based auth — no API key needed.

## Features

- OpenAI-compatible `/v1/chat/completions`
- Streaming (SSE) and non-streaming
- Models: `gemini-3.5-flash`, `gemini-3.5-flash-thinking`, `gemini-flash-lite`, `gemini-pro`, `gemini-auto`
- Tool calling (function calling) support
- OpenAI Responses API (`/v1/responses`) for Codex CLI
- Google AI native API (`:generateContent`, `:streamGenerateContent`)
- Automatic rate-limit retry with xsrf token recovery
- CORS enabled

## Requirements

- **Python 3.10+**
- `pip install -r requirements.txt` (just `requests` + optional `httpx`)
- **Firefox** with [cookies.txt](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/) extension
- **Optional:** VPN/proxy if Google blocks your IP (Gemini sometimes blocks datacenter IPs)

## Setup (step by step)

### 1. Clone & install

```bash
git clone https://github.com/YOUR_USERNAME/gemini-web2api.git
cd gemini-web2api
pip install -r requirements.txt
```

### 2. Copy config

```bash
cp config.json.example config.json
```

### 3. Export cookies

1. Open [Gemini](https://gemini.google.com/app) **in Firefox** and log in
2. Install [cookies.txt](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/) extension (if not already)
3. Click the extension icon → **Export** → save as `cookie.txt`
4. Put `cookie.txt` in the project directory (alongside `gemini_web2api.py`)

> The file must be in **Netscape format** (tabs, not spaces). The cookies.txt extension exports this by default.

### 4. Get xsrf token

The proxy needs an `xsrf_token` to authenticate requests to Gemini. Run:

```bash
python3 -c "
from gemini_web2api import gemini_init, load_config
load_config()
gemini_init()
print('OK — xsrf_token set')
"
```

This extracts the token from Gemini's page source automatically.

**Alternative (manual):**
1. Open `https://gemini.google.com/app` in Firefox
2. View page source (Ctrl+U)
3. Search for `"SNlM0e"`
4. Copy the value — it looks like `"48448350.xxxxx"`
5. Paste it into `config.json` under `"xsrf_token"`

### 5. Run

```bash
python3 gemini_web2api.py
```

Expected output:
```
* Proxy server running on http://0.0.0.0:8081
* Logged in
```

If you see **401 / 403** — cookies expired. Re-export from Firefox and run `gemini_init()` again.

### 6. Verify it works

```bash
# Check server is alive
curl -s http://localhost:8081/v1/models | head -c 200

# Send a message (non-streaming)
curl -s -X POST http://localhost:8081/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemini-3.5-flash","messages":[{"role":"user","content":"Say hello in 3 words"}]}'

# Send a message (streaming)
curl -s -N -X POST http://localhost:8081/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemini-3.5-flash","messages":[{"role":"user","content":"Count to 5"}],"stream":true}'
```

## Models

| ID | Description | Notes |
|---|---|---|
| `gemini-3.5-flash` | Fast, general purpose | Recommended |
| `gemini-3.5-flash-thinking` | Deep reasoning, long output | ~20k characters |
| `gemini-flash-lite` | Lightweight, fastest | Good for simple tasks |
| `gemini-pro` | Pro model | May be limited by subscription |
| `gemini-auto` | Auto-select | Picks best model |

> Available models depend on your Gemini subscription. Some models may require Gemini Advanced.

## Configuration reference

| Field | Default | Description |
|---|---|---|
| `port` | `8081` | Server port |
| `host` | `"0.0.0.0"` | Bind address |
| `xsrf_token` | `""` | Auth token from `SNlM0e` in Gemini page source |
| `gemini_bl` | `"boq_chat_202..."` | Build version — matches current Gemini frontend |
| `proxy` | `null` | HTTP proxy for upstream (Gemini) |
| `log_requests` | `false` | Log request/response bodies |
| `api_keys` | `[]` | Restrict access (empty = anyone can use) |

## How it works

1. You send a standard OpenAI chat request to `/v1/chat/completions`
2. The proxy translates it to Gemini's internal API (`StreamGenerate`)
3. Sends the request with your cookies and xsrf token
4. Streams the response back (or returns as JSON)
5. If rate-limited, retries automatically with exponential backoff

## Usage with OpenCode

```json
{
  "provider": {
    "gemini": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Gemini Local",
      "options": {
        "baseURL": "http://localhost:8081/v1",
        "apiKey": "sk-proxy",
        "timeout": 120000
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

## FAQ

### Q: 401 / 403 Forbidden
**Cookies expired.** Re-export from Firefox and run `gemini_init()` again.

### Q: "SNlM0e not found" / xsrf_token empty
Google changed the page structure, or the token extraction failed. Set `xsrf_token` manually.

### Q: Rate limited (1150/1152 or e:3/e:4/e:8)
The proxy retries automatically with delays (up to 5 attempts). If persistent, wait 5-10 minutes between requests.

### Q: e:33 / e:37 — CAPTCHA required
Google wants you to prove you're human. Open Gemini in your browser, solve the CAPTCHA, then restart the proxy.

### Q: e:38 / e:40 / e:49 / e:52 — session invalid
Session expired. Export **fresh cookies** from Firefox.

### Q: "подозрительный трафик" / "suspicious traffic"
Google blocked your IP. Switch to a residential IP or disable VPN. Gemini blocks most datacenter IPs.

### Q: Model not working / `gemini_bl` outdated
The `gemini_bl` version in config.json must match the current Gemini frontend build. To update:
1. Open Gemini in Firefox
2. Inspect the page source for `"bl":"boq_chat_202..."`
3. Copy the new value into `config.json`

### Q: Server works locally but not over network
Set `"api_keys"` in config.json to restrict access. The server binds `0.0.0.0` by default.

## Files

```
gemini-web2api/
├── gemini_web2api.py      # Proxy server
├── config.json.example    # Configuration template
├── requirements.txt       # Python dependencies
├── start.sh               # Start script
├── cookie.txt             # Cookies (gitignored, you create this)
├── config.json            # Active config (gitignored, from .example)
├── README.md
└── LICENSE
```

## License

MIT
