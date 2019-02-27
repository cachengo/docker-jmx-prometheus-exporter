export IMAGE_TAG=$(cat VERSION)
export AARCH=`uname -m`
export IMAGE_NAME=jmx-prometheus-exporter

docker build -t cachengo/$IMAGE_NAME-$AARCH:$IMAGE_TAG .
docker push cachengo/$IMAGE_NAME-$AARCH:$IMAGE_TAG
