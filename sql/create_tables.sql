--
-- Candidate Reference ("cn" data set)
--
CREATE TABLE IF NOT EXISTS cand (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cand_id              TEXT,
    cand_name            TEXT,
    cand_pty_affiliation TEXT,
    cand_election_yr     INTEGER,
    cand_office_st       TEXT,
    cand_office          TEXT,
    cand_office_district TEXT,
    cand_ici             TEXT,
    cand_status          TEXT,
    cand_pcc             TEXT,
    cand_st1             TEXT,
    cand_st2             TEXT,
    cand_city            TEXT,
    cand_st              TEXT,
    cand_zip             TEXT,
    -- added columns start here
    elect_cycle          INTEGER,
    -- the following parsed name fields are used to help with creating
    -- "master" record associations (similar to `indiv`, below)
    last_name            TEXT,
    first_name           TEXT,
    other_names          TEXT,
    nick_name            TEXT,
    title                TEXT,
    suffix               TEXT
)
WITH (FILLFACTOR=70);

--
-- Candidate Financials ("weball" data set)
--
CREATE TABLE IF NOT EXISTS cand_fins (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cand_id              TEXT,
    cand_name            TEXT,
    cand_ici             TEXT,
    pty_cd               TEXT,
    cand_pty_affiliation TEXT,
    ttl_receipts         NUMERIC(14,2),
    trans_from_auth      NUMERIC(14,2),
    ttl_disb             NUMERIC(14,2),
    trans_to_auth        NUMERIC(14,2),
    coh_bop              NUMERIC(14,2),
    coh_cop              NUMERIC(14,2),
    cand_contrib         NUMERIC(14,2),
    cand_loans           NUMERIC(14,2),
    other_loans          NUMERIC(14,2),
    cand_loan_repay      NUMERIC(14,2),
    other_loan_repay     NUMERIC(14,2),
    debts_owed_by        NUMERIC(14,2),
    ttl_indiv_contrib    NUMERIC(14,2),
    cand_office_st       TEXT,
    cand_office_district TEXT,
    spec_election        TEXT,
    prim_election        TEXT,
    run_election         TEXT,
    gen_election         TEXT,
    gen_election_precent NUMERIC(7,4),
    other_pol_cmte_contrib NUMERIC(14,2),
    pol_pty_contrib      NUMERIC(14,2),
    cvg_end_dt           DATE,
    indiv_refunds        NUMERIC(14,2),
    cmte_refunds         NUMERIC(14,2),
    -- added columns start here
    elect_cycle          INTEGER
);

--
-- Committee Reference ("cm" data set)
--
CREATE TABLE IF NOT EXISTS cmte (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cmte_id              TEXT,
    cmte_nm              TEXT,
    tres_nm              TEXT,
    cmte_st1             TEXT,
    cmte_st2             TEXT,
    cmte_city            TEXT,
    cmte_st              TEXT,
    cmte_zip             TEXT,
    cmte_dsgn            TEXT,
    cmte_tp              TEXT,
    cmte_pty_affiliation TEXT,
    cmte_filing_freq     TEXT,
    org_tp               TEXT,
    connected_org_nm     TEXT,
    cand_id              TEXT,
    -- added columns start here
    elect_cycle          INTEGER
);

--
-- Committee Financials ("webk" data set)
--
CREATE TABLE IF NOT EXISTS cmte_fins (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cmte_id              TEXT,
    cmte_nm              TEXT,
    cmte_tp              TEXT,
    cmte_dsgn            TEXT,
    cmte_filing_freq     TEXT,
    ttl_receipts         NUMERIC(14,2),
    trans_from_aff       NUMERIC(14,2),
    indv_contrib         NUMERIC(14,2),
    other_pol_cmte_contrib NUMERIC(14,2),
    cand_contrib         NUMERIC(14,2),
    cand_loans           NUMERIC(14,2),
    ttl_loans_received   NUMERIC(14,2),
    ttl_disb             NUMERIC(14,2),
    tranf_to_aff         NUMERIC(14,2),
    indv_refunds         NUMERIC(14,2),
    other_pol_cmte_refunds NUMERIC(14,2),
    cand_loan_repay      NUMERIC(14,2),
    loan_repay           NUMERIC(14,2),
    coh_bop              NUMERIC(14,2),
    coh_cop              NUMERIC(14,2),
    debts_owed_by        NUMERIC(14,2),
    nonfed_trans_received NUMERIC(14,2),
    contrib_to_other_cmte NUMERIC(14,2),
    ind_exp              NUMERIC(14,2),
    pty_coord_exp        NUMERIC(14,2),
    nonfed_share_exp     NUMERIC(14,2),
    cvg_end_dt           DATE,
    -- added columns start here
    elect_cycle          INTEGER
);

