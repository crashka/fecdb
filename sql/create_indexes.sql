--
-- Candidate Master (cand)
--
CREATE INDEX cand_cand_id                  ON cand (cand_id);

--
-- Candidate Financials (cand_fins)
--
CREATE INDEX cand_fins_cand_id             ON cand_fins (cand_id);

--
-- Committee Master (cmte)
--
CREATE INDEX cmte_cmte_id                  ON cmte (cmte_id);
CREATE INDEX cmte_cand_id                  ON cmte (cand_id);

--
-- Committee Financials (cmte_fins)
--
CREATE INDEX cmte_fins_cmte_id             ON cmte_fins (cmte_id);

--
-- Committee Contributions (cmte_contrib)
--
CREATE INDEX cmte_contrib_cmte_id          ON cmte_contrib (cmte_id);
CREATE INDEX cmte_contrib_cand_id          ON cmte_contrib (cand_id);
CREATE INDEX cmte_contrib_other_id         ON cmte_contrib (other_id);
CREATE INDEX cmte_contrib_transaction_tp   ON cmte_contrib (transaction_tp);
CREATE INDEX cmte_contrib_transaction_amt  ON cmte_contrib (transaction_amt);
CREATE INDEX cmte_contrib_state_city       ON cmte_contrib (state, city);
CREATE INDEX cmte_contrib_zip_code         ON cmte_contrib (zip_code);

--
-- Committee Miscellaneous Transactions (cmte_misc)
--
CREATE INDEX cmte_misc_cmte_id             ON cmte_misc (cmte_id);
CREATE INDEX cmte_misc_other_id            ON cmte_misc (other_id);
CREATE INDEX cmte_misc_transaction_tp      ON cmte_misc (transaction_tp);
CREATE INDEX cmte_misc_transaction_amt     ON cmte_misc (transaction_amt);
CREATE INDEX cmte_misc_state_city          ON cmte_misc (state, city);
CREATE INDEX cmte_misc_zip_code            ON cmte_misc (zip_code);

--
-- Candidate-Committee Link (cand_cmte)
--
CREATE INDEX cand_cmte_cand_id             ON cand_cmte (cand_id);
CREATE INDEX cand_cmte_cmte_id             ON cand_cmte (cmte_id);

--
-- Individual Contributions (indiv_contrib)
--
CREATE INDEX indiv_contrib_cmte_id         ON indiv_contrib (cmte_id);
CREATE INDEX indiv_contrib_transaction_tp  ON indiv_contrib (transaction_tp);
CREATE INDEX indiv_contrib_transaction_amt ON indiv_contrib (transaction_amt);
--CREATE INDEX indiv_contrib_indiv_info_id   ON indiv_contrib (indiv_info_id, transaction_dt);
--CREATE INDEX indiv_contrib_indiv_id        ON indiv_contrib (indiv_id, transaction_dt);
CREATE INDEX indiv_contrib_indiv_info_id   ON indiv_contrib (indiv_info_id);
CREATE INDEX indiv_contrib_indiv_id        ON indiv_contrib (indiv_id);

--
-- Individual Information (indiv_info)
--
CREATE UNIQUE INDEX indiv_info_user_key    ON indiv_info (name, zip_code, city, state, employer, occupation);
CREATE INDEX indiv_info_state_city         ON indiv_info (state, city);
CREATE INDEX indiv_info_zip_code           ON indiv_info (zip_code);

--
-- Individual Master (indiv)
--
CREATE UNIQUE INDEX indiv_user_key         ON indiv (name, zip_code, city, state);
CREATE INDEX indiv_state_city              ON indiv (state, city);
CREATE INDEX indiv_zip_code                ON indiv (zip_code);
CREATE INDEX indiv_last_name_first_name    ON indiv (last_name, first_name);
CREATE INDEX indiv_donor_indiv_id          ON indiv (donor_indiv_id);
CREATE INDEX indiv_hh_indiv_id             ON indiv (hh_indiv_id);
