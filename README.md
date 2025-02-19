## Script to deploy

```move
sui client publish --skip-fetch-latest-git-deps --with-unpublished-dependencies
```

## Script to upgrade

```move
sui client upgrade --upgrade-capability <UPGRADE-CAP-ID> --skip-fetch-latest-git-deps
```
