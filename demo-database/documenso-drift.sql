-- Changes made by hand to a database built from Documenso's migrations, outside any migration,
-- so that Crux's /drift has something known to find. Run by build-documenso-database.ps1 -Drift.

-- A column added for a support hotfix.
ALTER TABLE "User" ADD COLUMN "supportNote" TEXT;

-- A default changed: new recipients start as viewers rather than signers.
ALTER TABLE "Recipient" ALTER COLUMN "role" SET DEFAULT 'VIEWER'::"RecipientRole";

-- An index added to speed up a slow page.
CREATE INDEX "Envelope_title_hotfix_idx" ON "Envelope" ("title");

-- A function edited in place: ids made longer.
CREATE OR REPLACE FUNCTION generate_id() RETURNS TEXT AS $$
BEGIN
    RETURN nanoid(21, 'abcdefhiklmnorstuvwxyz');
END;
$$ LANGUAGE plpgsql VOLATILE;
