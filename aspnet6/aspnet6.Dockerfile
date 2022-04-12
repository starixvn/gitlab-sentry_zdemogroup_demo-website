# https://hub.docker.com/_/microsoft-dotnet
FROM registry.nexdev.net:5050/docker/dotnet/core/sdk:6.0-alpine AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetapp/*.csproj ./aspnetapp/
RUN dotnet restore -v n 
#RUN dotnet restore -r linux-musl-x64

# copy everything else and build app
COPY aspnetapp/. ./aspnetapp/
WORKDIR /source/aspnetapp
RUN dotnet publish -r linux-x64 --self-contained false -o /app
#RUN dotnet publish -c release -o /app -r linux-musl-x64 --self-contained false --no-restore
# final stage/image
#FROM registry.nexdev.net:5050/docker/dotnet/core/aspnet:6.0-alpine-amd64 AS base
#RUN apk add --update curl && \
#    rm -rf /var/cache/apk/*
FROM registry.nexdev.net:5050/docker/dotnet/core/aspnet:6.0 AS base
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "aspnetapp.dll"]
#ENTRYPOINT ["./aspnetapp"]
