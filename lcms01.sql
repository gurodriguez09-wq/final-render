--
-- PostgreSQL database dump
--

\restrict zSCVdjthux4dIEhFEd6eFhbo2EgZtPYOmYclSGyekyzXM2lXUdBI1bBS7dtRSPZ

-- Dumped from database version 18.2
-- Dumped by pg_dump version 18.2

-- Started on 2026-03-02 12:36:43

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
-- TOC entry 227 (class 1255 OID 16608)
-- Name: registrar_cambio_estado(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_cambio_estado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 
    IF NEW.id_estado <> OLD.id_estado THEN
        INSERT INTO HISTORIAL_RECIBO (
            id_recibo,
            id_estado_anterior,
            id_estado_nuevo,
            fecha_cambio
        )
        VALUES (
            OLD.id_recibo,
            OLD.id_estado,
            NEW.id_estado,
            CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.registrar_cambio_estado() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16553)
-- Name: empleado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empleado (
    id_empleado integer NOT NULL,
    cargo character varying(50) NOT NULL
);


ALTER TABLE public.empleado OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16552)
-- Name: empleado_id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.empleado_id_empleado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.empleado_id_empleado_seq OWNER TO postgres;

--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 221
-- Name: empleado_id_empleado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.empleado_id_empleado_seq OWNED BY public.empleado.id_empleado;


--
-- TOC entry 220 (class 1259 OID 16542)
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado (
    id_estado integer NOT NULL,
    nombre character varying(30) NOT NULL
);


ALTER TABLE public.estado OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16541)
-- Name: estado_id_estado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.estado_id_estado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.estado_id_estado_seq OWNER TO postgres;

--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 219
-- Name: estado_id_estado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.estado_id_estado_seq OWNED BY public.estado.id_estado;


--
-- TOC entry 226 (class 1259 OID 16583)
-- Name: historial_recibo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_recibo (
    id_historial integer NOT NULL,
    id_recibo integer NOT NULL,
    id_estado_anterior integer,
    id_estado_nuevo integer NOT NULL,
    fecha_cambio timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.historial_recibo OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16582)
-- Name: historial_recibo_id_historial_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_recibo_id_historial_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_recibo_id_historial_seq OWNER TO postgres;

--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 225
-- Name: historial_recibo_id_historial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.historial_recibo_id_historial_seq OWNED BY public.historial_recibo.id_historial;


--
-- TOC entry 224 (class 1259 OID 16562)
-- Name: recibo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recibo (
    id_recibo integer NOT NULL,
    fecha_ingreso timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_salida timestamp without time zone,
    valor_total numeric(10,2) NOT NULL,
    nombre_cliente character varying(100) NOT NULL,
    telefono_cliente character varying(20),
    paquete text NOT NULL,
    id_estado integer NOT NULL
);


ALTER TABLE public.recibo OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16561)
-- Name: recibo_id_recibo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recibo_id_recibo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recibo_id_recibo_seq OWNER TO postgres;

--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 223
-- Name: recibo_id_recibo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recibo_id_recibo_seq OWNED BY public.recibo.id_recibo;


--
-- TOC entry 4873 (class 2604 OID 16556)
-- Name: empleado id_empleado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleado ALTER COLUMN id_empleado SET DEFAULT nextval('public.empleado_id_empleado_seq'::regclass);


--
-- TOC entry 4872 (class 2604 OID 16545)
-- Name: estado id_estado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado ALTER COLUMN id_estado SET DEFAULT nextval('public.estado_id_estado_seq'::regclass);


--
-- TOC entry 4876 (class 2604 OID 16586)
-- Name: historial_recibo id_historial; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_recibo ALTER COLUMN id_historial SET DEFAULT nextval('public.historial_recibo_id_historial_seq'::regclass);


--
-- TOC entry 4874 (class 2604 OID 16565)
-- Name: recibo id_recibo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recibo ALTER COLUMN id_recibo SET DEFAULT nextval('public.recibo_id_recibo_seq'::regclass);


