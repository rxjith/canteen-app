--
-- PostgreSQL database dump
--

\restrict 2cKYUm3sGx75u0STeNPcZ5O87oWmHDIg10uO10iZNJxM7r8EKZ8InYNWf3WfS29

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: canteen_admin
--

CREATE TABLE public.menu_items (
    item_id integer NOT NULL,
    name character varying(100) NOT NULL,
    price numeric(6,2) NOT NULL,
    current_stock integer DEFAULT 0 NOT NULL,
    is_special boolean DEFAULT false,
    status character varying(20) DEFAULT 'available'::character varying,
    is_visible boolean DEFAULT true,
    category character varying(50) DEFAULT 'Lunch'::character varying,
    description text DEFAULT 'Fresh canteen preparation'::text,
    CONSTRAINT menu_items_status_check CHECK (((status)::text = ANY ((ARRAY['available'::character varying, 'out_of_stock'::character varying])::text[])))
);


ALTER TABLE public.menu_items OWNER TO canteen_admin;

--
-- Name: menu_items_item_id_seq; Type: SEQUENCE; Schema: public; Owner: canteen_admin
--

CREATE SEQUENCE public.menu_items_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menu_items_item_id_seq OWNER TO canteen_admin;

--
-- Name: menu_items_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canteen_admin
--

ALTER SEQUENCE public.menu_items_item_id_seq OWNED BY public.menu_items.item_id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: canteen_admin
--

