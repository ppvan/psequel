CREATE TABLE IF NOT EXISTS "migrations" (
    "id" INTEGER,
    "version_num" INTEGER,
    PRIMARY KEY("id" AUTOINCREMENT)
);
INSERT INTO "migrations" (version_num) VALUES (1);

ALTER TABLE "connections" ADD COLUMN "cert_path" TEXT NOT NULL DEFAULT "";