#!/bin/bash
# require namespace name or "all" as parameter
# require awk, jq, trivy to be installed
NAMESPACE_ARG=$1

if [ "$NAMESPACE_ARG" == "all" ]; then
    all_namespaces="$(kubectl get ns --no-headers -o custom-columns=":metadata.name" )"
elif [ -n "$NAMESPACE_ARG" ]; then
    all_namespaces=$NAMESPACE_ARG
else
    echo "Namespace name (or 'all' for all namespaces) is expected as parameter."
    exit 1
fi

declare -A scanned
all_images=""
for single_ns in $all_namespaces; do
    ns_pods=$(kubectl get pods -n $single_ns --no-headers -o custom-columns=":metadata.name")
    for ns_pod in $ns_pods; do
        echo "Scanning pod $ns_pod"
        images=$(kubectl get pod $ns_pod -n $single_ns -o jsonpath='{.spec.containers[*].image}')
        for image in $images; do
            echo "- Image: $image"
            if [[ -z "${scanned[$image]}" ]]; then
                scanned[$image]=$(./bin/trivy image --severity HIGH,CRITICAL --format json $image 2>/dev/null \
                    | jq -r '.Results[].Vulnerabilities | length' 2>/dev/null \
                    | awk '{sum+=$1} END{print sum+0}')
            fi

            all_images+="$image,$ns_pod,$single_ns,${scanned[$image]}"$'\n'
        done
    done
done
echo "------------------- Scan completed ----------------------"
# This output list unique images, but will miss pods with duplicated images
# echo "$all_images" | sort -t, -k1,1 -u | column -ts, -N Image,Pod,Namespace

# This output show all pods, for better visibility duplicated image names not printed 
echo "$all_images" | sort -t, -k1,1 | awk -F, 'BEGIN{OFS=","} seen[$1]++ {$1=""} 1' | column -ts, -N Image,Pod,Namespace,Vulnerabilities | tee scan_images.output

