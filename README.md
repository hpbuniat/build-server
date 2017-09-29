## build-server
Docker container for building our web app without the need of modifying the host.

#### Usage
Run the container from your project root directory.

    #!/bin/bash
    docker run -it --rm \
        -e "HOME=/home/$USER" \
        -e "USER" \
        -e "UID=$(id -u)" \
        -e "GID=$(id -g)" \
        -v ~:/home/$USER \
        -v /etc/localtime:/etc/localtime:ro \
        -v $PWD:/app \
    hpbuniat/build-server

This runs the container with the common settings. It requires a ```build/``` directory in your project root.
From the build dir it runs a ```robo install```.

You can run different build commands by providing an alternative command on startup.

    #!/bin/bash
        docker run -it --rm \
            -e "HOME=/home/$USER" \
            -e "USER" \
            -e "UID=$(id -u)" \
            -e "GID=$(id -g)" \
            -v ~:/home/$USER \
            -v /etc/localtime:/etc/localtime:ro \
            -v $PWD:/app \
        hpbuniat/build-server YOUR_COMMAND
