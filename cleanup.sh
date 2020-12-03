#!/bin/bash

containers=$(docker container ls --format '{{.ID}}')
images=$(docker image ls --format '{{.ID}}')

for id in ${containers}
do
con_inspect=$(docker inspect --format='{{.Name}}' ${id})
if [[ ${con_inspect}  == "<none>" ]] || [[ ${con_inspect} == "app" ]]
then
echo "$(docker stop ${id})"
echo "$(docker rm ${id})"
fi
done

for id in ${images}
do
img_inspect=$(docker image inspect --format='{{.RepoTags}}' ${id})
if [[ ${img_inspect} == "[]" ]] || [[ ${img_inspect} == "app" ]]
then
echo "$(docker rmi ${id})"
fi
done

echo "$(docker network disconnect testNetwork app)"
echo "$(docker network disconnect testNetwork jenkins)"
echo "$(docker network rm testNetwork)"
