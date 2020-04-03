# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# sd-devices-files
# ========
#
# Moves files into place on sd-devices
#
##

include:
  - update.qubes-vm

install-python-apt-for-repo-config:
  pkg.installed:
    - pkgs:
      - python-apt
    - require:
      # Require that the Qubes update state has run first. Doing so
      # will ensure that apt is sufficiently patched prior to installing.
      - sls: update.qubes-vm

configure-signal-apt-repo:
  pkgrepo.managed:
    - name: "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main"
    - file: /etc/apt/sources.list.d/signal-xenial.list
    - key_url: "salt://sd/sd-workstation/signal-apt-key.asc"
    - clean_file: True # squash file to ensure there are no duplicates
    - require:
      - pkg: install-python-apt-for-repo-config

# Libreoffice needs to be installed here to convert to pdf to allow printing
sd-chat-install-signal:
  pkg.installed:
    - name: signal-desktop
    - retry:
        attempts: 3
        interval: 60
    - install_recommends: False

sd-chat-open-in-dvm-desktop:
  file.managed:
    - name: /usr/share/applications/open-in-dvm.desktop
    - source: salt://sd/sd-chat/open-in-dvm.desktop
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

sd-chat-configure-mimetypes:
  file.managed:
    - name: /usr/share/applications/mimeapps.list
    - source: salt://sd/sd-chat/mimeapps.list
    - user: user
    - group: user
    - mode: 644
    - makedirs: True
  cmd.run:
    - name: sudo update-desktop-database /usr/share/applications
    - require:
      - file: sd-chat-configure-mimetypes
      - file: sd-chat-open-in-dvm-desktop
    - onchanges:
      - file: sd-chat-open-in-dvm-desktop
      - file: sd-chat-configure-mimetypes
