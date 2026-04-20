"""Expand data/countries.json with country + capital labels in 12 languages.

Queries Wikidata once per target language using the native
`SERVICE wikibase:label` (fast, cache-friendly), falling back to English
when a label is missing.

Run once locally (network required):
    python tools/expand_country_translations.py
"""

from __future__ import annotations

import json
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COUNTRIES_JSON = ROOT / "data" / "countries.json"

# 12 supported languages. EN + TR are already in the file — we only need
# to fetch the remaining ten.
EN_TR = {"en", "tr"}
LANGS_NEW = ["de", "fr", "es", "it", "pt", "ru", "ja", "zh", "ar", "ko"]

ENDPOINT = "https://query.wikidata.org/sparql"
USER_AGENT = "geoquiz-expand/2.0 (contact: eagleeyetrader1@gmail.com)"


def build_lang_query(iso2_codes: list[str], lang: str) -> str:
    """Ask for country + capital labels in `lang` (with English fallback
    provided by the label service). Flat, one row per country."""
    iso_values = " ".join(f'"{c}"' for c in iso2_codes)
    return f"""
SELECT ?iso ?countryLabel ?capitalLabel WHERE {{
  VALUES ?iso {{ {iso_values} }}
  ?country wdt:P297 ?iso .
  OPTIONAL {{ ?country wdt:P36 ?capital . }}
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "{lang},en" . }}
}}
""".strip()


def run_query(query: str, attempt: int = 0) -> list[dict]:
    url = ENDPOINT + "?" + urllib.parse.urlencode({"query": query, "format": "json"})
    req = urllib.request.Request(url, headers={
        "User-Agent": USER_AGENT,
        "Accept": "application/sparql-results+json",
    })
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            data = json.loads(r.read())
        return data.get("results", {}).get("bindings", [])
    except urllib.error.HTTPError as e:
        if e.code in (429, 500, 502, 503, 504) and attempt < 3:
            wait = 2 ** attempt * 3
            print(f"[expand] HTTP {e.code}, retrying in {wait}s (attempt {attempt + 1})")
            time.sleep(wait)
            return run_query(query, attempt + 1)
        raise


def chunked(seq, n):
    for i in range(0, len(seq), n):
        yield seq[i:i + n]


def main() -> int:
    with COUNTRIES_JSON.open("r", encoding="utf-8") as f:
        countries = json.load(f)

    iso_list = [c["iso2"].upper() for c in countries if c.get("iso2")]
    print(f"[expand] {len(iso_list)} countries × {len(LANGS_NEW)} new languages")

    # (iso, lang) → label
    country_labels: dict[tuple[str, str], str] = {}
    capital_labels: dict[tuple[str, str], str] = {}

    for lang in LANGS_NEW:
        for batch in chunked(iso_list, 100):
            q = build_lang_query(batch, lang)
            rows = run_query(q)
            filled_c = filled_k = 0
            for row in rows:
                iso = row.get("iso", {}).get("value", "").upper()
                cl = row.get("countryLabel", {}).get("value", "")
                kl = row.get("capitalLabel", {}).get("value", "")
                if iso and cl:
                    country_labels[(iso, lang)] = cl
                    filled_c += 1
                if iso and kl:
                    capital_labels[(iso, lang)] = kl
                    filled_k += 1
            print(f"[expand] lang={lang} batch={len(batch)} country={filled_c} capital={filled_k}")
            time.sleep(0.8)

    # Merge — never overwrite existing EN/TR fields.
    for c in countries:
        iso = c.get("iso2", "").upper()
        for lang in LANGS_NEW:
            key_c = f"country{lang.upper()}"
            key_k = f"capital{lang.upper()}"
            cl = country_labels.get((iso, lang))
            kl = capital_labels.get((iso, lang))
            if cl:
                c[key_c] = cl
            if kl:
                c[key_k] = kl

    # Safety net: ensure every lang has a non-empty value. Fill gaps with EN
    # so "no half system" holds at the data level — no blank options.
    filled_country_fallback = 0
    filled_capital_fallback = 0
    for c in countries:
        en_country = c.get("countryEN", "")
        en_capital = c.get("capitalEN", "")
        for lang in LANGS_NEW:
            key_c = f"country{lang.upper()}"
            key_k = f"capital{lang.upper()}"
            if not c.get(key_c) and en_country:
                c[key_c] = en_country
                filled_country_fallback += 1
            if not c.get(key_k) and en_capital:
                c[key_k] = en_capital
                filled_capital_fallback += 1

    with COUNTRIES_JSON.open("w", encoding="utf-8") as f:
        json.dump(countries, f, ensure_ascii=False, indent=2)

    print(f"[expand] wrote {COUNTRIES_JSON}")
    print(f"[expand] EN-fallbacked: country={filled_country_fallback}, capital={filled_capital_fallback}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
