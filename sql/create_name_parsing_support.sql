/*
 *  Parse out comma- and space-delimited "components" (first/middle/last names, titles, suffixes,
 *  etc.) of the `name` field for `indiv`
 *
 *  Terminology-wise, "parts" are comma-delimited components, and "words" are delimited by either
 *  commas or spaces; note that commas and spaces should be trimmed and normalized by this point,
 *  but we still trim the parts here to be sure (and there are some other possible outlier cases
 *  as well, see scripts/fmt_indiv.awk)
 */
create or replace view indiv_parsed as
select id,
       name,
       city,
       state,
       zip_code,
       array_length(name_parts, 1) num_parts,
       array_length(name_words, 1) num_words,
       nullif(trim(name_parts[1]), '') as part1,
       nullif(trim(name_parts[2]), '') as part2,
       nullif(trim(name_parts[3]), '') as part3,
       nullif(trim(array_to_string(name_parts[4:], ',')), '') as other_parts,
       array_length(regexp_split_to_array(trim(name_parts[1]), '\s+'), 1) as part1_words,
       array_length(regexp_split_to_array(trim(name_parts[2]), '\s+'), 1) as part2_words,
       array_length(regexp_split_to_array(trim(name_parts[3]), '\s+'), 1) as part3_words
  from (select i.id,
               i.name,
               i.city,
               i.state,
               i.zip_code,
               string_to_array(i.name, ',') as name_parts,
               regexp_split_to_array(i.name, '[\s,]+') as name_words
          from indiv i) as name_segments;
