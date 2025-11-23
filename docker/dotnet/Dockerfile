# Use the official .NET 9 SDK to build the application
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build-eshop

# Copy the project files and restore dependencies

WORKDIR /app

COPY ./Eshop/Eshop.csproj ./Eshop/Eshop.csproj


WORKDIR /app/Eshop

RUN dotnet restore


WORKDIR /app

COPY ./Eshop ./Eshop


WORKDIR /app/Eshop

RUN dotnet build
RUN dotnet publish -c Release -o out


# Publish the application
RUN dotnet publish -o /app/Eshop/publish

# Use the official .NET 9 runtime for running the application
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime-eshop
WORKDIR /app
COPY --from=build-Eshop /app/Eshop/publish .

# Set the entry point
ENTRYPOINT ["dotnet", "Eshop.dll"] 