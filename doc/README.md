# DESY - Digital Educational SYstem

## Description

DESY - Digital Educational SYstem is a web application thought to create and
share on-line multimedia lessons.

The lessons are created by the application users; users can also upload media
elements, which can be included in their lessons and shared with other users.

The lessons can be collected inside containers called Virtual Classrooms,
which will be shared on the web via their respective URLs.

## Architecture

The software architecture is composed by: 

*   the **web application**: developed in [Ruby](http://www.ruby-lang.org)
    using the web framework [Ruby on Rails](http://rubyonrails.org/), provides
    the web frontend; it uses [PostgreSQL](http://www.postgresql.org) for data
    persistence
*   the **background processes**: managed through the
    [Delayed::Job](https://github.com/collectiveidea/delayed_job) library,
    they run the instances charged of uploaded media converting and editing
*   the **cron jobs**: periodically actions, like f.e. checking the size of
    media elements folder in order to send an alert to the maintainer


## Requirements

### Hardware requirements

An adequate infastructure consists of:

*   a web server: it runs the web application and the database, and hosts the
    media elements; it requires of enough CPU and RAM for running the
    processes instances, and enough disk space to host the media files
*   a media processing server: it runs the media processing jobs, and requires
    of a discrete amount of CPU and RAM in order to process the media files;
    it should be designated to run the cron jobs too


### Software requirements

DeSY is designed to be deployed on Linux systems; it is expected to be
deployed on Debian systems, but can be easily customized to run on every Unix
system, BSD included, provided that its dependencies are available on the host
OS.

These are the software dependencies:

*   Ruby >= 2.0
*   PostgreSQL >= 9.2
*   libav >= 0.8.3
*   libavcodec-extra-53
*   mkvtoolnix
*   sox >= 14.4.0
*   g++
*   libsqlite3-dev
*   libpq-dev
*   imagemagick
*   Ruby Bundler gem
*   gems installed by Bundler and their dependencies
*   PHP
*   nginx | apache


## Installation

If DeSY is going to be installed on a dedicated clean machine, you can run
`script/install DESY_ARCHIVE { web_server SERVER_NAME | jobs_server }`, where
`DESY_ARCHIVE` is the path to the DeSY archive, while `web_server` or
`jobs_server` is the role of the server (whether it is dedicated to serve the
web application or executing the background jobs, such the media conversions
and editing processings); if its role is `web_server`, you must specify
`SERVER_NAME`, which is the server name that will be written inside the nginx
virtual host configuration.

After executing the installation script follow the post-script instructions in
order to get a running production environment.

Otherwise you can proceed with the manual installation:

1.  Install prerequirements and Ruby dependencies (on a Debian/Ubuntu system:
    `git gcc make zlib1g-dev libyaml-dev libssl-dev libgdbm-dev
    libreadline-dev libncurses5-dev libffi-dev`)
2.  Install Ruby (possibly using
    [rbenv](https://github.com/sstephenson/rbenv), [RVM](https://rvm.io/), or
    [chruby](https://github.com/postmodern/chruby))
3.  Extract the DeSY copy into the destination path (it should be somewhere
    inside the home of the user which runs the app)
4.  Install application dependencies (on a Debian/Ubuntu system: `libpq-dev
    g++ libsqlite3-dev imagemagick libav-tools libavcodec-extra-53 mkvtoolnix
    sox` - **libpq-dev version should be >= 9.2**)
5.  Install Bundler (`gem install bundler`)
6.  `cd` into the DeSY folder and install the bundle (`bundle install
    --deployment --without development test irbtools`)
7.  Copy and customize as needed the following configuration files:

    *   `config/settings.yml.example` to `config/settings.yml`
    *   `config/database.yml.example` to `config/database.yml`
    *   `config/logrotate.conf.example` to `/etc/lograte.d/`


8.  If it is a web server installation:

    1.  Install and configure PHP in order to serve WIRIS pages (an example of
        web server configuration is inside `config/nginx.conf.example`)
    2.  Install and configure the web server (nginx is preferred, but not
        required)
    3.  Ensure the web server to serve the following MIME types (if nginx web
        server is used, you can use `config/nginx.conf.example` as start for
        the DeSY site configuration file):

        *   video/mp4   mp4
        *   video/webm  webm
        *   audio/mp4   m4a
        *   audio/ogg   ogg


    4.  Configure Unicorn as application server (you can use
        `config/unicorn.init.d.example` as init script and
        `config/unicorn.conf.example` as service configuration, while
        `config/unicorn.rb.example` as Unicorn processes configuration)
    5.  Install and configure PostgreSQL (**PostgreSQL version should >=
        9.2**)


    Otherwise, if it is a job server installation:

    1.  Configure DelayedJob (you can use `config/delayed_job.init.d.example`
        as init script and `config/delayed_job.conf.example` as service
        configuration)
    2.  Configure the cron jobs (executing `bundle exec whenever
        --update-crontab`)



## Configuration

DeSY can be configured through the file `config/settings.yml` (which must be
created after the installation - see [Installation](#label-Installation)). See
the contents of the example file (`config/settings.yml.example`) for details.
