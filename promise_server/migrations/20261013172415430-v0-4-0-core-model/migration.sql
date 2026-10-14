BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "promise" ADD COLUMN "commitmentType" text DEFAULT 'personal'::text;
ALTER TABLE "promise" ADD COLUMN "milestoneOrder" bigint;

--
-- MIGRATION VERSION FOR promise
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('promise', '20261013172415430-v0-4-0-core-model', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261013172415430-v0-4-0-core-model', "timestamp" = now();

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
