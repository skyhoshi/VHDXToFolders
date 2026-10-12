# $command1 = "-c 'apk add nodejs npm' -c /bin/sh"




docker run --name nodetest --entrypoint /bin/sh -p 8080:8080 -it hubpcontainersacr.azurecr.io/library/dotnet/aspnet:8.0-alpine 

# -c 'apk add nodejs npm' -c 'node -v' -c 'npm -v'

# -c /bin/sh
docker exec -it nodetest sh -c "apk add nodejs npm"
# docker exec -it nodetest sh -c "node -v"
# docker exec -it nodetest sh -c "npm -v"
# #docker exec -it nodetest sh -c "npm install -g http-server"
# #docker exec -it nodetest sh -c "http-server -p 8080"

# #docker start nodetest -a -i -t
# docker attach nodetest
# #docker rm nodetest


docker debug --command "node -v" nodetest
docker debug --command "npm -v" nodetest
