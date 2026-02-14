#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json, re, unicodedata
from pathlib import Path

def slugify(s: str) -> str:
    # aksanları ASCII'ye indir: "Bogotá"->"Bogota", "Yaoundé"->"Yaounde"
    s = unicodedata.normalize("NFKD", s or "")
    s = s.encode("ascii", "ignore").decode("ascii")
    s = s.lower()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    s = re.sub(r"-{2,}", "-", s).strip("-")
    return s

data = json.loads(Path("data/countries.json").read_text(encoding="utf-8"))
out = []
for row in data:
    iso2 = (row.get("iso2") or "").upper()
    countryEN = row.get("countryEN") or ""
    capEN = row.get("capitalEN") or ""
    if not iso2 or not capEN:
        continue
    out.append({
        "iso2": iso2,
        "countryEN": countryEN,
        "capitalEN": capEN,
        "slugCapital": slugify(capEN)
    })

out.sort(key=lambda x: x["countryEN"])
Path("assets").mkdir(exist_ok=True)
Path("assets/capitals_seed.json").write_text(
    json.dumps(out, ensure_ascii=False, indent=2),
    encoding="utf-8"
)
print(f"wrote assets/capitals_seed.json with {len(out)} records")
