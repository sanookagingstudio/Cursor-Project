# RESTORE GUIDE — FunAging.club (ONEPACK v13)

## Quick Restore Steps

1. Fetch all branches and tags:
   git fetch --all
   git fetch --tags

2. Checkout main branch:
   git checkout main
   git pull

3. List available stable tags:
   git tag -l "stable-v13-*"

4. Restore to a specific stable tag:
   git checkout tags/<TAG> -b restore-<TAG>

## Example
git checkout tags/stable-v13-20251212-000330 -b restore-20251212

## View All Tags
git tag -l

## View Tag Details
git show <TAG>
