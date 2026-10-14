BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "promise_financial_terms" (
    "id" bigserial PRIMARY KEY,
    "promiseId" bigint NOT NULL,
    "totalAmountMinorUnits" bigint NOT NULL,
    "currency" text NOT NULL,
    "payerUserId" text NOT NULL,
    "payeeUserId" text NOT NULL,
    "notes" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "promise_financial_terms_promise_id_idx" ON "promise_financial_terms" USING btree ("promiseId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "promise_payment_record" (
    "id" bigserial PRIMARY KEY,
    "promiseId" bigint NOT NULL,
    "scheduleId" bigint,
    "recordKind" text NOT NULL,
    "reversesPaymentRecordId" bigint,
    "recorderUserId" text NOT NULL,
    "payerUserId" text NOT NULL,
    "payeeUserId" text NOT NULL,
    "amountMinorUnits" bigint NOT NULL,
    "currency" text NOT NULL,
    "paymentDate" timestamp without time zone NOT NULL,
    "paymentMethod" text NOT NULL,
    "externalReference" text,
    "notes" text,
    "attachmentId" bigint,
    "status" text NOT NULL DEFAULT 'pending_confirmation'::text,
    "confirmedAt" timestamp without time zone,
    "confirmerUserId" text,
    "disputeReason" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "promise_payment_record_promise_id_idx" ON "promise_payment_record" USING btree ("promiseId");
CREATE INDEX "promise_payment_record_reverses_idx" ON "promise_payment_record" USING btree ("reversesPaymentRecordId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "promise_payment_schedule" (
    "id" bigserial PRIMARY KEY,
    "promiseId" bigint NOT NULL,
    "installmentOrder" bigint NOT NULL,
    "amountMinorUnits" bigint NOT NULL,
    "currency" text NOT NULL,
    "dueDate" timestamp without time zone NOT NULL,
    "cancelledAt" timestamp without time zone,
    "cancelledByUserId" text,
    "cancellationReason" text,
    "notes" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "promise_payment_schedule_promise_id_idx" ON "promise_payment_schedule" USING btree ("promiseId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "promise_financial_terms"
    ADD CONSTRAINT "promise_financial_terms_fk_0"
    FOREIGN KEY("promiseId")
    REFERENCES "promise"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "promise_payment_record"
    ADD CONSTRAINT "promise_payment_record_fk_0"
    FOREIGN KEY("promiseId")
    REFERENCES "promise"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "promise_payment_record"
    ADD CONSTRAINT "promise_payment_record_fk_1"
    FOREIGN KEY("scheduleId")
    REFERENCES "promise_payment_schedule"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "promise_payment_record"
    ADD CONSTRAINT "promise_payment_record_fk_2"
    FOREIGN KEY("reversesPaymentRecordId")
    REFERENCES "promise_payment_record"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "promise_payment_record"
    ADD CONSTRAINT "promise_payment_record_fk_3"
    FOREIGN KEY("attachmentId")
    REFERENCES "promise_attachment"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "promise_payment_schedule"
    ADD CONSTRAINT "promise_payment_schedule_fk_0"
    FOREIGN KEY("promiseId")
    REFERENCES "promise"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR promise
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('promise', '20261014110623555', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014110623555', "timestamp" = now();

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
