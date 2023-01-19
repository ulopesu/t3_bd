create or replace function "testeScheduleSerial" () 
returns integer as $$
declare errors_count integer;
	begin
		with schedule as (	
		-- Cria uma tabela que é cópia da tabela Schedule contendo a coluna id
		    select
		        (row_number() over ()) as id,
		        *
		    from
		        public."Schedule"
		    order by
		        "time"
		),
		t1 as (	
		-- Agrupa a tabela schedule pelas transações, contando as operações
		    select
		        "#t",
		        COUNT("time") as len
		    from
		        public."Schedule"
		    group by
		        "#t"
		), 
		schedule_len as ( 
		-- Cria uma tabela que é cópia da tabela schedule contendo
		-- a quantidade de operações em cada transação
		    select
		        id,
		        "time",
		        t1."#t",
		        "op",
		        "attr",
		        len
		    from
		        schedule
		        inner join t1 on schedule."#t" = t1."#t"
		    order by
		        "time"
		),
		t2 as (
		-- Cria uma tabela que contém a distancia entre as linhas
		-- de cada operação de uma mesma transação quando a tabela
		-- está ordenada pelo tempo.
		    select
		        s1.id as id1,
		        s2.id as id2,
		        s1."#t",
		        s1.len,
		        ABS(s1.id - s2.id) as dist
		    from
		        schedule_len s1,
		        schedule_len s2
		    where
		        s1."#t" = s2."#t"
		),
		partialResult as (
		-- Cria uma tabela de resultados contendo uma coluna value,
		-- onde seram armazenados os erros encontrados, é considerado
		-- um erro sempre que a distância entre duas operações 
		-- da mesma transação é maior ou igual a quantidade de operações
		-- da transação que está sendo avaliada.
		    select
		        id1,
		        id2,
		        (
		            case
		                when dist >= len then 0
		                else 1
		            end
		        ) as value
		    from
		        t2
		)

		select	-- Conta a quantidade de erros encontrados
		    count(*) into errors_count
		from
		    partialResult
		where
		    value = 0;

		if errors_count > 0 then 
			return 0;	-- Retorna 0 quando algum erro é encontrado
		end if;
		return 1;	-- Retorna 1 quando nenhum erro é encontrado
	end;
$$ language plpgsql;