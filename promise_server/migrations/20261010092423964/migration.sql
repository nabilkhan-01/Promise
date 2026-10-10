BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "promise_attachment" (
    "id" bigserial PRIMARY KEY,
    "promiseId" bigint NOT NULL,
    "uploaderUserId" text NOT NULL,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "fileName" text NOT NULL,
    "mimeType" text NOT NULL,
    "fileSize" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "approvalStatus" text NOT NULL,
    "reviewedAt" timestamp without time zone,
    "reviewerUserId" text,
    "rejectionReason" text
);


--
-- MIGRATION VERSION FOR promise
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('promise', '20261010092423964', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010092423964', "timestamp" = now();

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
