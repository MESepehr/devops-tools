FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build-eshop

# Copy the project files and restore dependencies
WORKDIR /app

COPY ./Eshop/Eshop.csproj ./Eshop/Eshop.csproj

WORKDIR /app/Eshop

RUN dotnet restore

WORKDIR /app

COPY ./Eshop ./Eshop

WORKDIR /app/Eshop

RUN dotnet publish -c Release -o /app/Eshop/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime-eshop
WORKDIR /app
COPY --from=build-eshop /app/Eshop/publish .

ENTRYPOINT ["dotnet", "Eshop.dll"]
