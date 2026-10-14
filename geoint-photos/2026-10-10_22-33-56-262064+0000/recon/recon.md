# Recon: IMG_20261010_231927.jpg

First pass in 18s (meta 4.9s FAILED, intake 12.9s FAILED).
Reverse image search ran on Yandex and Baidu (original + variants). Make (or revisit) your gut call, then use the evidence below to confirm, contradict or sharpen it.

## Metadata

- meta.py did not run: attempt #1. Sleeping 1.1783628s before the next attempt
WARN Retry attempt #1. Sleeping 1.7969381s before the next attempt
WARN Retry attempt #1. Sleeping 3.6085152s before the next attempt
WARN Retry

## Text

- OCR found no text (or it is too small: zoom the crops in intake/edges and detect/).

## Reverse image search (Yandex, Baidu)

- intake did not finish: WARN Retry attempt #0. Sleeping 1.7661951s before the next attempt
WARN Retry attempt #1. Sleeping 3.9680465s before the next attempt
WARN Retry attempt #2. Sleeping 6.9795483s before the next attempt

## World prior (learned models: ranking only)

- not run (skipped)

## Camera

- not run (skipped)

## Things to inspect

- Edge and corner crops: `intake/edges/` (look at every one); OCR boxes: `intake/ocr.png`.

## Next

1. Compare this page with your gut call. Where they disagree, find out why (a misread, an unusual scene, a wrong gut).
2. `board.py init --photo original/<file>`; record your own observations as clues; `board.py ingest recon/textgeo.json` and `board.py ingest recon/prior/prior.json` after checking the signals make sense.
3. Separate the top candidates with the cheapest decisive test (text lookups, web search, `refsheet.py`, the world clue files).
4. Follow every reverse-search lead (source pages, albums, captions); try Google Lens through the browser tool and re-run the scripted engines on a tight crop of the most distinctive object. No questions to the user — decide and continue.
