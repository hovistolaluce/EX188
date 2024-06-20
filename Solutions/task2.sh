#!/bin/sh

sudo podman pull registry.do180.lab:5000/httpd

sudo podman run -d \
        --name reg-httpd \
        -p 8080:80 \
        -v /web:/usr/local/apache2/htdocs \
        registry.do180.lab:5000/httpd

# SELinux verbietet den Zugriff auf das Host-Verzeichnis als Volume
# zum Nutzen von semanage: yum install policycoreutils-python-utils
# neuer Kontext wird als Richtlinie übernommen
sudo semanage fcontext -a -t container_file_t /web
sudo semanage fcontext -a -t container_file_t /web/index.html
# Zurücksetzen des File Kontextes (auf neue Richtline)
sudo restorecon /web
sudo restorecon /web/index.html

sudo podman generate systemd reg-httpd | sudo tee -a /usr/lib/systemd/system/reg-httpd.service

sudo systemctl daemon-reload
sudo systemctl restart reg-httpd

# Eintragung in Registry als insecure:
unqualified-search-registries = ["registry.do180.lab:5000","registry.access.redhat.com", "registry.redhat.io", "docker.io"]
[[registry]]
location = "registry.do180.lab:5000"
insecure = true

