BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "promise_payment_record" ADD COLUMN "disputedAt" timestamp without time zone;
ALTER TABLE "promise_payment_record" ADD COLUMN "disputerUserId" text;
ALTER TABLE "promise_payment_record" ADD COLUMN "cancelledAt" timestamp without time zone;
ALTER TABLE "promise_payment_record" ADD COLUMN "cancellerUserId" text;
ALTER TABLE "promise_payment_record" ADD COLUMN "cancellationReason" text;
--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "promise_payment_schedule_order_idx" ON "promise_payment_schedule" USING btree ("promiseId", "installmentOrder");

--
-- MIGRATION VERSION FOR promise
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('promise', '20261014111449582', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014111449582', "timestamp" = now();

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
