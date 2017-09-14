#!/bin/bash

function oneTimeSetUp () {
  if [[ $EUID -ne 0 ]]; then
    echo "Tests must be run as root" 1>&2
    exit 1
  fi

  app_root=$( cd $(dirname "$0")/../../.. && pwd )
  apparchive="$app_root/tmp/app.txz"

  if ! [ -f "$apparchive" ]; then
    if ! git archive -o "$apparchive" HEAD; then
      echo "Unable to create the app archive" 1>&2
      exit 1
    fi
  fi

  source "$app_root/bin/install.d/debian"
}

function setUp () {
  username="testuser"
  groupname="testgroup"
  password="password"
  user_home=/home/$username
  appname=desy
  app_path=/home/$username/www/desy
  servername='desy.example.com'
  DEBUG=true
}

function _assertTrue () {
  assertTrue "$1" "$1"
}

function _assertFalse () {
  assertFalse "$1" "$1"
}

function _assertCommandNull () {
  assertNull "\`$1\` NOT NULL" "`$1`"
}

function test_sourceLoaded () {
  assertEquals 'function' "$(type -t suc 2> /dev/null)"
}

function test_suc () {
  local prev="$username"
  username="$USER"

  assertEquals "hello from $USER" "`suc 'echo hello from \$USER'`"

  username="$prev"
}

function test_update_apt_and_install_prerequirements_and_dependencies () {
  local required_packages=( ${PREREQUIRED_PACKAGES[@]} ${RUBY_REQUIRED_PACKAGES[@]} )
  required_packages=$(printf " %s" "${required_packages[@]}")
  required_packages=${required_packages:1}
  assertEquals 'git curl xz-utils gcc make zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev' "$required_packages"

  apt-get --assume-yes purge $required_packages > /dev/null 2>&1
  apt-get --assume-yes autoremove > /dev/null 2>&1

  for package in $required_packages; do
    _assertFalse "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"
  done

  update_apt_and_install_prerequirements_and_dependencies > /dev/null 2>&1

  for package in $required_packages; do
    _assertTrue "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"
  done
}

function test_create_app_user () {
  deluser --remove-home --remove-all-files "$username" > /dev/null 2>&1
  delgroup "$groupname" > /dev/null 2>&1

  _assertFalse "id \"$username\" 2> /dev/null"
  _assertFalse "grep \"^$groupname:\" /etc/group"

  create_app_user > /dev/null 2>&1

  _assertTrue "id \"$username\" 2> /dev/null"
  _assertTrue "grep \"^$groupname:\" /etc/group"
}

function test_extract_app_archive () {
  _assertTrue "[ -f \"$apparchive\" ]"

  extract_app_archive > /dev/null 2>&1

  _assertTrue "[ -d \"$app_path\" ]"
  _assertTrue "[ -f \"$app_path/config/application.rb\" ]"
  assertEquals "$username" "`stat -c %U \"$app_path\"`"
}

function test_install_rbenv_and_ruby () {
  _assertFalse "[ -d \"$user_home/.rbenv\" ]"
  _assertFalse "[ -d \"$user_home/.rbenv/plugins/ruby-build\" ]"
  _assertFalse "su --login --command 'which ruby' \"$username\""
  _assertFalse "su --login --command 'ruby --version 2> /dev/null | grep \"^ruby 2\.0\.0p247 \"' \"$username\""

  # FIXME: there's no way to call a no-interactive `gem`
  # install_rbenv_and_ruby > /dev/null 2>&1
  install_rbenv_and_ruby

  local last_ruybgems_version='2.0.3'

  _assertTrue "[ -d \"$user_home/.rbenv\" ]"
  _assertTrue "[ -d \"$user_home/.rbenv/plugins/ruby-build\" ]"
  _assertTrue "su --login --command 'which ruby' \"$username\""
  _assertTrue "su --login --command 'ruby --version 2> /dev/null | grep \"^ruby 2\.0\.0p247 \"' \"$username\""
  assertEquals "$last_ruybgems_version" "`su --login --command 'gem --version' \"$username\"`"
}