--
-- Committee Contributions ("pas2" data set)
--
CREATE TABLE IF NOT EXISTS cmte_contrib (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cmte_id              TEXT,
    amndt_ind            TEXT,
    rpt_tp               TEXT,
    transaction_pgi      TEXT,
    image_num            TEXT,
    transaction_tp       TEXT,
    entity_tp            TEXT,
    name                 TEXT,
    city                 TEXT,
    state                TEXT,
    zip_code             TEXT,
    employer             TEXT,
    occupation           TEXT,
    transaction_dt       DATE,
    transaction_amt      NUMERIC(14,2),
    other_id             TEXT,
    cand_id              TEXT,
    tran_id              TEXT,
    file_num             NUMERIC(22),
    memo_cd              TEXT,
    memo_text            TEXT,
    sub_id               NUMERIC(19),
    -- added columns start here
    elect_cycle          INTEGER
);

--
-- Committee Miscellaneous Transactions ("oth" data set)
--
CREATE TABLE IF NOT EXISTS cmte_misc (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cmte_id              TEXT,
    amndt_ind            TEXT,
    rpt_tp               TEXT,
    transaction_pgi      TEXT,
    image_num            TEXT,
    transaction_tp       TEXT,
    entity_tp            TEXT,
    name                 TEXT,
    city                 TEXT,
    state                TEXT,
    zip_code             TEXT,
    employer             TEXT,
    occupation           TEXT,
    transaction_dt       DATE,
    transaction_amt      NUMERIC(14,2),
    other_id             TEXT,
    tran_id              TEXT,
    file_num             NUMERIC(22),
    memo_cd              TEXT,
    memo_text            TEXT,
    sub_id               NUMERIC(19),
    -- added columns start here
    elect_cycle          INTEGER
);

--
-- Candidate-Committee Link ("ccl" data set)
--
CREATE TABLE IF NOT EXISTS cand_cmte (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cand_id              TEXT,
    cand_election_yr     INTEGER,
    fec_election_yr      INTEGER,
    cmte_id              TEXT,
    cmte_tp              TEXT,
    cmte_dsgn            TEXT,
    linkage_id           NUMERIC(12),
    -- added columns start here
    elect_cycle          INTEGER
);

--
-- Individual Contributions ("indiv" data set)
--
CREATE TABLE IF NOT EXISTS indiv_contrib (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    cmte_id              TEXT,
    amndt_ind            TEXT,
    rpt_tp               TEXT,
    transaction_pgi      TEXT,
    image_num            TEXT,
    transaction_tp       TEXT,
    entity_tp            TEXT,
    -- note that the following six columns will be removed when this
    -- table is normalized (moved to `indiv_info` table)
    name                 TEXT,
    city                 TEXT,
    state                TEXT,
    zip_code             TEXT,
    employer             TEXT,
    occupation           TEXT,
    -- end of `indiv_info` columns (to be moved)
    transaction_dt       DATE,
    transaction_amt      NUMERIC(14,2),
    other_id             TEXT,
    tran_id              TEXT,
    file_num             NUMERIC(22),
    memo_cd              TEXT,
    memo_text            TEXT,
    sub_id               NUMERIC(19),
    -- added columns start here
    elect_cycle          INTEGER,
    -- FK constraints for the following two columns specified below
    indiv_info_id        BIGINT,  -- foreign key to extracted PII fields (see above)
    indiv_id             BIGINT,  -- foreign key to "individual master" table
    -- the following two columns will also be removed when this table
    -- is normalized (only used to set the foreign keys, just above)
    indiv_info_hashkey   TEXT,
    indiv_hashkey        TEXT
);

