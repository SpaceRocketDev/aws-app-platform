from flask import Flask, Response
from prometheus_client import Counter, Gauge, Histogram, generate_latest, CONTENT_TYPE_LATEST
import random, time, threading, html, os

app = Flask(__name__)

REQS = Counter("hello_requests_total", "Number of hello ticks")
TEMP = Gauge("hello_temperature_celsius", "Fake temperature reading")
LAT  = Histogram("hello_latency_seconds", "Fake work latency")

ready = {"ok": False}
BUMP_FILE = os.path.join(os.path.dirname(__file__), "bump.txt")

def last_bump_line(path=BUMP_FILE) -> str:
    try:
        with open(path, "r", encoding="utf-8") as f:
            # Read all lines, pick the last non-empty
            lines = [ln.rstrip("\n") for ln in f.readlines()]
            for ln in reversed(lines):
                if ln.strip():
                    return ln
            return "(bump.txt is empty)"
    except FileNotFoundError:
        return "(bump.txt not found)"

def worker():
    # Warm up
    time.sleep(1)
    ready["ok"] = True
    while True:
        REQS.inc()
        TEMP.set(random.uniform(20.0, 30.0))
        with LAT.time():
            time.sleep(random.uniform(0.05, 0.25))
        time.sleep(1)

@app.route("/")
def root():
    bump = last_bump_line()
    # Simple HTML, escape content from file
    body = f"""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Hello Demo</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body {{ font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; margin: 2rem; }}
          .card {{ border: 1px solid #ddd; border-radius: 12px; padding: 1.25rem; }}
          .muted {{ color: #555; }}
        </style>
      </head>
      <body>
        <h1>Hello Demo</h1>
        <div class="card">
          <div class="muted">Last bump</div>
          <div><strong>{html.escape(bump)}</strong></div>
        </div>
        <p><a href="/metrics">/metrics</a> | <a href="/-/ready">/-/ready</a></p>
      </body>
    </html>
    """
    return body, 200, {"Content-Type": "text/html; charset=utf-8"}

@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route("/-/ready")
def readyz():
    return ("ok", 200) if ready["ok"] else ("starting", 503)

if __name__ == "__main__":
    threading.Thread(target=worker, daemon=True).start()
    app.run(host="0.0.0.0", port=9091)
