BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "promise" ADD COLUMN "creatorConfirmed" boolean NOT NULL DEFAULT false;
ALTER TABLE "promise" ADD COLUMN "recipientConfirmed" boolean NOT NULL DEFAULT false;

--
-- DATA TRANSFORMATION: Preserve completed meaning for pre-existing records
--
UPDATE "promise" SET "creatorConfirmed" = true, "recipientConfirmed" = true WHERE "status" = 'completed';

--
-- MIGRATION VERSION FOR promise
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('promise', '20260927112123345', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260927112123345', "timestamp" = now();

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
