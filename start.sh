#!/bin/bash

# Postfix
service postfix start

# Apache
/usr/sbin/apache2ctl -D FOREGROUND