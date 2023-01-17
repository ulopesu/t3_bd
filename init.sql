DROP TABLE IF EXISTS public."Schedule";

CREATE TABLE IF NOT EXISTS public."Schedule"
(	
	id SERIAL PRIMARY key,
    "time" bigint NOT NULL,
    transaction bigint NOT NULL,
    operation "char" NOT NULL,
    attr "char"
);

INSERT INTO public."Schedule" ("time","transaction",operation,attr) VALUES (1,1,'R','X');
INSERT INTO public."Schedule" ("time","transaction",operation,attr) VALUES (2,2,'R','X');
INSERT INTO public."Schedule" ("time","transaction",operation,attr) VALUES (3,2,'W','X');
INSERT INTO public."Schedule" ("time","transaction",operation,attr) VALUES (4,1,'W','X');
INSERT INTO public."Schedule" ("time","transaction",operation,attr) VALUES (5,2,'C','');
INSERT INTO public."Schedule" ("time","transaction",operation,attr) VALUES (6,1,'C','');
