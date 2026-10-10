BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "promise" ADD COLUMN "recipientAccepted" boolean NOT NULL DEFAULT true;
ALTER TABLE "promise" ADD COLUMN "recipientAcceptedAt" timestamp without time zone;

--
-- MIGRATION VERSION FOR promise
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('promise', '20261010135103018', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010135103018', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
