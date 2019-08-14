-- we use this output as a high-level indicator of the structure of the `name` column;
-- note that "parts" are comma-delimited segments (assuming doubled commas have been
-- removed), and "words" are segments delimited by either commas or spaces
copy (
with name_parse as (
       select array_length(string_to_array(i.name, ','), 1) num_parts,
              array_length(regexp_split_to_array(i.name, '[\s,]+'), 1) num_words
         from indiv i
       )
select num_parts,
       num_words,
       count(*)
  from name_parse
 group by 1, 2
 order by 3 desc
)
to '/tmp/indiv_name_stats.csv'
with (format csv, header true)
