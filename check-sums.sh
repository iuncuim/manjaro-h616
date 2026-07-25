#!/usr/bin/env bash
set -euo pipefail

ARG="${1:-.}"

if [[ -d "$ARG" ]]; then
  DIR="${ARG%/}"
  PKGBUILD="$DIR/PKGBUILD"
else
  PKGBUILD="$ARG"
  DIR="$(dirname "$PKGBUILD")"
fi

[[ -f "$PKGBUILD" ]] || { echo "ERROR: '$PKGBUILD' not found" >&2; exit 1; }

extract() {
  local arr=$1
  bash -c "
    source '$PKGBUILD' >/dev/null 2>&1 || true
    printf '%d\n' \"\${#$arr[@]}\"
    for e in \"\${$arr[@]}\"; do printf '%s\n' \"\$e\"; done
  "
}

mapfile -t src_lines < <(extract source)
mapfile -t md5_lines < <(extract md5sums)

src_n=${src_lines[0]}
md5_n=${md5_lines[0]}
src=("${src_lines[@]:1}")
md5=("${md5_lines[@]:1}")

echo "PKGBUILD: $PKGBUILD"
echo "source=$src_n  md5sums=$md5_n"
echo ""

max=$((src_n > md5_n ? src_n : md5_n))
printf "%-4s %-70s %-34s %-34s %s\n" "#" "source" "md5 (PKGBUILD)" "md5 (file)" "status"
echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------"

ok=0; warn=0; bad=0
for ((i=0; i<max; i++)); do
  s="${src[i]:-}"
  m="${md5[i]:-}"
  actual=""
  status=""

  [[ -z "$s" && -z "$m" ]] && continue

  if [[ $s == http://* || $s == https://* ]]; then
    fname="${s##*/}"
    if [[ -f "$DIR/$fname" ]]; then
      actual=$(md5sum "$DIR/$fname" | awk '{print $1}')
      if [[ $actual == "$m" ]]; then
        status="OK"; ok=$((ok+1))
      else
        status="MISMATCH"; bad=$((bad+1))
      fi
    else
      actual="<not-found>"
      status="MISSING"; warn=$((warn+1))
    fi
  elif [[ $m == "SKIP" ]]; then
    actual="<SKIP>"
    status="SKIP"
  elif [[ -z "$s" ]]; then
    actual="<extra-md5>"
    status="EXTRA"
    bad=$((bad+1))
  else
    f="$DIR/$s"
    if [[ -f "$f" ]]; then
      actual=$(md5sum "$f" | awk '{print $1}')
      if [[ $actual == "$m" ]]; then
        status="OK"
        ok=$((ok+1))
      else
        status="MISMATCH"
        bad=$((bad+1))
      fi
    else
      actual="<not-found>"
      status="MISSING"
      warn=$((warn+1))
    fi
  fi

  printf "%-4d %-70s %-34s %-34s %s\n" $((i+1)) "$s" "$m" "$actual" "$status"
done

echo ""
echo "OK=$ok  MISMATCH=$bad  MISSING=$warn"

if [[ $src_n != "$md5_n" ]]; then
  echo ""
  echo "SIZE MISMATCH: source=$src_n  md5sums=$md5_n"
  echo ""
  echo "Patch files in $DIR not in source[]:"
  for f in "$DIR"/*.patch; do
    fname="${f##*/}"
    [[ -f "$f" ]] || continue
    found=0
    for s in "${src[@]}"; do
      [[ $s == "$fname" ]] && { found=1; break; }
    done
    [[ $found == 0 ]] && echo "  $fname"
  done
fi
