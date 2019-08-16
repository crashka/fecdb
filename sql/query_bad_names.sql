-- names not starting with a letter
select substr(name, 1, 1) first_char, count(*) from indiv where name !~ '^[A-Z]' group by 1;

-- one or two character "names"
select name, count(*) from indiv where length(name) <= 2 group by 1;
