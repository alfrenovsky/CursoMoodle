#!/bin/bash

untar()
{
  cd /var/www/html/
  tar xfz /moodle/moodle.tgz
  chown www-data.www-data /var/www/html -R
}

wait4mysql()
{
  cat < /dev/null > /dev/tcp/db/3306 || figlet "Waiting for mysql"
  until (cat < /dev/null > /dev/tcp/db/3306) 2> /dev/null
  do
    echo "."
    sleep 0.5
  done
}

installmoodle()
{
  if [ -f /var/www/html/moodle/config.php ]
  then
    figlet "Moodle already installed"
  else
    untar
    wait4mysql
    chown www-data.www-data /var/www -R
    cd /var/www/html/moodle
    figlet "Installing moodle..."
    sudo -u www-data php admin/cli/install.php \
      --agree-license \
      --non-interactive \
      --lang=es \
      --wwwroot=http://localhost/moodle \
      --dataroot=/var/www/moodledata \
      --dbtype=mariadb \
      --dbhost=db \
      --dbname=moodle_db \
      --dbpass=moodle_pass \
      --dbuser=moodle_user \
      --dbport=3306 \
      "--fullname=Moodle Site" \
      --shortname=MS \
      --adminuser=admin \
      --adminpass=pass \
      --adminemail=nobody@example.com
  fi
}

upgradeifneeded()
{
  # TAREA PARA LA CASA
  if [ -f /var/www/html/moodle/update ]
  then
    rm /var/www/html/moodle/update
    upgrade
  fi
}

upgrade()
{
  figlet "Upgrade"

  wait4mysql
  sudo -u www-data php moodle/admin/cli/maintenance.php --enable

  cd /var/www/html
  list_plugins > /tmp/plugin.list

  shopt -s dotglob # Alguien sabe que es esto?

  [ -d .old ] || mkdir .old

  mv * .old 2> /dev/null # A donde vamos no necesitamos mensajes de error

  untar
  chown www-data.www-data /var/www -R

  mv .old/moodle/config.php moodle/

  figlet "Copiando plugins"
  cat /tmp/plugin.list | while read plugin
  do
    if [ ! -d moodle/$plugin ]
    then
      echo "copiando $plugin"
      dirname=$(dirname moodle/$plugin)
      [ -d "$dirname" ] || mkdir -p "$dirname" ]
      mv .old/moodle/$plugin $dirname/
    fi
  done

  rm -rf .old &

  figlet "Running upgrade"
  sudo -u www-data php moodle/admin/cli/upgrade.php --non-interactive
  sudo -u www-data php moodle/admin/cli/maintenance.php --disable

}

list_plugins()
{
  moosh info-plugins | while read type dir list
  do
    for name in ${list//,/ }
    do
      $dir/$name
    done
  done
}

copyphpini()
{
  [ $DEBUG ] && ini="development" || ini="production"
  figlet "Copying ${ini} php ini"
  cp "$PHP_INI_DIR/php.ini-$ini" "$PHP_INI_DIR/php.ini"
}

# https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
makephpfpmini()
{
  figlet "Making php-fpm customizations"
  output="/usr/local/etc/php-fpm.d/yy-custom.conf"
  echo "[www]" | tee ${output}
  for var in ${!PHP_FPM_@}
  do
    echo "${!var}" | tee -a ${output}
  done
}


makephpcustomini()
{
  figlet "Making php customizations"
  output="$PHP_INI_DIR/conf.d/99-moodle.ini"
  for var in ${!PHP_CFG_@}
  do
    echo "${!var}" | tee -a ${output}
  done
}

copyphpini
makephpfpmini

makephpcustomini

installmoodle # if needed

upgradeifneeded

wait4mysql

figlet "Starting php-fpm"
php-fpm
