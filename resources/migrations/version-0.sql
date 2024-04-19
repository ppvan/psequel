CREATE TABLE IF NOT EXISTS "connections" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "host" TEXT NOT NULL,
    "port" TEXT NOT NULL,
    "user" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "database" TEXT NOT NULL,
    "use_ssl" INT NOT NULL,
    "options" TEXT NOT NULL,
    "create_at" DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "queries" (
    "id" INTEGER,
    "sql" TEXT NOT NULL,
    "create_at" DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id" AUTOINCREMENT)
);
