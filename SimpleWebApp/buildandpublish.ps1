

#Need to setup the ECR_REGISTRY and ECR_REPOSITORY as environment variables.
#Or switch them out for the proper names when deployed
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .\SimpleWebApp\
docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG 