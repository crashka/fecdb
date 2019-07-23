--
-- Candidate Master ("cn" data set)
--
CREATE TABLE IF NOT EXISTS cand (
    cand_id              TEXT,
    cand_name            TEXT,
    cand_pty_affiliation TEXT,
    cand_election_yr     NUMERIC(4),
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
    cand_zip             TEXT
);

--
-- Candidate Financials ("weball" data set)
--
CREATE TABLE IF NOT EXISTS cand_fins (
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
    cmte_refunds         NUMERIC(14,2)
);

--
-- Committee Master ("cm" data set)
--
CREATE TABLE IF NOT EXISTS cmte (
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
    cand_id              TEXT
);

--
-- Committee Financials ("webk" data set)
--
CREATE TABLE IF NOT EXISTS cmte_fins (
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
    cvg_end_dt           DATE
);

--
-- Committee Contributions ("pas2" data set)
--
CREATE TABLE IF NOT EXISTS cmte_contrib (
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
    sub_id               NUMERIC(19)
);

--
-- Committee Miscellaneous Transactions ("oth" data set)
--
CREATE TABLE IF NOT EXISTS cmte_misc (
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
    sub_id               NUMERIC(19)
);

--
-- Candidate-Committee Link ("ccl" data set)
--
CREATE TABLE IF NOT EXISTS cand_cmte (
    cand_id              TEXT,
    cand_election_yr     NUMERIC(4),
    fec_election_yr      NUMERIC(4),
    cmte_id              TEXT,
    cmte_tp              TEXT,
    cmte_dsgn            TEXT,
    linkage_id           NUMERIC(12)
);

--
-- Individual Contributions ("indiv" data set)
--
CREATE TABLE IF NOT EXISTS indiv_contrib (
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
    sub_id               NUMERIC(19)
);
