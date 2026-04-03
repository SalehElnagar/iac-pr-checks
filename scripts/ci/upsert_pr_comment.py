#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


API_ROOT = "https://api.github.com"


def request_json(method: str, url: str, token: str, payload: dict | None = None) -> dict | list:
    body = None
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if payload is not None:
        body = json.dumps(payload).encode()
        headers["Content-Type"] = "application/json"

    request = urllib.request.Request(url, data=body, headers=headers, method=method)
    with urllib.request.urlopen(request) as response:
        return json.loads(response.read().decode())


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True)
    parser.add_argument("--pr", required=True, type=int)
    parser.add_argument("--marker", required=True)
    parser.add_argument("--body-file", required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        raise SystemExit("GITHUB_TOKEN is required")

    body = Path(args.body_file).read_text()
    comments_url = f"{API_ROOT}/repos/{args.repo}/issues/{args.pr}/comments?per_page=100"
    comments = request_json("GET", comments_url, token)

    existing = next(
        (comment for comment in comments if args.marker in comment.get("body", "")),
        None,
    )

    if existing:
        update_url = f"{API_ROOT}/repos/{args.repo}/issues/comments/{existing['id']}"
        request_json("PATCH", update_url, token, {"body": body})
        print(f"Updated PR comment {existing['id']}")
    else:
        create_url = f"{API_ROOT}/repos/{args.repo}/issues/{args.pr}/comments"
        request_json("POST", create_url, token, {"body": body})
        print(f"Created PR comment on #{args.pr}")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except urllib.error.HTTPError as exc:
        sys.stderr.write(exc.read().decode())
        raise
