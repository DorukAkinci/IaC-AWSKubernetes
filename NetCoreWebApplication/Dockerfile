FROM mcr.microsoft.com/dotnet/core/aspnet:2.2

WORKDIR /app
COPY ./SampleWebApiAspNetCore/output .
EXPOSE 5000
ENV ASPNETCORE_URLS http://*:5000
ENV ASPNETCORE_ENVIRONMENT docker
ENTRYPOINT ["dotnet", "SampleWebApiAspNetCore.dll"]