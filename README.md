# action-backstop

Github Action for running BackstopJS and store the report on
backstore.

TLDR; Have a `backstop.json` in the root of the project, and ensure
that the secrets `DAIS_PLATFORMSH_ID`, `DAIS_PLATFORMSH_KEY` and
`RELOAD_BACKSTORE_KEY` is properly set. The latter is automatically
set for repositories in the `reload` organization and the former is
documented in [Dais](RELOAD_BACKSTORE_KEY). Add the following
workflow to `.github/workflows/visual_test.yml`:

``` yaml
on: pull_request
name: Visual regression test
jobs:

  visual_test:
    name: BackstopJS visual test
    if: '!github.event.deleted'
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    - uses: reload/action-backstop@v2
      with:
        action: reference
        github_token: ${{ github.token }}

    - uses: xendk/dais@main
      with:
        platform_id: ${{ secrets.DAIS_PLATFORMSH_ID }}
        platform_key: ${{ secrets.DAIS_PLATFORMSH_KEY }}
        files: backstop.json

    - uses: reload/action-backstop@v2
      with:
        github_token: ${{ github.token }}
        backstore_key: ${{ secrets.RELOAD_BACKSTORE_KEY }}
```
