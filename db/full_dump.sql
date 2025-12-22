--
-- PostgreSQL database dump
--

\restrict xYcLTFJnkqZ5PkIpje1zonSeRCqWpZA0W81djtwhBG8q2xRhZVw4NcIs2DkHbaC

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: apply_discount_to_service(text, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.apply_discount_to_service(IN service_name text, IN discount_percent integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validation
    IF discount_percent < 0 OR discount_percent > 100 THEN
        RAISE NOTICE 'Invalid discount: %. Allowed range is 0-100%%',
            discount_percent;
        RETURN;
    END IF;

    -- Update service info
    UPDATE services
    SET
        description =
            CASE
                WHEN description IS NULL OR description = ''
                    THEN 'Discount ' || discount_percent || '%'
                ELSE description || ' (Discount ' || discount_percent || '%)'
            END,
        price = price - (price * discount_percent / 100.0)
    WHERE name = service_name;

    -- If service not found
    IF NOT FOUND THEN
        RAISE NOTICE 'Service "%" not found.', service_name;
    ELSE
        -- Here we have EXACTLY 2 placeholders → pass 2 params
        RAISE NOTICE 'Discount % applied to "%". Description and price updated.',
            discount_percent, service_name;
    END IF;
END;
$$;


ALTER PROCEDURE public.apply_discount_to_service(IN service_name text, IN discount_percent integer) OWNER TO postgres;

--
-- Name: get_popular_service_by_worker(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_popular_service_by_worker(worker_name character varying, worker_surname character varying) RETURNS TABLE(service_name character varying, counter bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH service_counts AS (
        SELECT
            s.name::VARCHAR(50) AS svc_name,
            COUNT(os.service_id) AS svc_counter,
            RANK() OVER (ORDER BY COUNT(os.service_id) DESC) AS rnk
        FROM workers w
        JOIN orders o ON o.worker_id = w.worker_id
        JOIN orderservices os ON os.order_id = o.order_id
        JOIN services s ON s.service_id = os.service_id
        WHERE w.name = worker_name
          AND w.surname = worker_surname
        GROUP BY s.name
    )
    SELECT svc_name, svc_counter
    FROM service_counts
    WHERE rnk = 1;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'No completed services'::VARCHAR(50), 0::BIGINT;
    END IF;
END;
$$;


ALTER FUNCTION public.get_popular_service_by_worker(worker_name character varying, worker_surname character varying) OWNER TO postgres;

--
-- Name: log_order_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_order_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO orders_logs(order_id, time_of_modify)
        VALUES (NEW.order_id, NOW());
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.log_order_changes() OWNER TO postgres;

--
-- Name: stop_weekend_order_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stop_weekend_order_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    day_of_week INT;
BEGIN
    day_of_week := EXTRACT(ISODOW FROM CURRENT_DATE);

    IF day_of_week IN (6, 7) THEN
        INSERT INTO orders_block_logs(details)
        VALUES ('Attempt to create order in the weekend day');
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.stop_weekend_order_func() OWNER TO postgres;

--
-- Name: total_revenue_for_service(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.total_revenue_for_service(entered_service_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT COALESCE(SUM(quantity * unit_price), 0)
    INTO total
  FROM orderservices os
  WHERE os.service_id = entered_service_id;

  RETURN total;
END;
$$;


ALTER FUNCTION public.total_revenue_for_service(entered_service_id integer) OWNER TO postgres;

--
-- Name: worker_done_ten_services(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.worker_done_ten_services() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    worker_services_count INT;
    msg TEXT := 'Worker done more than 10 different services';
    worker INT;
BEGIN
    SELECT worker_id INTO worker
    FROM orders
    WHERE order_id = NEW.order_id;

    SELECT COUNT(DISTINCT os.service_id)
    INTO worker_services_count
    FROM orderservices os
    JOIN orders o ON os.order_id = o.order_id
    WHERE o.worker_id = worker;

    IF worker_services_count >= 10 THEN
        UPDATE workers
        SET description =
            CASE
                WHEN description IS NULL THEN msg
                WHEN description NOT LIKE '%' || msg || '%'
                    THEN description || ' ' || msg
                ELSE description
            END
        WHERE worker_id = worker;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.worker_done_ten_services() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cars; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cars (
    car_id integer NOT NULL,
    brand character varying(50) NOT NULL,
    model character varying(50) NOT NULL,
    year integer,
    vin_code character varying(50),
    client_id integer NOT NULL
);


ALTER TABLE public.cars OWNER TO postgres;

--
-- Name: cars_car_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cars ALTER COLUMN car_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cars_car_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    client_id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    phone character varying(20) NOT NULL
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- Name: clients_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.clients ALTER COLUMN client_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.clients_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    status character varying(30) DEFAULT 'new'::character varying,
    worker_id integer NOT NULL,
    car_id integer NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_block_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_block_logs (
    log_id integer NOT NULL,
    time_of_attempt timestamp without time zone DEFAULT now() NOT NULL,
    details text
);


ALTER TABLE public.orders_block_logs OWNER TO postgres;

--
-- Name: orders_block_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.orders_block_logs ALTER COLUMN log_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_block_logs_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: orders_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_logs (
    log_id integer NOT NULL,
    order_id integer NOT NULL,
    time_of_modify timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.orders_logs OWNER TO postgres;

--
-- Name: orders_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.orders_logs ALTER COLUMN log_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_logs_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.orders ALTER COLUMN order_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: orderservices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orderservices (
    order_services_id integer NOT NULL,
    order_id integer NOT NULL,
    service_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    total_price numeric(10,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    CONSTRAINT orderservices_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.orderservices OWNER TO postgres;

--
-- Name: orderservices_order_services_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.orderservices ALTER COLUMN order_services_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orderservices_order_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    service_id integer NOT NULL,
    name character varying(100) NOT NULL,
    price numeric(10,2) NOT NULL,
    description text
);


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: services_service_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.services ALTER COLUMN service_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.services_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: workers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workers (
    worker_id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    "position" character varying(50) NOT NULL,
    phone character varying(20),
    description text
);


ALTER TABLE public.workers OWNER TO postgres;

--
-- Name: workers_worker_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.workers ALTER COLUMN worker_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.workers_worker_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: cars; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cars (car_id, brand, model, year, vin_code, client_id) FROM stdin;
1	Toyota	Camry	2018	JTNB11HK003456781	1
2	Honda	Civic	2016	2HGFB2F50CH123452	2
3	BMW	X5	2020	WBAKS410300F12341	3
4	Audi	A4	2017	WAUZZZ8K5HA123451	4
5	Ford	Focus	2015	1FADP3F26FL123451	5
6	Mercedes	C200	2019	WDDWF4JB1KF123451	6
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients (client_id, name, surname, phone) FROM stdin;
1	John	Williams	1555000111
2	Emily	Davis	1555000222
3	Michael	Brown	1555000333
4	Sophia	Wilson	1555000444
5	Daniel	Anderson	1555000555
6	Laura	Taylor	1555000666
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, order_date, status, worker_id, car_id) FROM stdin;
2	2025-01-12	completed	2	2
3	2025-01-14	in_progress	3	3
4	2025-01-15	in progress	4	4
5	2025-01-16	in progress	5	5
11	2025-12-18	new	8	1
1	2025-01-10	completed	1	2
18	2025-12-24	new	9	6
\.


--
-- Data for Name: orders_block_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_block_logs (log_id, time_of_attempt, details) FROM stdin;
1	2025-12-20 18:31:31.752823	Attempt to create order in the weekend day
2	2025-12-21 21:57:11.190304	Attempt to create order in the weekend day
3	2025-12-21 21:59:30.794865	Attempt to create order in the weekend day
4	2025-12-21 22:01:19.804476	Attempt to create order in the weekend day
5	2025-12-21 22:01:29.948332	Attempt to create order in the weekend day
6	2025-12-21 22:05:58.930239	Attempt to create order in the weekend day
7	2025-12-21 22:06:58.567132	Attempt to create order in the weekend day
8	2025-12-21 22:10:00.542293	Attempt to create order in the weekend day
9	2025-12-21 22:16:35.479197	Attempt to create order in the weekend day
10	2025-12-21 22:16:48.307344	Attempt to create order in the weekend day
11	2025-12-21 22:16:54.482884	Attempt to create order in the weekend day
12	2025-12-21 22:18:06.891434	Attempt to create order in the weekend day
13	2025-12-21 22:18:12.09458	Attempt to create order in the weekend day
14	2025-12-21 22:18:31.046588	Attempt to create order in the weekend day
\.


--
-- Data for Name: orders_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_logs (log_id, order_id, time_of_modify) FROM stdin;
1	4	2025-12-18 13:36:44.899065
2	5	2025-12-20 20:07:47.231604
3	1	2025-12-21 21:59:49.100422
4	1	2025-12-21 22:01:06.768284
5	1	2025-12-21 22:01:11.20975
\.


--
-- Data for Name: orderservices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orderservices (order_services_id, order_id, service_id, quantity, unit_price) FROM stdin;
1	1	1	1	60.00
2	1	2	1	80.00
3	2	3	1	120.00
4	2	2	1	80.00
5	3	4	1	50.00
6	3	5	1	70.00
7	4	2	1	80.00
8	4	6	1	55.00
9	5	1	1	60.00
12	11	2	1	80.00
13	11	3	1	120.00
14	11	4	1	50.00
15	11	5	1	70.00
16	11	6	1	55.00
17	11	12	1	40.00
18	11	13	1	50.00
19	11	14	1	60.00
20	11	15	1	70.00
21	11	11	1	80.00
11	11	1	1	60.00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (service_id, name, price, description) FROM stdin;
2	Oil Change	80.00	Replace oil and filter
3	Brake Pad Replacement	120.00	Replace brake pads
4	Suspension Inspection	50.00	Check suspension components
5	Spark Plug Replacement	70.00	Replace spark plugs
6	AC System Check	55.00	Air conditioning inspection
11	test1	80.00	Some description (Discount 20%)
12	Test Service A	40.00	Auto-generated test service
13	Test Service B	50.00	Auto-generated test service
14	Test Service C	60.00	Auto-generated test service
1	Engine Diagnostics	60.00	Full engine computer scan
17	TEST WEB 	80.00	Discount 20%
15	Test Service D	63.00	Auto-generated test service (Discount 10%)
\.


--
-- Data for Name: workers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workers (worker_id, name, surname, "position", phone, description) FROM stdin;
2	Alex	Johnson	Mechanic	1555001002	\N
3	James	Moore	Electrician	1555001003	\N
4	Peter	Walker	Service Advisor	1555001004	\N
5	Chris	Hall	Mechanic	1555001005	\N
6	Oliver	King	Master Technician	1555001006	\N
8	TEST	TRIGGERS	MECHANIC	123213	Worker done more than 10 different services
1	David	Miller	Mechanic	1555001001	Changing description from web
9	WEB	TEST	Mechanic	12313	check
\.


--
-- Name: cars_car_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cars_car_id_seq', 6, true);


--
-- Name: clients_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clients_client_id_seq', 6, true);


--
-- Name: orders_block_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_block_logs_log_id_seq', 14, true);


--
-- Name: orders_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_logs_log_id_seq', 5, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 25, true);


--
-- Name: orderservices_order_services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orderservices_order_services_id_seq', 21, true);


--
-- Name: services_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.services_service_id_seq', 17, true);


--
-- Name: workers_worker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workers_worker_id_seq', 12, true);


--
-- Name: cars cars_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_pkey PRIMARY KEY (car_id);


--
-- Name: clients clients_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_phone_key UNIQUE (phone);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- Name: orders_block_logs orders_block_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_block_logs
    ADD CONSTRAINT orders_block_logs_pkey PRIMARY KEY (log_id);


--
-- Name: orders_logs orders_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_logs
    ADD CONSTRAINT orders_logs_pkey PRIMARY KEY (log_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: orderservices orderservices_order_id_service_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderservices
    ADD CONSTRAINT orderservices_order_id_service_id_key UNIQUE (order_id, service_id);


--
-- Name: orderservices orderservices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderservices
    ADD CONSTRAINT orderservices_pkey PRIMARY KEY (order_services_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (service_id);


--
-- Name: workers workers_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_phone_key UNIQUE (phone);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (worker_id);


--
-- Name: orders trg_disallow_weekend_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_disallow_weekend_orders BEFORE INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.stop_weekend_order_func();


--
-- Name: orders trg_log_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_orders AFTER UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.log_order_changes();


--
-- Name: orderservices trg_worker_done_ten_services; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_worker_done_ten_services AFTER INSERT ON public.orderservices FOR EACH ROW EXECUTE FUNCTION public.worker_done_ten_services();


--
-- Name: cars cars_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON DELETE CASCADE;


--
-- Name: orders orders_car_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_car_id_fkey FOREIGN KEY (car_id) REFERENCES public.cars(car_id) ON DELETE CASCADE;


--
-- Name: orders orders_worker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_worker_id_fkey FOREIGN KEY (worker_id) REFERENCES public.workers(worker_id);


--
-- Name: orderservices orderservices_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderservices
    ADD CONSTRAINT orderservices_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: orderservices orderservices_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orderservices
    ADD CONSTRAINT orderservices_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id);


--
-- PostgreSQL database dump complete
--

\unrestrict xYcLTFJnkqZ5PkIpje1zonSeRCqWpZA0W81djtwhBG8q2xRhZVw4NcIs2DkHbaC

