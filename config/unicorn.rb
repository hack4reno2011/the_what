working_directory "/var/lib/capolite/apps/the_what/current"
stderr_path "/var/lib/capolite/apps/the_what/current/log/unicorn.log"
stdout_path "/var/lib/capolite/apps/the_what/current/log/unicorn.log"
pid "/var/lib/capolite/apps/the_what/current/tmp/pids/unicorn.pid"

preload_app true
timeout 60
worker_processes 2
listen 5000
user "apache", "apache"
