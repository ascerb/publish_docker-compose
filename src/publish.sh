VERSION="$1"
OVERRIDE="$2"
REPO_TOKEN="$3"
GITHUB_REPOSITORY=$(echo "$GITHUB_REPOSITORY" | awk '{print tolower($0)}')

echo "VERSION=$VERSION"
echo "OVERRIDE=$OVERRIDE"

docker login ghcr.io -u "${GITHUB_REF}" -p "${REPO_TOKEN}"

VERSION=$VERSION docker compose -f "$OVERRIDE" build

echo "REPO: $GITHUB_REPOSITORY"

DIM=$(docker images -aq)
echo "DIM1 $DIM"

DIM=$(docker images -a)
echo "DIM2 $DIM"

DIM=$(docker ps -a)
echo "DIM3 $DIM"

DIM=$(docker ps -aq)
echo "DIM4 $DIM"

IMAGES=$(docker inspect --format='{{.Image}}' "$(docker ps -aq)")

echo "IMAGES: $IMAGES"

for IMAGE in $IMAGES; do
    echo "IMAGE: $IMAGE"
    
    NAME=$(basename "${GITHUB_REPOSITORY}").$(docker inspect --format '{{ index .Config.Labels "name" }}' "$IMAGE")
    TAG="ghcr.io/${GITHUB_REPOSITORY}/$NAME:$VERSION"

    docker tag "$IMAGE" "$TAG"
    docker push "$TAG"
done
