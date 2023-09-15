VERSION="$1"
OVERRIDE="$2"
REPO_TOKEN="$3"
GITHUB_REPOSITORY=$(echo "$GITHUB_REPOSITORY" | awk '{print tolower($0)}')

echo "VERSION=$VERSION"
echo "OVERRIDE=$OVERRIDE"

docker login ghcr.io -u "${GITHUB_REF}" -p "${REPO_TOKEN}"

VERSION=$VERSION docker compose -f docker-compose.yml -f "$OVERRIDE" build

IMAGES_IN_DIR=$(docker ps -aq)

echo "Images in dir:"
echo ""
echo $IMAGES_IN_DIR
echo ""

#IMAGES=$(docker inspect --format='{{.Config.Image}}' $IMAGES_IN_DIR)
IMAGES=$(docker inspect --size --format='{{.Id}}' "$IMAGES_IN_DIR")

echo "IMAGES: $IMAGES"



for IMAGE in $IMAGES; do
    echo "IMAGE: $IMAGE"
    
    NAME=$(basename "${GITHUB_REPOSITORY}").$(docker inspect --format '{{ index .Config.Labels "name" }}' "$IMAGE")
    TAG="ghcr.io/${GITHUB_REPOSITORY}/$NAME:$VERSION"

    docker tag "$IMAGE" "$TAG"
    docker push "$TAG"
done
