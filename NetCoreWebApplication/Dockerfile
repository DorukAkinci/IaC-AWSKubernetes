FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build

WORKDIR /app
COPY ./SampleWebApiAspNetCore/*.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o output


FROM mcr.microsoft.com/dotnet/core/aspnet:2.2

WORKDIR /app
COPY --from=build /app/SampleWebApiAspNetCore/output .
EXPOSE 5000
ENV ASPNETCORE_URLS http://*:5000
ENV ASPNETCORE_ENVIRONMENT docker
ENTRYPOINT ["dotnet", "SampleWebApiAspNetCore.dll"]
