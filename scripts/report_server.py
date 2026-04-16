#!/usr/bin/env python3
from __future__ import annotations

import json
import mimetypes
from datetime import datetime, timezone
from email.utils import formatdate
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import quote, urlparse
import os


REPO_ROOT = Path(__file__).resolve().parent.parent
REPORTS_ROOT = REPO_ROOT / "reports"
HOST = "0.0.0.0"
try:
    PORT = int(os.environ.get("REPORTS_PORT", "8081"))
    if not 1 <= PORT <= 65535:
        raise ValueError("port out of range")
except (ValueError, TypeError):
    PORT = 8081


class ReportRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(REPORTS_ROOT), **kwargs)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/reports":
            self._handle_reports_api()
            return
        super().do_GET()

    def _handle_reports_api(self):
        payload = {
            "reports": self._collect_reports(),
            "generatedAt": datetime.now(timezone.utc).isoformat(),
        }
        body = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def list_directory(self, path):
        self.send_error(HTTPStatus.FORBIDDEN, "Directory listing is disabled")
        return None

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def send_head(self):
        parsed = urlparse(self.path)
        if parsed.path == "/":
            saved_path = self.path
            self.path = "/index.html"
            try:
                return super().send_head()
            finally:
                self.path = saved_path
        return super().send_head()

    def translate_path(self, path):
        translated = super().translate_path(path)
        resolved = Path(translated).resolve()
        try:
            resolved.relative_to(REPORTS_ROOT.resolve())
        except ValueError:
            return str(REPORTS_ROOT / "index.html")
        return str(resolved)

    def guess_type(self, path):
        if path.endswith(".json"):
            return "application/json"
        return super().guess_type(path)

    def _collect_reports(self):
        reports = []
        root = REPORTS_ROOT.resolve()
        for file_path in sorted(root.rglob("*")):
            if not file_path.is_file():
                continue
            if file_path.name.startswith("."):
                continue
            relative_path = file_path.relative_to(root)
            if relative_path.as_posix() == "index.html":
                continue
            stat = file_path.stat()
            reports.append(
                {
                    "name": relative_path.name,
                    "path": relative_path.as_posix(),
                    "url": quote(relative_path.as_posix()),
                    "sizeBytes": stat.st_size,
                    "modifiedAt": datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc).isoformat(),
                    "modifiedAtHttp": formatdate(stat.st_mtime, usegmt=True),
                    "contentType": mimetypes.guess_type(file_path.name)[0] or "application/octet-stream",
                }
            )

        reports.sort(key=lambda item: item["modifiedAt"], reverse=True)
        return reports


def main():
    REPORTS_ROOT.mkdir(parents=True, exist_ok=True)
    server = ThreadingHTTPServer((HOST, PORT), ReportRequestHandler)
    print(f"[reports] dynamic server running on http://{HOST}:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
