-- note that "parts" are comma-delimited segments (assuming doubled commas have been
-- removed), and "words" are segments delimited by either commas or spaces
create view name_parse as
select name,
       array_length(name_parts, 1) num_parts,
       array_length(name_words, 1) num_words,
       nullif(trim(name_parts[1]), '') as part1,
       nullif(trim(name_parts[2]), '') as part2,
       nullif(trim(name_parts[3]), '') as part3,
       nullif(trim(array_to_string(name_parts[4:], ',')), '') as other_parts,
       array_length(regexp_split_to_array(trim(name_parts[1]), '\s+'), 1) as part1_words,
       array_length(regexp_split_to_array(trim(name_parts[2]), '\s+'), 1) as part2_words,
       array_length(regexp_split_to_array(trim(name_parts[3]), '\s+'), 1) as part3_words
  from (select trim(i.name) as name,
               string_to_array(trim(i.name), ',') as name_parts,
               regexp_split_to_array(trim(i.name), '[\s,]+') as name_words
          from indiv i) as name_segments
