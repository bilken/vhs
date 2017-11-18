#!/bin/bash

set -x
rsync $* --progress -m -v --size-only -a -r /media/billy/Backup1/vhs/ billyk@billyk-delta:/media/billyk/Backup2/vhs/

