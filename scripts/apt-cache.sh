if test -n "${USE_APT_CACHER_NG}"; then
  gateway=$(networkctl status 2>&- | grep Gateway | cut -d':' -f 2 | cut -d' ' -f 2 )
  echo "Acquire::http::Proxy \"http://${gateway}:3142\";" > /etc/apt/apt.conf
fi
