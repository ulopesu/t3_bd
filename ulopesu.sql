--  BANCO DE DADOS - TRABALHO 3 - UFES - 2022/2
--  ALUNO: USIEL F. LOPES JR.


-- Código inicial para criar a tabela Schedule
DROP TABLE IF EXISTS public."Schedule";

CREATE TABLE "Schedule" (
    "time" integer,
    "#t" integer NOT NULL,
    "op" character NOT NULL,
    "attr" character NOT NULL,
    UNIQUE ("time")
);

-- Função para verificar se o escalonamento (schedule) é serial
-- Funcionamento: Análisa toda a tabela Schedule e returnanando 1, 
-- se um escalonamento da tabela for serial, e 0, caso contrário
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

--
--      COMO TESTAR?
--

--  1)  Instale o PostgreSQL, crie um banco de dados e acesse-o através 
--      de alguma ferramenta de administração de banco de dados
--      como: DBeaver ou PGadmin


--  2)  Execute todos os comandos apresentados acima na ordem listada.


--  3)  Preencha a tabela Schedule com algum estacalonamento não serial,
--      os comandos apresentados abaixo preenchem a tabela com a mesma configuração
--      de dados do Exemplo 01 do trabalho.
INSERT INTO "Schedule" ("time", "#t", "op", "attr") VALUES
(1, 1, 'R', 'X'),
(2, 2, 'R', 'X'),
(3, 2, 'W', 'X'),
(4, 1, 'W', 'X'),
(5, 2, 'C', '-'),
(6, 1, 'C', '-');


--  4)  Já com a tabela Schedule preenchida, basta executar o comando abaixo e verificar 
--      se a saída corresponde ao esperado (1 para escalonamento serial e 0 para escalonamento não serial)
select public."testeScheduleSerial"();


--  5)  O comando abaixo permite limpar os dados da tabela Schedule
DELETE FROM public."Schedule";


--  6)  Para testar algum escalonamento serial, basta executar o comando anterior 
--      para limpar a tabela e inserir na mesma algum escalonamento serial 
--      e executar o passo 4 novamente. Os comandos apresentados abaixo preenchem 
--      a tabela Schedule com a mesma configuração de dados do Exemplo 02 do trabalho.
INSERT INTO "Schedule" ("time", "#t", "op", "attr") VALUES
(7, 3, 'R', 'X'),
(8, 3, 'R', 'Y'),
(9, 3, 'W', 'Y'),
(10, 3, 'C', '-'),
(11, 4, 'R', 'X'),
(12, 4, 'C', '-');
