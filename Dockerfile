# https://hub.docker.com/_/microsoft-dotnet
FROM registry.nexdev.net:5050/docker/dotnet/core/sdk:6.0
#registry.nexdev.net:5050/docker/dotnet/core/sdk:6.0-alpine AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetapp/*.csproj ./aspnetapp/
RUN dotnet restore -v n
#RUN dotnet restore -r linux-musl-x64

# copy everything else and build app
COPY aspnetapp/. ./aspnetapp/
WORKDIR /source/aspnetapp
#RUN dotnet publish -c release -o /app -r linux-musl-x64 --self-contained false --no-restore
RUN dotnet publish -r linux-musl-x64 --self-contained false -o /app

# final stage/image
FROM registry.nexdev.net:5050/docker/dotnet/core/aspnet:6.0 AS base
#registry.nexdev.net:5050/docker/dotnet/core/aspnet:6.0-alpine-amd64 AS base
WORKDIR /app
COPY --from=build /app ./
RUN apk add --update curl && \
    rm -rf /var/cache/apk/*
RUN curl --version
# See: https://github.com/dotnet/announcements/issues/20
# Uncomment to enable globalization APIs (or delete)
# ENV \
#     DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
#     LC_ALL=en_US.UTF-8 \
#     LANG=en_US.UTF-8
# RUN apk add --no-cache icu-libs
ENV TZ="America/La_Paz"
ENTRYPOINT ["dotnet", "aspnetapp.dll"]
#ENTRYPOINT ["./aspnetapp"]
