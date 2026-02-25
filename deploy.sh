#!/bin/bash
# ============================================================
# deploy.sh - Deploy johndrefahl.com to AWS
# S3 + CloudFront + Route 53
# ============================================================
#
# Usage:
#   First time:  ./deploy.sh setup
#   Updates:     ./deploy.sh sync
#   Full redeploy: ./deploy.sh setup (safe to re-run)
#
# Prerequisites:
#   - AWS CLI configured with appropriate credentials
#   - Domain johndrefahl.com in Route 53
#
# ============================================================

set -euo pipefail

DOMAIN="johndrefahl.com"
BUCKET="johndrefahl.com"
REGION="us-east-1"
SITE_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[deploy]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
err() { echo -e "${RED}[error]${NC} $1" >&2; exit 1; }

# ---- Sync files to S3 ----
sync_files() {
  log "Syncing files to s3://${BUCKET}..."

  aws s3 sync "$SITE_DIR" "s3://${BUCKET}" \
    --exclude "deploy.sh" \
    --exclude ".DS_Store" \
    --exclude "*.md" \
    --exclude ".git/*" \
    --delete \
    --cache-control "public, max-age=3600" \
    --region "$REGION"

  aws s3 cp "s3://${BUCKET}/index.html" "s3://${BUCKET}/index.html" \
    --cache-control "public, max-age=300, s-maxage=86400" \
    --content-type "text/html; charset=utf-8" \
    --metadata-directive REPLACE \
    --region "$REGION"

  aws s3 cp "s3://${BUCKET}/error.html" "s3://${BUCKET}/error.html" \
    --cache-control "public, max-age=300" \
    --content-type "text/html; charset=utf-8" \
    --metadata-directive REPLACE \
    --region "$REGION"

  log "Files synced."
}

# ---- Invalidate CloudFront cache ----
invalidate_cache() {
  DIST_ID=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Aliases.Items[0]=='${DOMAIN}'].Id" \
    --output text 2>/dev/null || echo "")

  if [ -n "$DIST_ID" ] && [ "$DIST_ID" != "None" ]; then
    log "Invalidating CloudFront cache (${DIST_ID})..."
    aws cloudfront create-invalidation \
      --distribution-id "$DIST_ID" \
      --paths "/*" > /dev/null
    log "Cache invalidation submitted."
  else
    warn "No CloudFront distribution found for ${DOMAIN}. Skipping invalidation."
  fi
}

# ---- Main ----
case "${1:-sync}" in
  sync)
    sync_files
    invalidate_cache
    log "=== Deploy complete! ==="
    ;;
  invalidate)
    invalidate_cache
    ;;
  *)
    echo "Usage: $0 {sync|invalidate}"
    echo "  sync       - Sync files and invalidate cache (default)"
    echo "  invalidate - Just invalidate CloudFront cache"
    exit 1
    ;;
esac