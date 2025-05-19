#!/bin/bash
set -e

# Vérification des variables d'environnement
: "${MYSQL_DATABASE:?Variable MYSQL_DATABASE non définie}"
: "${MYSQL_USER:?Variable MYSQL_USER non définie}"
: "${MYSQL_PASSWORD:?Variable MYSQL_PASSWORD non définie}"

echo "📦 Installation de la base de données..."

# Si la DB existe déjà, on ne refait pas l'init
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "✅ Base de données déjà initialisée, démarrage normal..."
    exec /usr/sbin/mysqld --user=mysql
fi

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

echo "🛠 Initialisation de la base..."
mysql_install_db --user=mysql > /dev/null

# Lancement de mysqld en arrière-plan (pas exec)
echo "🚀 Lancement MariaDB pour initialisation..."
/usr/sbin/mysqld --user=mysql --skip-networking &
pid="$!"

echo "⏳ Attente de MariaDB (mariadb-admin --wait)..."
mariadb-admin --wait=30 --silent ping || {
    echo "❌ MariaDB n'a pas démarré à temps."
    kill "$pid"
    exit 1
}
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
kill "$pid"
wait "$pid"

echo "✅ Installation terminée"

exec /usr/sbin/mysqld --user=mysql
