

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash \
    && apt-get install nodejs -yq

RUN apt-get install libcairo2-dev libjpeg-dev libpango1.0-dev libgif-dev build-essential g++ -yq


# Copy app and tests
COPY *.sln ./
COPY test ./test
COPY src ./src

# Restore nuget packages
RUN dotnet restore

# Test & Build
RUN dotnet test test/LoadTestToolbox.Tests.csproj -c Release
RUN dotnet publish -c Release -o out

# Copy charting files
COPY *.json ./
COPY *.js ./


# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as runtime

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash \
    && apt-get install nodejs -yq
RUN apt-get install libcairo2-dev libjpeg-dev libpango1.0-dev libgif-dev build-essential g++ -yq

WORKDIR /app
COPY --from=build-env /app/*.json ./

# Run npm install
RUN npm install
RUN npm install canvas

COPY --from=build-env /app/*.js ./
COPY --from=build-env /app/out .

RUN ls -la ./
ENTRYPOINT ["dotnet", "LoadTestToolbox.dll"]