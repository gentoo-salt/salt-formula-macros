# Macro for package installation including adding license file, accept_keywords file
# example usage:
# package_install(firefox, www-client/firefox, True, '', '')
# package_install(vivaldi, www-client/vivaldi, True, 'Vivaldi', '')
# package_install(testdisk, app-admin/testdisk, False, '', 'ntfs reiserfs')
#
# TODO: switch to augeas instead of file.replace

{%- macro install(
    pkg,
    slot=''
) %}

{% if slot == '' %}
install-package-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
    - version: latest
{% else %}
install-package-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
    - version: latest
    - slot: {{ slot }}
{% endif %}

{%- endmacro %}


# Macro for 'soft' unmasking packages (adding to accept_keywords folder)
# example usage:
# accept_keywords(firefox, www-client/firefox)
#
# TODO: switch to augeas instead of file.replace

{%- macro accept_keywords(
    pkg_name,
    pkg
) %}

{% set keywords_file = '/etc/portage/package.accept_keywords/' + pkg_name %}

{% if not salt['file.file_exists'](keywords_file) %}
create-keywords-file-{{ pkg }}:
  file.managed:
    - name: {{ keywords_file }}
    - user: root
    - group: root
    - mode: 644
    - replace: False
{% endif %}

update-keywords-file-{{ pkg }}:
  file.replace:
    - name: {{ keywords_file }}
    - pattern: .*{{ pkg }}$
    - repl: {{ pkg }}
    - append_if_not_found: True
    - backup: False

{%- endmacro %}


# Macro for adding license for package
# example usage:
# accept_license(vivaldi, www-client/vivaldi, True, 'Vivaldi', '')
#
# TODO: switch to augeas instead of file.replace

{%- macro license(
    pkg_name,
    pkg,
    license
) %}

{% set license_file = '/etc/portage/package.license/' + pkg_name %}

{% if license %}
{% if not salt['file.file_exists'](license_file) %}
create-license-file-{{ pkg }}:
  file.managed:
    - name: {{ license_file }}
    - user: root
    - group: root
    - mode: 644
    - replace: False
{% endif %}

update-license-file-{{ pkg }}:
  file.replace:
    - name: {{ license_file }}
    - pattern: .*{{ pkg }} .*
    - repl: "{{ pkg }} {{ license }}"
    - append_if_not_found: True
    - backup: False
{% endif %}

{%- endmacro %}


# Macro for adding use flags for package
# example usage:
# use(testdisk, app-admin/testdisk, "ntfs reiserfs")
#
# TODO: switch to augeas instead of file.replace

{%- macro use(
    pkg_name,
    pkg,
    flags
) %}

{% set use_file = '/etc/portage/package.use/' + pkg_name %}

{% if not salt['file.file_exists'](use_file) %}
create-use-file-{{ pkg }}:
  file.managed:
    - name: {{ use_file }}
    - user: root
    - group: root
    - mode: 644
    - replace: False
{% endif %}

update-use-file-{{ pkg }}:
  file.replace:
    - name: {{ use_file }}
    - pattern: .*{{ pkg }} .*
    - repl: "{{ pkg }} {{ flags }}"
    - append_if_not_found: True
    - backup: False

{%- endmacro %}
