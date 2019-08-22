--
--  group of individuals (`indiv` table)
--
CREATE TABLE IF NOT EXISTS indiv_group (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name                 TEXT,
    description          TEXT
)
WITH (FILLFACTOR=70);

--
--  group members (should be "base" `indiv` records)
--
CREATE TABLE IF NOT EXISTS indiv_group_memb (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    indiv_group_id       BIGINT,
    base_indiv_id        BIGINT
)
WITH (FILLFACTOR=70);

--
--  group of individuals (`indiv2` table)
--
CREATE TABLE IF NOT EXISTS indiv2_group (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name                 TEXT,
    description          TEXT
)
WITH (FILLFACTOR=70);

--
--  group members (should be "base" `indiv2` records)
--
CREATE TABLE IF NOT EXISTS indiv2_group_memb (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    indiv2_group_id      BIGINT,
    base_indiv2_id       BIGINT
)
WITH (FILLFACTOR=70);

ALTER TABLE indiv_group_memb  ADD FOREIGN KEY (indiv_group_id)  REFERENCES indiv_group (id);
ALTER TABLE indiv_group_memb  ADD FOREIGN KEY (base_indiv_id)   REFERENCES indiv (id);

ALTER TABLE indiv2_group_memb ADD FOREIGN KEY (indiv2_group_id) REFERENCES indiv2_group (id);
ALTER TABLE indiv2_group_memb ADD FOREIGN KEY (base_indiv2_id)  REFERENCES indiv2 (id);

CREATE UNIQUE INDEX indiv_group_name           ON indiv_group (name);
CREATE UNIQUE INDEX indiv_group_memb_user_key  ON indiv_group_memb (indiv_group_id, base_indiv_id);
CREATE INDEX indiv_group_memb_base_indiv_id    ON indiv_group_memb (base_indiv_id);

CREATE UNIQUE INDEX indiv2_group_name          ON indiv2_group (name);
CREATE UNIQUE INDEX indiv2_group_memb_user_key ON indiv2_group_memb (indiv2_group_id, base_indiv2_id);
CREATE INDEX indiv2_group_memb_base_indiv2_id  ON indiv2_group_memb (base_indiv2_id);