function test_install_application_and_media_editing_dependencies () {
  local required_packages=( ${APP_REQUIRED_PACKAGES[@]} )
  required_packages=$(printf " %s" "${required_packages[@]}")
  required_packages=${required_packages:1}
  assertEquals 'g++ libsqlite3-dev imagemagick libav-tools libavcodec-extra-53 mkvtoolnix sox' "$required_packages"

  apt-get --assume-yes purge $required_packages > /dev/null 2>&1
  apt-get --assume-yes autoremove > /dev/null 2>&1

  for package in $required_packages; do
    _assertFalse "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"
  done

  install_application_and_media_editing_dependencies > /dev/null 2>&1

  for package in $required_packages; do
    _assertTrue "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"
  done
}

function test_install_libpq_dev () {
  local package=libpq-dev

  apt-get --assume-yes purge "$package" > /dev/null 2>&1
  apt-get --assume-yes autoremove > /dev/null 2>&1
  rm -f /etc/apt/sources.list.d/pgdg.list
  apt-get --assume-yes update > /dev/null 2>&1

  _assertFalse "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"

  install_libpq_dev > /dev/null 2>&1

  _assertTrue "dpkg-query --show --showformat='\${Version}' \"$package\" 2> /dev/null | grep --quiet '^9\.[2-9]'"
}

function test_install_bundle () {
  local bundle_path="$app_path"/vendor/bundle
  rm -rf "$bundle_path"
  su --login --command 'gem uninstall bundler' "$username"

  _assertFalse "su --login --command 'which bundle' \"$username\""
  _assertFalse "[ -d \"$bundle_path\" ]"

  install_bundle

  _assertTrue "su --login --command 'which bundle' \"$username\""
  _assertTrue "[ -d \"$bundle_path\" ]"
  _assertTrue "[ -s \"$bundle_path\" ]"
}

function test_configure_desy () {
  rm -f "$app_path/config/settings.yml"
  rm -f "$app_path/config/database.yml"

  _assertFalse "[ -f \"$app_path/config/settings.yml\" ]"
  _assertFalse "[ -f \"$app_path/config/database.yml\" ]"

  configure_desy

  _assertTrue "[ -f \"$app_path/config/settings.yml\" ]"
  _assertTrue "[ -f \"$app_path/config/database.yml\" ]"
}

function test_configure_logrotate () {
  rm -f "/etc/logrotate.d/${username}_$appname"
  rm -rf "$app_path/log/media"

  _assertFalse "[ -d \"$app_path/log/media\" ]"
  _assertFalse "[ -f \"/etc/logrotate.d/${username}_$appname\" ]"

  configure_logrotate

  _assertTrue "[ -d \"$app_path/log/media\" ]"
  assertEquals "`cat \"$app_root\"/bin/install.d/test/logrotate.conf.diff`" \
               "`diff \"$app_root\"/config/logrotate.conf.example \"/etc/logrotate.d/${username}_$appname\"`"
}

function test_install_and_configure_php () {
  local package=php5-fpm

  apt-get --assume-yes purge "$package" > /dev/null 2>&1
  apt-get --assume-yes autoremove > /dev/null 2>&1

  _assertFalse "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"

  install_and_configure_php > /dev/null 2>&1

  _assertTrue "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"
}

function test_install_and_configure_nginx () {
  local package=nginx

  apt-get --assume-yes purge "${package}-common" > /dev/null 2>&1
  apt-get --assume-yes purge "$package" > /dev/null 2>&1
  apt-get --assume-yes autoremove > /dev/null 2>&1
  rm -rf /etc/nginx

  _assertFalse "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"
  _assertFalse "[ -d \"/etc/nginx\" ]"
  _assertFalse "[ -f \"/etc/nginx/sites-available/${username}_$appname\" ]"
  _assertFalse "[ -h \"/etc/nginx/sites-enabled/${username}_$appname\" ]"

  install_and_configure_nginx > /dev/null 2>&1

  _assertTrue "[ -d \"/etc/nginx\" ]"
  _assertTrue "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'" 
  _assertTrue "[ -f \"/etc/nginx/sites-available/${username}_$appname\" ]"
  _assertTrue "[ -h \"/etc/nginx/sites-enabled/${username}_$appname\" ]"
  assertEquals "`cat \"$app_root\"/bin/install.d/test/nginx.conf.diff`" "`diff \"$app_root\"/config/nginx.conf.example /etc/nginx/sites-enabled/testuser_desy`"
}

