#!/bin/bash
# Print-orientation STLs → stl/. Usage: bash print.sh [tag]   (tag → also _<tag> copies)
#   meety-dumpster-R-*  USB-C out the right wall   meety-dumpster-L-*  USB-C out the left wall
#   meety-dumpster-*    shared by both (lid ×2, wheel)
cd "$(dirname "$0")"
tag="$1"
E() {
    out="meety-dumpster-$1"; shift
    timeout 300 openscad -o "stl/$out.stl" -D print=true "$@" dumpster.scad 2>&1 | grep -E 'WARNING|ERROR|assert'
    [ -n "$tag" ] && cp "stl/$out.stl" "stl/${out}_$tag.stl"
    printf "%-34s %8d bytes\n" "$out" "$(stat -c %s "stl/$out.stl")"
}
for s in R L; do
    E $s-body      -D "side=\"$s\"" -D 'part="body"' &
    E $s-deck      -D "side=\"$s\"" -D 'part="deck"' &
    E $s-cartridge -D "side=\"$s\"" -D 'part="cartridge"' &
    E $s-flame     -D "side=\"$s\"" -D 'part="flame"' &
done
E lid        -D 'part="lid"' &
E wheel      -D 'part="wheel"' &
wait
