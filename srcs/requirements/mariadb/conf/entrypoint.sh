#!/bin/bash
set -e

echo "📦 Installation de la base de données..."

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Démarrage du serveur en arrière-plan
echo "🚀 Lancement temporaire de MariaDB..."
/usr/sbin/mysqld --user=mysql --skip-networking &
MARIADB_PID=$!

# Attente du démarrage complet
echo "⏳ Attente du serveur MariaDB..."
until mariadb-admin ping --silent; do
    sleep 1
done

echo "✅ MariaDB prêt, initialisation de la base..."

mariadb << EOF
DROP DATABASE IF EXISTS $MYSQL_DATABASE;
CREATE DATABASE $MYSQL_DATABASE;
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "🛑 Arrêt du serveur temporaire..."
kill $MARIADB_PID
wait $MARIADB_PID

echo "✅ Installation terminée"

exec /usr/sbin/mysqld --user=mysql