--
-- TOC entry 5043 (class 0 OID 16553)
-- Dependencies: 222
-- Data for Name: empleado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empleado (id_empleado, cargo) FROM stdin;
\.


--
-- TOC entry 5041 (class 0 OID 16542)
-- Dependencies: 220
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estado (id_estado, nombre) FROM stdin;
1	recibido
2	en planta
3	listo
4	entregado
\.


--
-- TOC entry 5047 (class 0 OID 16583)
-- Dependencies: 226
-- Data for Name: historial_recibo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_recibo (id_historial, id_recibo, id_estado_anterior, id_estado_nuevo, fecha_cambio) FROM stdin;
1	2	1	2	2026-03-02 12:27:40.315048
2	2	2	4	2026-03-02 12:27:46.139407
\.


--
-- TOC entry 5045 (class 0 OID 16562)
-- Dependencies: 224
-- Data for Name: recibo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recibo (id_recibo, fecha_ingreso, fecha_salida, valor_total, nombre_cliente, telefono_cliente, paquete, id_estado) FROM stdin;
1	2026-03-02 12:21:50.964955	\N	45000.00	Carlos Perez	3001234567	Lavado premium	1
2	2026-03-02 12:24:19.340354	2026-03-09 12:24:19.340354	45000.00	Carlos Perez	3001234567	Lavado premium - 3 camisas y 2 pantalones	4
\.


--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 221
-- Name: empleado_id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.empleado_id_empleado_seq', 1, false);


--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 219
-- Name: estado_id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estado_id_estado_seq', 4, true);


--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 225
-- Name: historial_recibo_id_historial_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_recibo_id_historial_seq', 2, true);


--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 223
-- Name: recibo_id_recibo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recibo_id_recibo_seq', 2, true);


--
-- TOC entry 4883 (class 2606 OID 16560)
-- Name: empleado empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado);


--
-- TOC entry 4879 (class 2606 OID 16551)
-- Name: estado estado_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado
    ADD CONSTRAINT estado_nombre_key UNIQUE (nombre);


--
-- TOC entry 4881 (class 2606 OID 16549)
-- Name: estado estado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- TOC entry 4887 (class 2606 OID 16592)
-- Name: historial_recibo historial_recibo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_recibo
    ADD CONSTRAINT historial_recibo_pkey PRIMARY KEY (id_historial);


--
-- TOC entry 4885 (class 2606 OID 16576)
-- Name: recibo recibo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recibo
    ADD CONSTRAINT recibo_pkey PRIMARY KEY (id_recibo);


--
-- TOC entry 4892 (class 2620 OID 16609)
-- Name: recibo trigger_cambio_estado; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_cambio_estado AFTER UPDATE ON public.recibo FOR EACH ROW EXECUTE FUNCTION public.registrar_cambio_estado();


--
-- TOC entry 4888 (class 2606 OID 16577)
-- Name: recibo fk_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recibo
    ADD CONSTRAINT fk_estado FOREIGN KEY (id_estado) REFERENCES public.estado(id_estado);


--
-- TOC entry 4889 (class 2606 OID 16598)
-- Name: historial_recibo fk_estado_anterior; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_recibo
    ADD CONSTRAINT fk_estado_anterior FOREIGN KEY (id_estado_anterior) REFERENCES public.estado(id_estado);


--
-- TOC entry 4890 (class 2606 OID 16603)
-- Name: historial_recibo fk_estado_nuevo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_recibo
    ADD CONSTRAINT fk_estado_nuevo FOREIGN KEY (id_estado_nuevo) REFERENCES public.estado(id_estado);


--
-- TOC entry 4891 (class 2606 OID 16593)
-- Name: historial_recibo fk_recibo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_recibo
    ADD CONSTRAINT fk_recibo FOREIGN KEY (id_recibo) REFERENCES public.recibo(id_recibo) ON DELETE CASCADE;


-- Completed on 2026-03-02 12:36:43

--
-- PostgreSQL database dump complete
--

\unrestrict zSCVdjthux4dIEhFEd6eFhbo2EgZtPYOmYclSGyekyzXM2lXUdBI1bBS7dtRSPZ

