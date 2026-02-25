# johndrefahl.com

Personal resume/promotional website. Static HTML/CSS/JS hosted on AWS (S3 + CloudFront + Route 53).

## Files

```
index.html   - Main site (single page, everything inline)
error.html   - 404 error page
deploy.sh    - AWS deployment script
```

## Deploying Updates

After editing `index.html`:

```bash
./deploy.sh sync
```

This syncs files to S3 and invalidates the CloudFront cache. Changes show up within a few minutes.

## Adding the Resume PDF

Drop your resume PDF into this directory as `John_Drefahl_Resume.pdf`, then run `./deploy.sh sync`.

## Notes

- Fonts load from Google Fonts CDN (JetBrains Mono + Source Serif 4)
- Dark/light mode toggle persists via localStorage
- No frameworks, no build step. Edit HTML directly.
- Infrastructure: S3 static hosting + CloudFront CDN + Route 53 DNS + ACM TLS certificate
