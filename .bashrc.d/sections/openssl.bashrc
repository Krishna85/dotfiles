#!/bin/bash

# OpenSSL stuff
ssl() {
  CMD=$1

  if [[ -z $1 ]]; then
    echo "Missing command. Try one of:-"
    echo "
    LOCAL COMMANDS
    mod             - get the modulus for a certificate
    kmod            - get the modulus for a key
    hash            - get the hash for a certificate
    ihash           - get the issuer hash for a certificate
    text            - get the text output for a certificate
    exp             - get the expiry for a certificate
    gencsr          - generate a key and a CSR
    issuer          - get the issuer for a certificate
    sub             - get the subject of a certificate (inc SANs)

    REMOTE COMMANDS
    rmod            - get the modulus for a host's certificate
    rhash           - get the hash for a host's certificate
    rihash          - get the issuer hash for a host's certificate
    rtext           - get the text output for a host's certificate
    rexp            - get the expiry for a host's certificate
    rissuer         - get the issuer for a host's certificate
    rsub            - get the subject of a host's certificate (inc SANs)

    OTHER
    c               - connect to a host
    "
    return 1
  fi

  if [[ -z $2 ]]; then
    echo "Missing argument."
    return 1
  fi

  case ${CMD} in
    mod|modulus)
      FILE=$2
      openssl x509 -in ${FILE} -noout -modulus
      ;;
    kmod|kmodulus)
      FILE=$2
      openssl rsa -in ${FILE} -noout -modulus
      ;;
    hash)
      FILE=$2
      openssl x509 -in ${FILE} -noout -hash
      ;;
    ihash|issuer-hash)
      FILE=$2
      openssl x509 -in ${FILE} -noout -issuer_hash
      ;;
    text)
      FILE=$2
      openssl x509 -in ${FILE} -noout -text
      ;;
    exp|expiry)
      FILE=$2
      openssl x509 -in ${FILE} -noout -text | egrep "Not (Before|After)"
      ;;
    gencsr)
      CN=$2
      if [[ -z ${CN} ]]; then
        echo "No common name given."
        return 1
      fi
      openssl req -new -newkey rsa:2048 -nodes -days 365 -out ${CN}.csr -keyout ${CN}.key
      ;;
    issuer)
      FILE=$2
      openssl x509 -in ${FILE} -noout -issuer
      ;;
    sub|subject)
      FILE=$2
      openssl x509 -in ${FILE} -noout -text | egrep "(Subject:|DNS:)" | awk '{$1=$1};1'
      ;;
    rmod|remote-modulus)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      echo "" | openssl s_client -connect ${HOST_PORT} 2>&1 | openssl x509 -noout -modulus
      ;;
    rhash|remote-hash)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      echo "" | openssl s_client -connect ${HOST_PORT} 2>&1 | openssl x509 -noout -hash
      ;;
    rihash|remote-issuer-hash)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      echo "" | openssl s_client -connect ${HOST_PORT} 2>&1 | openssl x509 -noout -issuer_hash
      ;;
    rtext|remote-text)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      echo "" | openssl s_client -connect ${HOST_PORT} 2>&1 | openssl x509 -noout -text
      ;;
    rexp|remote-expiry)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      echo "" | openssl s_client -connect ${HOST_PORT} 2>&1 | openssl x509 -noout -text | egrep "Not (Before|After)"
      ;;
    rissuer|remote-issuer)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      echo "" | openssl s_client -connect ${HOST_PORT} 2>&1 | openssl x509 -noout -issuer
      ;;
    rsub|remote-subject)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      echo "" | openssl s_client -connect ${HOST_PORT} 2>&1 | openssl x509 -noout -text | egrep "(Subject:|DNS:)" | awk '{$1=$1};1'
      ;;
    c|connect)
      HOST_PORT=$2
      if [[ ! ${HOST_PORT} =~ .*:.* ]]; then
        echo "No port, assuming 443"
        HOST_PORT="${HOST_PORT}:443"
      fi
      openssl s_client -connect ${HOST_PORT}
      ;;
    *)
      ;;
  esac
}

