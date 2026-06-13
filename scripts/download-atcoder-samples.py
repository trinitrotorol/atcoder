#!/usr/bin/env python3
import argparse
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from pathlib import Path


class SampleParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.in_heading = False
        self.heading_parts = []
        self.pending = None
        self.in_pre = False
        self.pre_parts = []
        self.pre_kind_number = None
        self.samples = {}

    def handle_starttag(self, tag, attrs):
        if tag in ("h3", "h4"):
            self.in_heading = True
            self.heading_parts = []
        elif tag == "pre":
            self.in_pre = True
            self.pre_parts = []
            self.pre_kind_number = self.pending

    def handle_endtag(self, tag):
        if tag in ("h3", "h4") and self.in_heading:
            self.in_heading = False
            self.pending = parse_sample_heading("".join(self.heading_parts))
        elif tag == "pre" and self.in_pre:
            self.in_pre = False
            if self.pre_kind_number:
                kind, number = self.pre_kind_number
                content = normalize_pre("".join(self.pre_parts))
                self.samples.setdefault(number, {})
                self.samples[number].setdefault(kind, content)
            self.pre_kind_number = None

    def handle_data(self, data):
        if self.in_heading:
            self.heading_parts.append(data)
        if self.in_pre:
            self.pre_parts.append(data)


class TaskLinkParser(HTMLParser):
    def __init__(self, contest, base_url):
        super().__init__(convert_charrefs=True)
        self.contest = contest
        self.base_url = base_url
        self.urls = []
        self.seen = set()

    def handle_starttag(self, tag, attrs):
        if tag != "a":
            return

        attrs = dict(attrs)
        href = attrs.get("href")
        if not href:
            return

        url = urllib.parse.urljoin(self.base_url, href)
        parsed = urllib.parse.urlparse(url)
        match = re.fullmatch(rf"/contests/{re.escape(self.contest)}/tasks/([^/]+)", parsed.path)
        if not match:
            return

        task = match.group(1)
        if task in self.seen:
            return

        self.seen.add(task)
        self.urls.append(url)


def parse_sample_heading(text):
    text = re.sub(r"\s+", " ", text).strip()

    patterns = (
        (r"^入力例\s*(\d+)$", "input"),
        (r"^出力例\s*(\d+)$", "output"),
        (r"^Sample Input\s*(\d+)$", "input"),
        (r"^Sample Output\s*(\d+)$", "output"),
    )

    for pattern, kind in patterns:
        match = re.match(pattern, text, re.IGNORECASE)
        if match:
            return kind, int(match.group(1))
    return None


def normalize_pre(text):
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    return text.strip("\n") + "\n"


def infer_task_target(url):
    parsed = urllib.parse.urlparse(url)
    match = re.search(r"/contests/([^/]+)/tasks/([^/]+)", parsed.path)
    if not match:
        raise ValueError("AtCoder task URL must look like https://atcoder.jp/contests/<contest>/tasks/<task>")

    contest = match.group(1)
    task = match.group(2)
    prefix = contest + "_"
    problem = task[len(prefix):] if task.startswith(prefix) else task
    problem = re.sub(r"[^0-9A-Za-z_+-]+", "_", problem).lower()
    return contest, problem


def infer_contest_target(url):
    parsed = urllib.parse.urlparse(url)
    match = re.fullmatch(r"/contests/([^/]+)(?:/tasks)?/?", parsed.path)
    if not match:
        raise ValueError(
            "AtCoder URL must look like https://atcoder.jp/contests/<contest>/tasks "
            "or https://atcoder.jp/contests/<contest>/tasks/<task>"
        )
    return match.group(1)


def infer_url_kind(url):
    parsed = urllib.parse.urlparse(url)
    if re.search(r"/contests/[^/]+/tasks/[^/]+", parsed.path):
        return "task"
    return "contest"


def load_cookie_header(root, cookie_file):
    cookie = os.environ.get("ATCODER_COOKIE", "").strip()
    if cookie:
        return cookie.removeprefix("Cookie:").strip()

    session = os.environ.get("ATCODER_REVEL_SESSION", "").strip()
    if session:
        return f"REVEL_SESSION={session}"

    path = Path(cookie_file)
    if not path.is_absolute():
        path = root / path
    if not path.exists():
        return None

    text = path.read_text(encoding="utf-8").strip()
    if not text:
        return None

    if "\n" in text:
        for line in text.splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            fields = line.split("\t")
            if len(fields) >= 7 and "atcoder.jp" in fields[0] and fields[-2] == "REVEL_SESSION":
                return f"REVEL_SESSION={fields[-1]}"

        text = " ".join(line.strip() for line in text.splitlines() if line.strip() and not line.startswith("#"))

    text = text.removeprefix("Cookie:").strip()
    if "=" in text:
        return text
    return f"REVEL_SESSION={text}"


