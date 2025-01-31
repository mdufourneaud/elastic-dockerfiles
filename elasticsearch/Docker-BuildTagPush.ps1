param (
    [string] $Builder       = "amd64-arm64",
    [string] $Platform      = "linux/amd64,linux/arm64",
    [bool]   $CreateBuilder = $true
)

if ($CreateBuilder) {
    docker buildx create --name="$Builder" --platform="$Platform"
}

$contextPath         = $PSScriptRoot
$dockerfilePath      = Join-Path -Path:$PSScriptRoot -ChildPath:"Dockerfile"
$fullyQualifiedImage = "docker.io/mdufourneaud4datagalaxy/elastic-elasticsearch:8.17.1-debian-12-slim"
docker buildx build --builder="$Builder" --file="$dockerfilePath" --platform="$Platform" --push --tag="$fullyQualifiedImage" $contextPath