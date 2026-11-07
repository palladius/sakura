default:
    @just --list

# Lists available targets
list: default

# Show current version
version:
    @cat VERSION

# Cleans up temporary artifacts
clean:
    @echo "TODO cleanup"

# Installs software
install:
    sbin/make-install.sh

# Runs test suite across subdirectories
test:
    #!/usr/bin/env bash
    for dir in lib/recipes/ docz/richelp/; do
        if [ -d "$dir" ]; then
            echo "Testing subdir: $dir"
            make -C "$dir" || true
        fi
    done

# Runs Ruby unit tests
test-ruby:
    rake test

# Fills autocomplete scripts (e.g. gcutil)
autocomplete:
    make -C bashrc.d/services.d/autocomplete/gcutil.auto/

# Builds latest Docker image locally
docker-build:
    docker build -t=palladius/sakura:latest .

# Pushes Docker images to palladius/sakura:latest
docker-push: docker-build
    docker push palladius/sakura:latest

# Runs locally in bash for testing
docker-run:
    docker run -it -p 22180:80 --name sakura-on-apache2-local22180 palladius/sakura:latest

docker-run2:
    docker run -P --name sakura-on-apache2-anyport49k palladius/sakura:latest

# Builds and runs Docker container
docker: docker-build docker-run
    @echo "Building and running... on port 22180"
