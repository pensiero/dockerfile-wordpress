## dockerfile-wordpress

Docker image acting as the base for WordPress sites: Apache with mod_php, the
PHP extensions WordPress and its plugins use, and sane production settings.
It doesn't contain WordPress itself: the site lives in `/var/www/public`,
usually on a mounted volume.

### PHP 8.4 (branch `php84`)

Built on the official `php:8.4-apache` image (Debian 13, Apache 2.4). Tags are
`php8.4-YYYYMMDD`, one per build, never overwritten:

```bash
docker buildx build --platform linux/amd64 -t pensiero/wordpress:php8.4-YYYYMMDD --push .
```

Rebuild (new date tag) whenever PHP publishes a release for 8.4: the base image
is pinned to an exact PHP version in the `FROM` line, so bump that too.

#### Settings you can change per site

| Variable | Default | What it does |
|---|---|---|
| `APACHE_MAX_REQUEST_WORKERS` | `10` | Apache prefork workers. Keep workers × ~100 MB under the container memory limit. |
| `PHP_MEMORY_LIMIT` | `256M` | PHP `memory_limit` |
| `PHP_POST_MAX_SIZE` | `32M` | PHP `post_max_size` |
| `PHP_UPLOAD_MAX_FILESIZE` | `16M` | PHP `upload_max_filesize`; keep it below `post_max_size` |
| `PROJECT_PATH` / `PROJECT_PUBLIC_DIR` | `/var/www` / `public` | Document root is `$PROJECT_PATH/$PROJECT_PUBLIC_DIR` |

#### Differences from the old php7.4 image

- No postfix and no `mail()`: send mail through an SMTP plugin (WP Mail SMTP)
  with a real provider.
- No git, npm, yarn or composer at runtime.
- No FFI extension.
- `session.upload_progress.enabled = 0`, `post_max_size` 32M and
  `upload_max_filesize` 16M (were 64M/32M): hardening from the PHP security
  advisory of 2026-10-21 (CVE-2026-109618/109619).
- Apache answers `/.git`, `/.svn`, `/.hg`, `/.env` with 404 and refuses
  `*.sql`, `*.bak`, `*.old` and similar, without starting PHP.
- Logs go to stdout/stderr.

### PHP extensions included

bcmath, calendar, ctype, curl, dom, exif, fileinfo, ftp, gd (jpeg, webp, avif,
freetype), gettext, iconv, imagick, intl, mbstring, mysqli, opcache, pcntl,
pdo_mysql, pdo_sqlite, posix, shmop, sockets, sodium, sysvmsg, sysvsem,
sysvshm, xml, xmlreader, xmlwriter, xsl, zip, zlib.

Check with `docker run --rm --entrypoint php pensiero/wordpress:<tag> -m`.

### Older tags (unmaintained)

`php5.6`, `php7.2`, `php7.4` (on `master`): Ubuntu 18.04 with the ondrej PPA,
built in 2020, no longer patched. PHP 7.4 is affected by
CVE-2026-109618/109619. Do not use them for anything new.
