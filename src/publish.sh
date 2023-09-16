VERSION="$1"
OVERRIDE="$2"
REPO_TOKEN="$3"
GITHUB_REPOSITORY=$(echo "$GITHUB_REPOSITORY" | awk '{print tolower($0)}')

echo "VERSION=$VERSION"
echo "OVERRIDE=$OVERRIDE"

docker login ghcr.io -u "${GITHUB_REF}" -p "${REPO_TOKEN}"

VERSION=$VERSION docker compose -f "$OVERRIDE" build

echo "GETTING ALL IMAGES LIST"
echo "$(docker images -a)"

delimiter="/"
REPO_SUFFIX="${GITHUB_REPOSITORY#*$delimiter}"
REPO_SUFFIX="^$REPO_SUFFIX-"

echo "REPO suffix: $REPO_SUFFIX"

IMAGES=$(docker images -a | grep "$REPO_SUFFIX" | awk '{ print $3 }' )

echo "OUR IMAGES LIST: $IMAGES"

for IMAGE in $IMAGES; do
    echo ""
    echo ""
    echo "IMAGE: $IMAGE"
    
    NAME=$(basename "${GITHUB_REPOSITORY}").$(docker inspect --format '{{ index .Config.Labels "name" }}' "$IMAGE")
    TAG="ghcr.io/${GITHUB_REPOSITORY}/$NAME:$VERSION"

    docker tag "$IMAGE" "$TAG"
    docker push "$TAG"
done
