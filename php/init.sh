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
    chown www-data.www-data /var/www/moodledata -R
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

  copyphpini
  makephpfpmini

  installmoodle

  wait4mysql

  figlet "Starting php-fpm"
  php-fpm
