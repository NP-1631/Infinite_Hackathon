# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy solution file and restore dependencies
COPY RagService.sln ./
COPY src/RagService.Core/RagService.Core.csproj src/RagService.Core/
COPY src/RagService.Infrastructure/RagService.Infrastructure.csproj src/RagService.Infrastructure/
COPY src/RagService.Api/RagService.Api.csproj src/RagService.Api/
RUN dotnet restore

# Copy all source files and publish
COPY src/ src/
RUN dotnet publish src/RagService.Api/RagService.Api.csproj -c Release -o /app/publish

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Copy documents folder for initial indexing
COPY docs/ docs/

# Set up port dynamically for Render
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["sh", "-c", "dotnet RagService.Api.dll --urls http://0.0.0.0:${PORT}"]
