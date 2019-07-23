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
CREATE INDEX cmte_contrib_transaction_amt  ON cmte_contrib (transaction_amt);
CREATE INDEX cmte_contrib_state            ON cmte_contrib (state);
CREATE INDEX cmte_contrib_zip_code         ON cmte_contrib (zip_code);

--
-- Committee Miscellaneous Transactions (cmte_misc)
--
CREATE INDEX cmte_misc_cmte_id             ON cmte_misc (cmte_id);
CREATE INDEX cmte_misc_transaction_amt     ON cmte_misc (transaction_amt);
CREATE INDEX cmte_misc_state               ON cmte_misc (state);
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
CREATE INDEX indiv_contrib_transaction_amt ON indiv_contrib (transaction_amt);
CREATE INDEX indiv_contrib_state           ON indiv_contrib (state);
CREATE INDEX indiv_contrib_zip_code        ON indiv_contrib (zip_code);