#!/bin/bash
LB_NAME=${1:-LOAD_BALANCER_NAME}
DNS="${2:-foobar.example.com}"

_configure_gclb_and_dns() {
    IPNAME="$1"
    DNSNAME="$2"
    #echo TODO da giu... pasrametrico in prod test/staging ehheheh
        # Creo IP pubblico
    echodo gcloud compute addresses create "$IPNAME" --global --ip-version IPV4 ||
        echo ok probably IP already exists: &&
             gcloud compute addresses list | grep "$IPNAME"
    GCLB_IP=$(             gcloud compute addresses list | grep "$IPNAME" | colonna 2 )
    yellow "Ill leave it with you to do something to associate IP to DNS. If you are Riccardo I have an idea..."
    host "$DNSNAME" ||
        rosso "Host doesnt resolve. If you are Riccardo, you can launch: dns-setup-palladius.sh $DNSNAME $GCLB_IP"
}

if [ $# -lt 2 ]; then
    echo "Usage: $(basename $0) <LB_NAME> <host.domain.com>"
    echo "  [example] $(basename $0) my-app-prod app-prod.palladius.it" | lolcat
    exit 11
else
    _configure_gclb_and_dns "$LB_NAME" "$DNS"
fi