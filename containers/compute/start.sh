#!/usr/bin/env bash

ARG=$1
DEF=wsserver
APP="${ARG:-$DEF}"

if [[ "$APP" != "wsserver" && "$APP" != "rserver" ]]; then
	echo "invalid app name"
	exit 1
fi

./$APP
