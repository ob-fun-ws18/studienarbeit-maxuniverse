# Use the existing Haskell image as our base
FROM debian:latest

# Checkout our code onto the Docker container
WORKDIR /app
ADD . /app

# Upgrade system
RUN apt update
RUN apt install -y aptitude
RUN aptitude dist-upgrade -y
RUN aptitude install -y net-tools default-mysql-server default-mysql-client curl ctop htop vim supervisor
RUN supervisorctl mysqld start

# Install haskell
RUN aptitude install -y ghc haskell-platform 
RUN curl -sSL https://get.haskellstack.org/ | sh

# clean packages
RUN aptitude clean

# Build and test our code, then install the “run-server” executable
RUN stack setup
RUN stack build
CMD ["stack", "exec", "dynkellServer-exe"]

# Expose a port to run our application
EXPOSE 7000
