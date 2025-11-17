#!/bin/bash
if [[ "$OSTYPE" == "linux"* ]]; then

    # Linux
    SCRIPT=`realpath $0`
    SCRIPTPATH=`dirname $SCRIPT`

    export PATH=$SCRIPTPATH:$PATH:/lib64
    exec "$SCRIPTPATH/mmClient-rhel9.exe" -user mmUser -password mmUser -networked Y -secure -port 443 -warn 4 -hostname cg.miramo.com "$@"
else
        echo "$OSTYPE not supported"
fi
