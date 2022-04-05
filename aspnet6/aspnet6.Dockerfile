# https://hub.docker.com/_/microsoft-dotnet
FROM registry.nexdev.net:5050/docker/dotnet/core/sdk:6.0-alpine AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnet6/*.csproj ./aspnet6/
RUN dotnet restore -v n
#RUN dotnet restore -r linux-musl-x64

# copy everything else and build app
COPY aspnet6/. ./aspnet6/
WORKDIR /source/aspnet6
#RUN dotnet publish -c release -o /app -r linux-musl-x64 --self-contained false --no-restore
RUN dotnet publish -r linux-musl-x64 --self-contained false -o /app

# final stage/image
FROM registry.nexdev.net:5050/docker/dotnet/core/aspnet:6.0-alpine-amd64 AS base
WORKDIR /app
COPY --from=build /app ./
RUN apk add --update curl && \
    rm -rf /var/cache/apk/*
RUN curl --version
ENV TZ="America/La_Paz"
ENTRYPOINT ["dotnet", "aspnet6.dll"]
#ENTRYPOINT ["./aspnetapp"]
