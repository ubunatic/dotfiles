#!/usr/bin/env bash

config="$(cd "$(dirname "$0")" && pwd)"
cd "$config" || exit 1

GPG_RECIPIENT="${GPG_RECIPIENT:-Uwe Jugel}"

plain_files() { find . -name "*.yml"; }
vault_files() { find . -name "*.gpg"; }

cryptinfo() {
     for  f in $(vault_files)
     do   echo "File: $f"
          gpg --list-packets "$f" | grep -E 'keyid|public key'
          echo "----"
     done
}

encrypt() {
     rm -f config.tar.gz.gpg
     tar -czf - . | gpg --encrypt --recipient "$GPG_RECIPIENT" --output "config.tar.gz.gpg"
}

decrypt() {
     gpg --decrypt "config.tar.gz.gpg" | tar -xzf -
}

upload() {
     # gsutil cp config.tar.gz.gpg gs://my-bucket/
     echo "Upload function not implemented. Please implement as needed."
}

usage() {
     cat << EOF
Usage: $0 command

Commands:
  encrypt     Encrypt the entire configuration directory into a single config.tar.gz.gpg file.
  decrypt     Decrypt the config.tar.gz.gpg file into the current directory.
  info        Show information about the encrypted .gpg files.
  usage       Show this help message.

EOF
}

case "$1" in
     e*) encrypt;;
     d*) decrypt;;
     i*) cryptinfo;;
     u*) usage;;
     *)  echo "Unknown command: $1"
         usage
         exit 1
     ;;
esac