function test_install_postgresql () {
  local package=postgresql-9.3

  apt-get --assume-yes purge "$package" > /dev/null 2>&1
  apt-get --assume-yes autoremove > /dev/null 2>&1
  apt-get --assume-yes update > /dev/null 2>&1

  _assertFalse "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"

  install_postgresql > /dev/null 2>&1

  _assertTrue "dpkg-query --show --showformat='\${Version}' \"$package\" 2> /dev/null | grep --quiet '^9\.[2-9]'"
}

function test_install_postgresql_contrib () {
  local package=postgresql-contrib-9.3

  apt-get --assume-yes purge "$package" > /dev/null 2>&1
  apt-get --assume-yes autoremove > /dev/null 2>&1
  apt-get --assume-yes update > /dev/null 2>&1

  _assertFalse "dpkg-query --show --showformat='\${db:Status-abbrev}' \"$package\" 2> /dev/null | grep --quiet '^i'"

  install_postgresql_contrib > /dev/null 2>&1

  _assertTrue "dpkg-query --show --showformat='\${Version}' \"$package\" 2> /dev/null | grep --quiet '^9\.[3-9]'"
}

function test_configure_unicorn_service () {
  update-rc.d unicorn remove -f > /dev/null
  rm -f /etc/init.d/unicorn
  rm -f "$app_path/config/unicorn.rb"
  rm -rf /etc/unicorn

  _assertFalse "[ -f \"/etc/init.d/unicorn\" ]"
  _assertFalse "[ -f \"$app_path/config/unicorn.rb\" ]"
  _assertFalse "[ -d \"/etc/unicorn\" ]"

  configure_unicorn_service > /dev/null 2>&1

  _assertTrue "[ -f \"/etc/init.d/unicorn\" ]"
  _assertTrue "[ -f \"$app_path/config/unicorn.rb\" ]"
  _assertTrue "[ -d \"/etc/unicorn\" ]"
  assertEquals "`cat \"$app_root\"/bin/install.d/test/unicorn.conf.diff`" "`diff \"$app_root\"/config/unicorn.conf.example /etc/unicorn/testuser\:desy`"
}

function test_configure_delayed_job_service () {
  update-rc.d delayed_job remove -f > /dev/null 2>&1
  rm -f /etc/init.d/delayed_job
  rm -rf /etc/delayed_job

  _assertFalse "[ -f \"/etc/init.d/delayed_job\" ]"
  _assertFalse "[ -d \"/etc/delayed_job\" ]"

  configure_delayed_job_service > /dev/null 2>&1

  _assertTrue "[ -f \"/etc/init.d/delayed_job\" ]"
  _assertTrue "[ -d \"/etc/delayed_job\" ]"
  assertEquals "`cat \"$app_root\"/bin/install.d/test/delayed_job.conf.diff`" "`diff \"$app_root\"/config/delayed_job.conf.example /etc/delayed_job/testuser\:desy`"
}

function test_configure_cron_service () {
  echo su --login --command "cd \"$app_path\" && bundle exec whenever --clear-crontab" "$username"

  su --login --command "cd \"$app_path\" && bundle exec whenever --clear-crontab" "$username"

  assertNotEquals "`cat \"$app_root\"/bin/install.d/test/crontab.out`" "`su --login --command \"crontab -l\" \"$username\"`"

  configure_cron_service > /dev/null 2>&1

  assertEquals "`cat \"$app_root\"/bin/install.d/test/crontab.out`" "`su --login --command \"crontab -l\" \"$username\"`"
}

function test_after_all () {
  _assertCommandNull "find ""$user_home"" -user root"
}

. shunit2