CREATE TABLE public.order_items (
    order_item_id integer NOT NULL,
    order_id integer,
    item_id integer,
    quantity integer NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_items OWNER TO canteen_admin;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: canteen_admin
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO canteen_admin;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canteen_admin
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: canteen_admin
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    user_id uuid,
    total_amount numeric(8,2) NOT NULL,
    status character varying(20) DEFAULT 'pending_payment'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone NOT NULL,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['pending_payment'::character varying, 'verified'::character varying, 'completed'::character varying, 'expired'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO canteen_admin;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: canteen_admin
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO canteen_admin;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canteen_admin
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: canteen_admin
--

CREATE TABLE public.users (
    user_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    roll_number character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(15) NOT NULL
);


ALTER TABLE public.users OWNER TO canteen_admin;

--
-- Name: menu_items item_id; Type: DEFAULT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.menu_items ALTER COLUMN item_id SET DEFAULT nextval('public.menu_items_item_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: canteen_admin
--

COPY public.menu_items (item_id, name, price, current_stock, is_special, status, is_visible, category, description) FROM stdin;
3	Meals	60.00	50	f	available	t	Lunch	Traditional campus meals with assorted sides.
5	Chapati	12.00	50	f	available	t	Lunch	Soft, handmade flatbreads.
6	Porotta	15.00	50	f	available	t	Lunch	Layered, flaky Kerala style porotta.
7	Egg Curry	35.00	50	f	available	t	Lunch	Boiled eggs simmered in a spiced tomato-onion gravy.
8	Chicken Curry	75.00	50	f	available	t	Lunch	Home-style campus special chicken curry.
9	Fish Curry	65.00	50	f	available	t	Lunch	Traditional tangy fish curry.
10	Meat Roll	30.00	50	f	available	t	Snacks	Crispy golden fried snack stuffed with seasoned meat.
11	Egg Puffs	15.00	50	f	available	t	Snacks	Flaky pastry dough wrapping a spiced hard-boiled egg.
12	Chicken Puffs	20.00	50	f	available	t	Snacks	Crispy baked pastry packed with savory chicken filling.
13	Chicken Cutlet	20.00	50	f	available	t	Snacks	Minced chicken patty seasoned with local spices and breaded.
14	Chicken Sandwich	35.00	50	f	available	t	Snacks	Shredded seasoned chicken inside toasted bread lines.
15	Veg. Sandwich	30.00	50	f	available	t	Snacks	Fresh garden vegetables layered with house spreads.
16	Burger	50.00	50	f	available	t	Snacks	Classic canteen grilled patty burger.
2	Fried Rice with Chilli Chicken	150.00	35	f	available	t	Lunch	Wok-tossed rice served alongside classic chilli chicken.
4	Omelette	15.00	38	f	available	t	Lunch	Freshly prepared seasoned egg omelette.
20	Mango Juice	40.00	49	f	available	t	Drinks	Fresh kitchen product pipeline addition.
21	Kiwi Juice	40.00	50	f	available	t	Drinks	Fresh kitchen product pipeline addition.
1	Fried Rice with Chicken Curry	150.00	50	f	available	t	Lunch	Fragrant fried rice paired with spicy chicken curry.
18	Bread	40.00	10	f	available	t	Snacks	Fresh kitchen product pipeline addition.
19	Strawberry Juice	40.00	50	f	available	t	Drinks	Fresh kitchen product pipeline addition.
17	Watermelon/Mint Juice	40.00	36	f	available	t	Drinks	Refreshing fresh juice blended based on seasonal availability.
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: canteen_admin
--

COPY public.order_items (order_item_id, order_id, item_id, quantity) FROM stdin;
1	17	2	30
2	18	2	1
3	19	2	1
4	20	2	1
5	20	4	1
6	20	17	2
7	21	2	2
8	21	4	2
9	21	17	2
10	22	2	2
11	22	4	2
12	22	17	2
13	23	2	2
14	23	4	2
15	23	17	2
16	24	2	1
17	24	4	1
18	24	17	1
19	25	2	1
20	25	4	1
21	25	17	1
22	26	2	1
23	26	4	1
24	26	17	1
25	27	2	2
26	27	4	1
27	27	17	2
28	28	2	2
29	28	4	1
30	28	17	2
31	29	2	1
32	29	4	1
33	29	20	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: canteen_admin
--

COPY public.orders (order_id, user_id, total_amount, status, created_at, expires_at) FROM stdin;
1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	150.00	expired	2026-05-28 16:05:28.950626	2026-05-28 16:10:28.950626
2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	150.00	expired	2026-05-28 16:06:44.18814	2026-05-28 16:11:44.18814
4	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	150.00	completed	2026-05-28 16:14:17.923191	2026-05-28 16:19:17.923191
3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	150.00	expired	2026-05-28 16:12:12.758917	2026-05-28 16:17:12.758917
5	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	360.00	expired	2026-05-28 16:23:48.840214	2026-05-28 16:28:48.840214
6	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	360.00	completed	2026-05-28 16:50:39.17992	2026-05-28 16:55:39.17992
7	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	384.00	expired	2026-05-28 16:56:37.232245	2026-05-28 17:01:37.232245
8	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1200.00	expired	2026-05-28 17:06:40.862701	2026-05-28 17:11:40.862701
9	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1080.00	expired	2026-05-28 17:11:26.52127	2026-05-28 17:16:26.52127
11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	678.00	completed	2026-05-28 17:18:33.141023	2026-05-28 17:23:33.141023
10	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	660.00	expired	2026-05-28 17:16:20.677567	2026-05-28 17:21:20.677567
12	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	840.00	completed	2026-05-28 17:25:04.59323	2026-05-28 17:30:04.59323
13	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	710.00	completed	2026-05-28 17:25:58.024172	2026-05-28 17:30:58.024172
14	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1992.00	completed	2026-05-28 17:28:18.062302	2026-05-28 17:33:18.062302
15	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	960.00	completed	2026-05-28 17:36:42.272195	2026-05-28 17:41:42.272195
16	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	920.00	completed	2026-05-28 19:54:10.754801	2026-05-28 19:59:10.754801
17	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	4500.00	completed	2026-05-28 21:01:30.516928	2026-05-28 21:06:30.516928
19	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	150.00	completed	2026-05-28 21:16:48.223501	2026-05-28 21:21:48.223501
18	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	150.00	expired	2026-05-28 21:15:49.231273	2026-05-28 21:20:49.231273
20	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	245.00	completed	2026-05-29 13:10:10.300258	2026-05-29 13:15:10.300258
21	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	410.00	completed	2026-05-29 15:17:25.546721	2026-05-29 15:22:25.546721
22	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	410.00	completed	2026-05-29 15:24:01.41173	2026-05-29 15:29:01.41173
23	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	410.00	completed	2026-05-29 15:37:23.027132	2026-05-29 15:42:23.027132
24	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	205.00	completed	2026-05-29 16:25:03.734831	2026-05-29 16:30:03.734831
26	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	205.00	completed	2026-05-29 16:31:24.616049	2026-05-29 16:36:24.616049
25	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	205.00	expired	2026-05-29 16:28:20.56065	2026-05-29 16:33:20.56065
27	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	395.00	completed	2026-05-29 21:14:48.79514	2026-05-29 21:19:48.79514
28	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	395.00	completed	2026-05-29 21:31:55.62975	2026-05-29 21:36:55.62975
29	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	205.00	completed	2026-05-29 21:37:37.358993	2026-05-29 21:42:37.358993
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: canteen_admin
--

COPY public.users (user_id, roll_number, name, phone) FROM stdin;
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	TEMP101	Test Student	9999999999
\.


--
-- Name: menu_items_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canteen_admin
--

SELECT pg_catalog.setval('public.menu_items_item_id_seq', 21, true);


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canteen_admin
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 33, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canteen_admin
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 29, true);


--
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (item_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_roll_number_key; Type: CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_roll_number_key UNIQUE (roll_number);


--
-- Name: order_items order_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.menu_items(item_id) ON DELETE RESTRICT;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canteen_admin
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO canteen_admin;


--
-- PostgreSQL database dump complete
--

\unrestrict 2cKYUm3sGx75u0STeNPcZ5O87oWmHDIg10uO10iZNJxM7r8EKZ8InYNWf3WfS29

