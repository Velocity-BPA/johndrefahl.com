# johndrefahl.com

Personal resume/promotional website. Static HTML/CSS/JS hosted on AWS (S3 + CloudFront + Route 53).

## Files

```
index.html                     - Main site (single page, everything inline)
error.html                     - 404 error page
John_Drefahl_Resume_2026.docx  - Resume served by the Resume button
og-image.jpg                   - Social share image (og:image, twitter:image)
robots.txt                     - Crawler rules
deploy.sh                      - AWS deployment script
```

## Deploying Updates

After editing `index.html`:

```bash
./deploy.sh sync
```

This syncs files to S3 and invalidates the CloudFront cache. Changes show up within a few minutes.

## Updating the Resume

The Resume button downloads `John_Drefahl_Resume_2026.docx`. Replace that file here and run `./deploy.sh sync`. If the file name changes, update the `resume-fab` link in `index.html` too.

`deploy.sh sync` never deletes from the bucket, so older resume URLs keep working. `John_Drefahl_Automation_Engineer_Resume.docx` in the bucket is an alias for links already sent out and is not in this repo.

## Notes

- Fonts load from Google Fonts CDN (JetBrains Mono + Source Serif 4)
- Dark/light mode toggle persists via localStorage
- No frameworks, no build step. Edit HTML directly.
- Infrastructure: S3 static hosting + CloudFront CDN + Route 53 DNS + ACM TLS certificate