def fetch_html(url, cookie_header=None):
    headers = {
        "User-Agent": "atcoder-local-sample-downloader/1.0",
        "Accept-Language": "ja,en;q=0.8",
    }
    if cookie_header:
        headers["Cookie"] = cookie_header

    request = urllib.request.Request(
        url,
        headers=headers,
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        charset = response.headers.get_content_charset() or "utf-8"
        return response.read().decode(charset, errors="replace")


def print_fetch_error(url, exc, cookie_header):
    if isinstance(exc, urllib.error.HTTPError) and exc.code == 404:
        print(f"failed to fetch AtCoder page: 404 Not Found: {url}", file=sys.stderr)
        if cookie_header:
            print("AtCoder returned 404 even with a cookie. Check contest registration and URL.", file=sys.stderr)
        else:
            print(
                "If you can open the page in your browser, save your AtCoder REVEL_SESSION "
                "to .atcoder-cookie or set ATCODER_REVEL_SESSION.",
                file=sys.stderr,
            )
        return

    print(f"failed to fetch AtCoder page: {exc}", file=sys.stderr)


def write_samples(root, contest, problem, samples):
    sample_dir = root / "contests" / contest / "sample"
    sample_dir.mkdir(parents=True, exist_ok=True)

    written = []
    complete_numbers = sorted(n for n, pair in samples.items() if "input" in pair)
    if not complete_numbers:
        raise ValueError("No sample inputs were found on the task page")

    for number in complete_numbers:
        pair = samples[number]
        input_path = sample_dir / f"{problem}_{number}.in"
        input_path.write_text(pair["input"], encoding="utf-8", newline="\n")
        written.append(input_path)

        if "output" in pair:
            output_path = sample_dir / f"{problem}_{number}.out"
            output_path.write_text(pair["output"], encoding="utf-8", newline="\n")
            written.append(output_path)

    return written


def parse_task_urls(contest, contest_url, html):
    parser = TaskLinkParser(contest, contest_url)
    parser.feed(html)
    return sorted(parser.urls, key=lambda url: infer_task_target(url)[1])


def download_task(root, task_url, html=None, cookie_header=None):
    contest, problem = infer_task_target(task_url)
    if html is None:
        html = fetch_html(task_url, cookie_header)

    sample_parser = SampleParser()
    sample_parser.feed(html)

    written = write_samples(root, contest, problem, sample_parser.samples)
    return contest, problem, written


def main():
    parser = argparse.ArgumentParser(description="Download AtCoder sample inputs and outputs.")
    parser.add_argument("url", help="AtCoder contest tasks URL or task URL")
    parser.add_argument("--root", default=".", help="repository root")
    parser.add_argument("--cookie-file", default=".atcoder-cookie", help="AtCoder cookie file")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    kind = infer_url_kind(args.url)
    cookie_header = load_cookie_header(root, args.cookie_file)

    try:
        html = fetch_html(args.url, cookie_header)
    except urllib.error.URLError as exc:
        print_fetch_error(args.url, exc, cookie_header)
        return 1

    if kind == "task":
        try:
            contest, problem, written = download_task(root, args.url, html, cookie_header)
        except ValueError as exc:
            print(str(exc), file=sys.stderr)
            return 1

        print(f"contest: {contest}")
        print(f"problem: {problem}")
        for path in written:
            print(path.relative_to(root).as_posix())
        return 0

    contest = infer_contest_target(args.url)
    task_urls = parse_task_urls(contest, args.url, html)
    if not task_urls:
        print(f"no task links found: {args.url}", file=sys.stderr)
        return 1

    print(f"contest: {contest}")
    for task_url in task_urls:
        try:
            _, problem, written = download_task(root, task_url, cookie_header=cookie_header)
        except urllib.error.URLError as exc:
            print_fetch_error(task_url, exc, cookie_header)
            return 1
        except ValueError as exc:
            print(f"failed: {task_url}: {exc}", file=sys.stderr)
            return 1

        print(f"problem: {problem}")
        for path in written:
            print(path.relative_to(root).as_posix())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
