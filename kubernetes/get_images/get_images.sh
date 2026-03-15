#!/bin/bash
# require namespace name or "all" as parameter

NAMESPACE_ARG=$1

if [ "$NAMESPACE_ARG" == "all" ]; then
    all_namespaces="$(kubectl get ns --no-headers -o custom-columns=":metadata.name" )"
elif [ -n "$NAMESPACE_ARG" ]; then
    all_namespaces=$NAMESPACE_ARG
else
    echo "Namespace name (or 'all' for all namespaces) is expected as parameter."
    exit 1
fi

all_images=""
for single_ns in $all_namespaces; do
    ns_pods=$(kubectl get pods -n $single_ns --no-headers -o custom-columns=":metadata.name")
    for ns_pod in $ns_pods; do
        images="$(kubectl get pod $ns_pod -n $single_ns -o jsonpath='{.spec.containers[*].image}')"
        for image in $images; do
            all_images+="$image,$ns_pod,$single_ns"$'\n'
        done
    done
done
# This output list unique images, but will miss pods with duplicated images
# echo "$all_images" | sort -t, -k1,1 -u | column -ts, -N Image,Pod,Namespace

# This output show all lines, but for better visibility don't print duplicated image names
echo "$all_images" | awk -F, 'BEGIN{OFS=","} seen[$1]++ {$1=""} 1' | column -ts, -N Image,Pod,Namespace
