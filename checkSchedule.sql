create or replace
function public.checkschedule()
	returns int4
	language plpgsql
as $function$
declare errors_count integer;

begin 
	with schedule as (
	select
		*
	from
		public."Schedule"
	order by
		"time"
	),
	t1 as (
	select
		"transaction",
		COUNT("time") as len
	from
		public."Schedule"
	group by
		"transaction"
	),
	schedule_len as (
	select
		id,
		"time",
		t1."transaction",
		operation,
		attr,
		len
	from
		schedule
	inner join t1 on
		schedule."transaction" = t1."transaction"
	order by
		"time"
	),
	t2 as (
	select
		s1.id as id1,
		s2.id as id2,
		s1."transaction",
		s1.len,
		ABS(s1.id - s2.id) as dist
	from
		schedule_len s1,
		schedule_len s2
	where
		s1."transaction" = s2."transaction"
	),
	resultParcial as (
	select
		id1,
		id2,
		(
		    case
				when dist > len-1 then 0
				else 1
			end
	    ) as value
	from
		t2
	)
	select
		count(*)
	into
		errors_count
	from
		resultParcial
	where
		value = 0;
	if errors_count>0 then
		return 0;
	else
		return 1;
	end if;
	return errors_count;
end;

$function$;
