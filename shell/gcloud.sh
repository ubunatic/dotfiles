# GCloud/GKE Hacks
# ================

cluster(){
   local zone="${2:-europe-west3}"
   gcloud container clusters get-credentials --zone "$zone" "$@"
}

gconfig() { gcloud config "$@"; }
gcfg()    { gcloud config "$@"; }
gauth()   { gcloud auth   "$@"; }

reauth() {
   gcloud auth login --update-adc
}

unimpersonate() {
   gcloud config unset auth/impersonate_service_account
}

impersonate() {
   if test -z "$1"
   then error "service account missing, see SA_* env vars"; return 1;
   fi
   gcloud config set auth/impersonate_service_account "$@"
}

# Add gcloud completion and PATH if not present.
if test -e "$APPS/google-cloud-sdk" && test -n "$ZSH_VERSION" && ! type gcloud > /dev/null
then
    # The next line updates PATH for the Google Cloud SDK.
    source "$APPS/google-cloud-sdk/path.zsh.inc"
    source "$APPS/google-cloud-sdk/completion.zsh.inc"
fi
