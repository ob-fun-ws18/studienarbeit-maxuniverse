# Use the existing Haskell image as our base
FROM haskell:latest

# Checkout our code onto the Docker container
ADD . /app
WORKDIR /app

# Build and test our code, then install the “run-server” executable
RUN stack setup
RUN stack build --test --copy-bins

# Expose a port to run our application
EXPOSE 7001

# Run the server command
CMD [“stack”, "exec", "dynkellClient-exe"]
