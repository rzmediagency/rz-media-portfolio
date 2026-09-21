# RZ Media — portfolio

Single static page. No build step, no dependencies.

```
index.html      the page — markup, styles, and the work list
media/          web-compressed .mp4 clips + matching .jpg posters
incoming/       drop raw videos here before they go in
add-clip.sh     compress one chosen video and generate its entry
```

## You choose what goes on the site

Nothing imports automatically. A video appears only once it has an entry in
the `CLIPS` list in `index.html`. That list is the whole control — if it
isn't in there, it isn't on the site. Delete an entry to pull a video;
reorder entries to reorder the grid.

## Adding a video

1. Drop the raw file in `incoming/`.
2. Run:

   ```bash
   ./add-clip.sh incoming/your-video.mov carhealers "Winter promo" FR
   ```

3. Paste the printed block into `CLIPS`, then fill in the four blanks:
   `leads`, `views`, `engagement`, and `why`.

New client? Add it to `CLIENTS` first:

```js
carhealers: { name: "Car Healers", sector: "Auto body shop · Montréal" }
```

A filter chip appears on its own once a clip uses that key.

## Preview locally

```bash
python3 -m http.server 4173
```

## Keeping it fast

Clips encode to 1080px wide, H.264, with `faststart`. Keep each under ~4 MB.
The grid loads posters only; a clip downloads when someone plays it.
