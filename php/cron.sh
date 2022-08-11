#!/bin/bash

sudo -u www-data php moodle/admin/cli/cron.php  &

while sleep 60
do
  sudo -u www-data php moodle/admin/cli/cron.php  &
done

