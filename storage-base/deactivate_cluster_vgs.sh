#!/bin/bash

vgs=$(/sbin/vgdisplay -C -o vg_name,vg_attr --noheadings 2> /dev/null | /usr/bin/awk '($2 ~ /.....c/) {print $1}')

[ "$vgs" ] || exit 0

/sbin/vgchange -anl $vgs
