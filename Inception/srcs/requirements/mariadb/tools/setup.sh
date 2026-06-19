#!/bin/bash
# Define the interpreter to be used to execute this script (Bash).

set -eu
# Enable strict mode: exit immediately if a command fails (-e) or if an undefined variable is used (-u).

SOCKET="/run/mysqld/mysqld.sock"
# Define the path for the MariaDB Unix socket file used for secure local communication.

INIT_MARKER="/var/lib/mysql/.inception_initialized"
# Define a hidden file path used as a state flag to check if the database has already been initialized.

read_secret() {
# Define a function named 'read_secret' to securely read passwords from files (Docker secrets).

    if [ ! -f "$1" ]; then
    # Check if the file passed as the first argument ($1) does NOT exist.

        echo "Missing secret file: $1" >&2
        # Print an error message to the standard error stream (stderr).

        exit 1
        # Exit the script with an error code (1) to prevent further execution.
    fi
    # End of the if condition.

    tr -d '\r\n' < "$1"
    # Read the file content and remove any carriage returns (\r) or newlines (\n) to ensure a clean password string.
}
# End of the 'read_secret' function.

MYSQL_PASSWORD="$(read_secret "${MYSQL_PASSWORD_FILE:-/run/secrets/db_password}")"
# Read the regular user password from the file defined in MYSQL_PASSWORD_FILE (or default to /run/secrets/db_password).

MYSQL_ROOT_PASSWORD="$(read_secret "${MYSQL_ROOT_PASSWORD_FILE:-/run/secrets/db_root_password}")"
# Read the root password from the file defined in MYSQL_ROOT_PASSWORD_FILE (or default to /run/secrets/db_root_password).

if [ -z "${MYSQL_DATABASE:-}" ] || [ -z "${MYSQL_USER:-}" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
# Check if any of the required variables (database name, user, or passwords) are empty (-z).

    echo "MariaDB configuration is incomplete" >&2
    # Print an error message to stderr if configuration is missing.

    exit 1
    # Exit the script to avoid setting up a broken or insecure database.
fi
# End of the variable validation block.

mkdir -p /run/mysqld /var/lib/mysql
# Create the necessary directories for the MariaDB socket and data, ignoring errors if they already exist (-p).

chown -R mysql:mysql /run/mysqld /var/lib/mysql
# Recursively (-R) change the owner and group of these directories to the 'mysql' user.

if [ ! -d /var/lib/mysql/mysql ]; then
# Check if the core 'mysql' system database directory does NOT exist (meaning it's a completely fresh volume).

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null
    # Initialize the MariaDB data directory and system tables, running as the 'mysql' user, and skip creating the test database.
fi
# End of the system tables installation check.

if [ ! -f "$INIT_MARKER" ]; then
# Check if the initialization marker file is missing (meaning this one-time setup has never run before).

    mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking --socket="$SOCKET" &
    # Start the MariaDB server in the background (&) with networking disabled for secure local configuration.

    pid="$!"
    # Save the Process ID (PID) of the background MariaDB server we just started.

    ready=0
    # Initialize a variable 'ready' to 0 (false) to track the server's health status.

    for _ in $(seq 1 60); do
    # Start a loop that will run up to 60 times (acting as a 60-second timeout).

        if mysqladmin --socket="$SOCKET" ping --silent; then
        # Ping the local database using the socket to check if it is awake and responding.

            ready=1
            # If the ping is successful, set 'ready' to 1 (true).

            break
            # Exit the loop immediately since the server is up and running.
        fi
        # End of the ping check.

        sleep 1
        # Wait for 1 second before trying to ping again.
    done
    # End of the healthcheck polling loop.

    if [ "$ready" -ne 1 ]; then
    # Check if the server failed to become ready after 60 seconds.

        echo "MariaDB did not become ready during initialization" >&2
        # Print a timeout error message to stderr.

        kill "$pid" 2>/dev/null || true
        # Attempt to kill the stuck MariaDB process, suppressing errors if it's already dead.

        exit 1
        # Exit the script with an error code.
    fi
    # End of the readiness validation.

    mysql --socket="$SOCKET" -u root <<SQL
    # Open a MySQL client session as 'root' using the socket, feeding it the SQL commands below (Here-Doc).

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
-- Change the root user's password to the secure one we read from the secret file.

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
-- Create the WordPress database if it doesn't already exist.

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
-- Create the regular WordPress user and set their password, allowing connections from any network interface ('%').

ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
-- Ensure the password is updated just in case the user already existed from a previous partial run.

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
-- Grant all permissions on the WordPress database to our newly created user.

FLUSH PRIVILEGES;
-- Reload the grant tables to apply the new user and privilege changes immediately.

SQL
    # End of the SQL Here-Doc input.

    mysqladmin --socket="$SOCKET" -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    # Gracefully shut down the temporary background MariaDB server using the new root password.

    wait "$pid"
    # Wait for the background MariaDB process to completely terminate before moving to the final step.

    touch "$INIT_MARKER"
    # Create the marker file so this entire initialization block is skipped on future container restarts.
fi
# End of the one-time setup block.

exec mariadbd --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
# Replace the current bash script process with the MariaDB server (making it PID 1), and open it to network connections (0.0.0.0).