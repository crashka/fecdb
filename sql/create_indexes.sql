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
--CREATE INDEX indiv_contrib_indiv_id        ON indiv_contrib (indiv_id, transaction_dt);
--CREATE INDEX indiv_contrib_indiv2_id       ON indiv_contrib (indiv2_id, transaction_dt);
CREATE INDEX indiv_contrib_indiv_id        ON indiv_contrib (indiv_id);
CREATE INDEX indiv_contrib_indiv2_id       ON indiv_contrib (indiv2_id);

--
-- Individual Master (indiv)
--
CREATE UNIQUE INDEX indiv_user_key         ON indiv (name, zip_code, city, state);
CREATE INDEX indiv_state_city              ON indiv (state, city);
CREATE INDEX indiv_zip_code                ON indiv (zip_code);
CREATE INDEX indiv_last_name_first_name    ON indiv (last_name, first_name);
CREATE INDEX indiv_base_indiv_id           ON indiv (base_indiv_id);
CREATE INDEX indiv_hhh_indiv_id            ON indiv (hhh_indiv_id);

--
-- Individual Master [Alt] (indiv2)
--
CREATE UNIQUE INDEX indiv2_user_key        ON indiv2 (name, zip_code, city, state, employer, occupation);
CREATE INDEX indiv2_state_city             ON indiv2 (state, city);
CREATE INDEX indiv2_zip_code               ON indiv2 (zip_code);
CREATE INDEX indiv2_last_name_first_name   ON indiv2 (last_name, first_name);
CREATE INDEX indiv2_base_indiv2_id         ON indiv2 (base_indiv2_id);
CREATE INDEX indiv2_hhh_indiv2_id          ON indiv2 (hhh_indiv2_id);
