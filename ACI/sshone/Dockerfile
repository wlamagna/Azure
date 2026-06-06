# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Install the SSH server
RUN apt-get update && apt-get install -y openssh-server

# Create an SSH user
RUN useradd -m -s /bin/bash sshuser && echo 'sshuser:<PUT A PASSWORD>' | chpasswd


# Optional: allow password auth (often needed)
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Start the SSH service
CMD ["/usr/sbin/sshd", "-D"]
