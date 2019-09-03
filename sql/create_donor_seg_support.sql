--
--  Donor Segment
--
CREATE TABLE IF NOT EXISTS donor_seg (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name                 TEXT,
    description          TEXT
)
WITH (FILLFACTOR=70);

--
--  Donor Segment Members (composed of "donor" `indiv` records)
--
CREATE TABLE IF NOT EXISTS donor_seg_memb (
    id                   BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    donor_seg_id         BIGINT,
    donor_indiv_id       BIGINT
)
WITH (FILLFACTOR=70);

ALTER TABLE donor_seg_memb ADD FOREIGN KEY (donor_seg_id)   REFERENCES donor_seg (id);
ALTER TABLE donor_seg_memb ADD FOREIGN KEY (donor_indiv_id) REFERENCES indiv (id);

CREATE UNIQUE INDEX donor_seg_name          ON donor_seg (name);
CREATE UNIQUE INDEX donor_seg_memb_user_key ON donor_seg_memb (donor_seg_id, donor_indiv_id);
CREATE INDEX donor_seg_memb_donor_indiv_id  ON donor_seg_memb (donor_indiv_id);

/*
 *  need to create a type, since postgres does not support BIGINT[][] where inner
 *  array has variable size, so we use array[row(array[<ids>])::id_array]
 */
CREATE TYPE id_array AS (ids BIGINT[]);

CREATE OR REPLACE FUNCTION create_donor_seg(donor_rows id_array[], seg_name text, seg_desc text = null)
RETURNS BIGINT AS $$
DECLARE
indiv_tbl TEXT = 'indiv';
seg_id    BIGINT;
donor_id  BIGINT;
donor_ids id_array;
BEGIN
    EXECUTE 'insert into donor_seg (name, description)
             values ($1, $2)
             on conflict do nothing
             returning id'
    INTO seg_id
    USING seg_name, seg_desc;

    FOREACH donor_ids IN ARRAY donor_rows
    LOOP
        EXECUTE 'select set_donor_indiv($1, $2)'
        INTO donor_id
        USING indiv_tbl, donor_ids.ids;

        EXECUTE
            'insert into donor_seg_memb(donor_seg_id, donor_indiv_id)
             values ($1, $2)
             on conflict do nothing'
        USING seg_id, donor_id;
    END LOOP;
    RETURN seg_id;
END;
$$ LANGUAGE plpgsql;
