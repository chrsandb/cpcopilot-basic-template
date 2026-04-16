#!/usr/bin/env python3
"""Read a secret from the terminal while masking printable input with asterisks."""

from __future__ import annotations

import os
import select
import sys
import termios
import tty


def read_masked(prompt_text: str, default_value: str = "") -> str:
    try:
        tty_in = open("/dev/tty", "r", encoding="utf-8", newline="")
    except OSError:
        tty_in = sys.stdin

    fd = tty_in.fileno()

    if not os.isatty(fd):
        return default_value

    try:
        old_settings = termios.tcgetattr(fd)
    except (termios.error, OSError, ValueError):
        return default_value

    buffer: list[str] = []
    byte_buf: bytes = b""
    raw_enabled = False

    try:
        if default_value:
            sys.stderr.write(f"{prompt_text} [{default_value}] ")
        else:
            sys.stderr.write(f"{prompt_text} ")
        sys.stderr.flush()

        tty.setraw(fd)
        raw_enabled = True

        while True:
            char = os.read(fd, 1)
            if not char:
                break

            if char in (b"\r", b"\n"):
                break

            if char == b"\x03":
                raise KeyboardInterrupt

            if char in (b"\x7f", b"\x08"):
                if buffer:
                    buffer.pop()
                    sys.stderr.write("\b \b")
                    sys.stderr.flush()
                byte_buf = b""
                continue

            if char == b"\x1b":
                byte_buf = b""
                while True:
                    ready, _, _ = select.select([fd], [], [], 0.01)
                    if not ready:
                        break
                    os.read(fd, 1)
                continue

            byte_buf += char
            try:
                decoded = byte_buf.decode("utf-8")
                byte_buf = b""
            except UnicodeDecodeError:
                # Incomplete multi-byte sequence; keep accumulating until valid
                # or discard after 4 bytes (longest valid UTF-8 sequence)
                if len(byte_buf) > 4:
                    byte_buf = b""
                continue

            if decoded.isprintable():
                buffer.append(decoded)
                sys.stderr.write("*")
                sys.stderr.flush()

        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        raw_enabled = False
        sys.stderr.write("\n")
        sys.stderr.flush()

        value = "".join(buffer)
        if not value and default_value:
            value = default_value
        return value
    finally:
        if raw_enabled:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        if tty_in is not sys.stdin:
            tty_in.close()


def main() -> int:
    prompt_text = sys.argv[1] if len(sys.argv) > 1 else "Secret:"
    default_value = sys.argv[2] if len(sys.argv) > 2 else ""

    try:
        value = read_masked(prompt_text, default_value)
    except KeyboardInterrupt:
        sys.stderr.write("\n")
        return 130
    except Exception as exc:  # pragma: no cover - defensive fallback for terminal quirks
        sys.stderr.write(f"masked_prompt.py: {exc}\n")
        return 1

    sys.stdout.write(value)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
