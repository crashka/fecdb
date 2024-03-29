--
--  Individual Segment
--
CREATE TABLE IF NOT EXISTS indiv_seg (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name                 TEXT NOT NULL,
    description          TEXT
)
WITH (FILLFACTOR=70);

--
--  Individual Segment Members (composed of `indiv` records)
--
CREATE TABLE IF NOT EXISTS indiv_seg_memb (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    indiv_seg_id         BIGINT NOT NULL,
    indiv_id             BIGINT NOT NULL
)
WITH (FILLFACTOR=70);

ALTER TABLE indiv_seg_memb ADD FOREIGN KEY (indiv_seg_id) REFERENCES indiv_seg (id) ON DELETE CASCADE;
ALTER TABLE indiv_seg_memb ADD FOREIGN KEY (indiv_id)     REFERENCES indiv (id);

CREATE UNIQUE INDEX indiv_seg_name          ON indiv_seg (name);
CREATE UNIQUE INDEX indiv_seg_memb_user_key ON indiv_seg_memb (indiv_seg_id, indiv_id);
CREATE INDEX indiv_seg_memb_indiv_id        ON indiv_seg_memb (indiv_id);

CREATE OR REPLACE FUNCTION create_indiv_seg(indiv_ids BIGINT[], seg_name text, seg_desc text = null)
RETURNS BIGINT AS $$
DECLARE
indiv_tbl TEXT = 'indiv';
seg_id    BIGINT;
indiv_id  BIGINT;
BEGIN
    EXECUTE 'insert into indiv_seg (name, description)
             values ($1, $2)
             on conflict do nothing
             returning id'
    INTO seg_id
    USING seg_name, seg_desc;

    FOREACH indiv_id IN ARRAY indiv_ids
    LOOP
        EXECUTE
            'insert into indiv_seg_memb(indiv_seg_id, indiv_id)
             values ($1, $2)
             on conflict do nothing'
        USING seg_id, indiv_id;
    END LOOP;
    RETURN seg_id;
END;
$$ LANGUAGE plpgsql;
