# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

#
# Installs 'sd-devices' AppVM, to persistently store SD data
# This VM has no network configured.
##
sd-chat-template:
  qvm.vm:
    - name: sd-chat-template
    - clone:
      - source: debian-10
      - label: blue
    - tags:
      - add:
        - sd-workstation

sd-chat:
  qvm.vm:
    - name: sd-chat
    - present:
      - template: sd-chat-template
      - label: blue
    - prefs:
      - template: sd-chat-template
      - netvm: "sys-firewall"
    - tags:
      - add:
        - sd-workstation
    - require:
      - qvm: sd-chat-template

# Ensure the Qubes menu is populated with relevant app entries,
# so that Nautilus/Files can be started via GUI interactions.
sd-chat-template-sync-appmenus:
  cmd.run:
    - name: >
        qvm-shutdown --wait sd-chat-template &&
        qvm-start --skip-if-running sd-chat &&
        qvm-sync-appmenus sd-chat
    - require:
      - qvm: sd-chat-template
    - onchanges:
      - qvm: sd-chat-template