--
-- Transaction Type
-- [from https://www.fec.gov/campaign-finance-data/transaction-type-code-descriptions/]
--
CREATE TABLE IF NOT EXISTS transaction_type (
    transaction_tp       TEXT PRIMARY KEY,
    description          TEXT
);

--
-- Committee Type
-- [from https://www.fec.gov/campaign-finance-data/committee-type-code-descriptions/]
--
CREATE TABLE IF NOT EXISTS cmte_type (
    cmte_tp              TEXT PRIMARY KEY,
    cmte_type_name       TEXT,
    description          TEXT
);

--
-- Party
-- [from https://www.fec.gov/campaign-finance-data/party-code-descriptions/]
--
CREATE TABLE IF NOT EXISTS party (
    party_cd             TEXT PRIMARY KEY,
    party_name           TEXT,
    notes                TEXT
);

--
-- Election Cycle
--
CREATE TABLE IF NOT EXISTS election_cycle (
    key                  INTEGER PRIMARY KEY,
    election_day         DATE
);

--
-- Individual Information
--
-- This is an extraction of all of the PII fields from `indiv_contrib`, including
-- individual address and employment info.  We do this normalization for better
-- clarity in the schema, as well as for efficiency (i.e. to reduce the size of
-- `indiv_contrib`, which is a beast).
--
-- Notes:
--   * We are ignoring `entity_tp`, since it is inconsistently used in the source
--     data and, thus, doesn't add any useful value
--
CREATE TABLE IF NOT EXISTS indiv_info (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- FEC columns
    name                 TEXT,
    city                 TEXT,
    state                TEXT,
    zip_code             TEXT,
    employer             TEXT,
    occupation           TEXT,
    -- derived/added columns start here
    elect_cycles         INTEGER[],  -- aggregation
    hashkey              TEXT        -- used to set FK in `indiv_contrib`
);

--
-- Individual Master
--
-- This table is a first-cut representation of distinct individuals, and is intially populated
-- by factoring out and/or collapsing the PII in `indiv_info`.  Note that we do a "conservative"
-- reduction of the PII here (just distinct name and address values--no additional processing of
-- those fields) to try and avoid discarding potentially discriminating information--from here,
-- we can apply various algorithms, or even manual curation, to associate multiple records with
-- a "donor" record representing a real life person.
--
-- Notes:
--   * We are specifying a lower FILLFACTOR than default (value is a total SWAG value for now),
--     since we will be doing updates for name normalization
--
CREATE TABLE IF NOT EXISTS indiv (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    -- consolidation of PII in `indiv_info`
    name                 TEXT,
    city                 TEXT,
    state                TEXT,
    zip_code             TEXT,
    -- derived columns start here
    hashkey              TEXT,
    last_name            TEXT,
    first_name           TEXT,
    other_names          TEXT,
    nick_name            TEXT,
    title                TEXT,
    suffix               TEXT,
    elect_cycles         INTEGER[],
    -- `indiv` records deemed to represent the same person (in real life) will all
    -- point to a common/base "donor" record (FK constraint specified below); note
    -- that all base donor records will actually also point to themselves
    donor_indiv_id       BIGINT,
    -- pointer to "head of household" record, works similarly to `donor_indiv_id`,
    -- but tracks all records presumed to be tied to a common household; note that
    -- this key will likely go away, since the same thing can be modeled using the
    -- `indiv_seg` table (which is a cleaner approach, but perhaps slightly more
    -- cumbersome to script)
    hh_indiv_id          BIGINT
)
WITH (FILLFACTOR=70);

--
-- foreign key constraints for `indiv_contrib`
--
ALTER TABLE indiv_contrib ADD FOREIGN KEY (indiv_info_id) REFERENCES indiv_info (id);
-- specify "ON DELETE SET NULL" to allow for multiple passes at creating the "individual master"
ALTER TABLE indiv_contrib ADD FOREIGN KEY (indiv_id) REFERENCES indiv (id) ON DELETE SET NULL;

--
-- foreign key constraints for `indiv`
--
ALTER TABLE indiv ADD FOREIGN KEY (donor_indiv_id) REFERENCES indiv (id);
ALTER TABLE indiv ADD FOREIGN KEY (hh_indiv_id) REFERENCES indiv (id);
