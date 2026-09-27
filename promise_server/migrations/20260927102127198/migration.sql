BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "promise" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "promisedTo" text NOT NULL,
    "description" text,
    "dueDate" timestamp without time zone NOT NULL,
    "dueTime" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "status" text NOT NULL
);


--
-- MIGRATION VERSION FOR promise
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('promise', '20260927102127198', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260927102127198', "timestamp" = now();

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
