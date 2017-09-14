--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: slide_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE slide_type AS ENUM (
    'cover',
    'title',
    'text',
    'image1',
    'image2',
    'image3',
    'image4',
    'audio',
    'video1',
    'video2'
);


--
-- Name: teaching_object; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE teaching_object AS ENUM (
    'Lesson',
    'MediaElement'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookmarks (
    id integer NOT NULL,
    user_id integer NOT NULL,
    bookmarkable_id integer NOT NULL,
    bookmarkable_type teaching_object NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookmarks_id_seq OWNED BY bookmarks.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(255),
    description text,
    attachment character varying(255) NOT NULL,
    metadata text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: documents_slides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents_slides (
    id integer NOT NULL,
    document_id integer NOT NULL,
    slide_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: documents_slides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_slides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_slides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_slides_id_seq OWNED BY documents_slides.id;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lessons (
    id integer NOT NULL,
    uuid uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id integer NOT NULL,
    school_level_id integer NOT NULL,
    subject_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    parent_id integer,
    copied_not_modified boolean NOT NULL,
    token character varying(255) NOT NULL,
    metadata text,
    notified boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lessons_id_seq OWNED BY lessons.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    lesson_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE locations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sti_type character varying(255),
    ancestry character varying(255),
    code character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: mailing_list_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mailing_list_addresses (
    id integer NOT NULL,
    group_id integer,
    heading character varying(255),
    email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mailing_list_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mailing_list_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailing_list_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mailing_list_addresses_id_seq OWNED BY mailing_list_addresses.id;


--
-- Name: mailing_list_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mailing_list_groups (
    id integer NOT NULL,
    user_id integer,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mailing_list_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mailing_list_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailing_list_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mailing_list_groups_id_seq OWNED BY mailing_list_groups.id;


--
-- Name: media_elements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_elements (
    id integer NOT NULL,
    user_id integer NOT NULL,
    sti_type character varying(255) NOT NULL,
    media character varying(255),
    title character varying(255) NOT NULL,
    description text NOT NULL,
    metadata text,
    converted boolean DEFAULT false NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    publication_date timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: media_elements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_elements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_elements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_elements_id_seq OWNED BY media_elements.id;


--
-- Name: media_elements_slides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_elements_slides (
    id integer NOT NULL,
    media_element_id integer NOT NULL,
    slide_id integer NOT NULL,
    "position" integer NOT NULL,
    caption text,
    inscribed boolean DEFAULT false NOT NULL,
    alignment integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: media_elements_slides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_elements_slides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_elements_slides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_elements_slides_id_seq OWNED BY media_elements_slides.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message text NOT NULL,
    title character varying(255) NOT NULL,
    basement text,
    seen boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: purchases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE purchases (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    responsible character varying(255) NOT NULL,
    phone_number character varying(255),
    fax character varying(255),
    email character varying(255) NOT NULL,
    ssn_code character varying(255),
    vat_code character varying(255),
    address character varying(255),
    postal_code character varying(255),
    city character varying(255),
    country character varying(255),
    location_id integer,
    accounts_number integer NOT NULL,
    includes_invoice boolean NOT NULL,
    release_date timestamp without time zone NOT NULL,
    start_date timestamp without time zone NOT NULL,
    expiration_date timestamp without time zone NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE purchases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE purchases_id_seq OWNED BY purchases.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports (
    id integer NOT NULL,
    reportable_id integer NOT NULL,
    reportable_type teaching_object NOT NULL,
    user_id integer NOT NULL,
    comment text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_id_seq OWNED BY reports.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: school_levels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE school_levels (
    id integer NOT NULL,
    description character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: school_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE school_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: school_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE school_levels_id_seq OWNED BY school_levels.id;


--
-- Name: slides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE slides (
    id integer NOT NULL,
    lesson_id integer NOT NULL,
    title character varying(255),
    text text,
    "position" integer NOT NULL,
    kind slide_type NOT NULL,
    metadata text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: slides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slides_id_seq OWNED BY slides.id;


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subjects (
    id integer NOT NULL,
    description character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subjects_id_seq OWNED BY subjects.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer NOT NULL,
    taggable_id integer NOT NULL,
    taggable_type teaching_object NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    word character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    surname character varying(255) NOT NULL,
    school_level_id integer NOT NULL,
    encrypted_password character varying(255) NOT NULL,
    confirmed boolean NOT NULL,
    active boolean NOT NULL,
    location_id integer,
    confirmation_token character varying(255),
    metadata text,
    password_token character varying(255),
    purchase_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users_subjects (
    id integer NOT NULL,
    user_id integer NOT NULL,
    subject_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_subjects_id_seq OWNED BY users_subjects.id;


--
-- Name: virtual_classroom_lessons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE virtual_classroom_lessons (
    id integer NOT NULL,
    lesson_id integer NOT NULL,
    user_id integer NOT NULL,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: virtual_classroom_lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE virtual_classroom_lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: virtual_classroom_lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE virtual_classroom_lessons_id_seq OWNED BY virtual_classroom_lessons.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookmarks ALTER COLUMN id SET DEFAULT nextval('bookmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_slides ALTER COLUMN id SET DEFAULT nextval('documents_slides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons ALTER COLUMN id SET DEFAULT nextval('lessons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailing_list_addresses ALTER COLUMN id SET DEFAULT nextval('mailing_list_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailing_list_groups ALTER COLUMN id SET DEFAULT nextval('mailing_list_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_elements ALTER COLUMN id SET DEFAULT nextval('media_elements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_elements_slides ALTER COLUMN id SET DEFAULT nextval('media_elements_slides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchases ALTER COLUMN id SET DEFAULT nextval('purchases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY school_levels ALTER COLUMN id SET DEFAULT nextval('school_levels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY slides ALTER COLUMN id SET DEFAULT nextval('slides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_subjects ALTER COLUMN id SET DEFAULT nextval('users_subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY virtual_classroom_lessons ALTER COLUMN id SET DEFAULT nextval('virtual_classroom_lessons_id_seq'::regclass);


--
-- Name: bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: documents_slides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents_slides
    ADD CONSTRAINT documents_slides_pkey PRIMARY KEY (id);


--
-- Name: lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: mailing_list_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mailing_list_addresses
    ADD CONSTRAINT mailing_list_addresses_pkey PRIMARY KEY (id);


--
-- Name: mailing_list_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mailing_list_groups
    ADD CONSTRAINT mailing_list_groups_pkey PRIMARY KEY (id);


--
-- Name: media_elements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_elements
    ADD CONSTRAINT media_elements_pkey PRIMARY KEY (id);


--
-- Name: media_elements_slides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_elements_slides
    ADD CONSTRAINT media_elements_slides_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);


--
-- Name: reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: school_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY school_levels
    ADD CONSTRAINT school_levels_pkey PRIMARY KEY (id);


--
-- Name: slides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slides
    ADD CONSTRAINT slides_pkey PRIMARY KEY (id);


--
-- Name: subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users_subjects
    ADD CONSTRAINT users_subjects_pkey PRIMARY KEY (id);


--
-- Name: virtual_classroom_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY virtual_classroom_lessons
    ADD CONSTRAINT virtual_classroom_lessons_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: fk__bookmarks_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__bookmarks_user_id ON bookmarks USING btree (user_id);


--
-- Name: fk__documents_slides_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__documents_slides_document_id ON documents_slides USING btree (document_id);


--
-- Name: fk__documents_slides_slide_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__documents_slides_slide_id ON documents_slides USING btree (slide_id);


--
-- Name: fk__documents_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__documents_user_id ON documents USING btree (user_id);


--
-- Name: fk__lessons_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__lessons_parent_id ON lessons USING btree (parent_id);


--
-- Name: fk__lessons_school_level_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__lessons_school_level_id ON lessons USING btree (school_level_id);


--
-- Name: fk__lessons_subject_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__lessons_subject_id ON lessons USING btree (subject_id);


--
-- Name: fk__lessons_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__lessons_user_id ON lessons USING btree (user_id);


--
-- Name: fk__likes_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__likes_lesson_id ON likes USING btree (lesson_id);


--
-- Name: fk__likes_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__likes_user_id ON likes USING btree (user_id);


--
-- Name: fk__mailing_list_addresses_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__mailing_list_addresses_group_id ON mailing_list_addresses USING btree (group_id);


--
-- Name: fk__mailing_list_groups_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__mailing_list_groups_user_id ON mailing_list_groups USING btree (user_id);


--
-- Name: fk__media_elements_slides_media_element_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__media_elements_slides_media_element_id ON media_elements_slides USING btree (media_element_id);


--
-- Name: fk__media_elements_slides_slide_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__media_elements_slides_slide_id ON media_elements_slides USING btree (slide_id);


--
-- Name: fk__media_elements_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__media_elements_user_id ON media_elements USING btree (user_id);


--
-- Name: fk__notifications_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__notifications_user_id ON notifications USING btree (user_id);


--
-- Name: fk__purchases_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__purchases_location_id ON purchases USING btree (location_id);


--
-- Name: fk__reports_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__reports_user_id ON reports USING btree (user_id);


--
-- Name: fk__slides_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__slides_lesson_id ON slides USING btree (lesson_id);


--
-- Name: fk__taggings_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__taggings_tag_id ON taggings USING btree (tag_id);


--
-- Name: fk__users_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_location_id ON users USING btree (location_id);


--
-- Name: fk__users_purchase_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_purchase_id ON users USING btree (purchase_id);


--
-- Name: fk__users_school_level_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_school_level_id ON users USING btree (school_level_id);


--
-- Name: fk__users_subjects_subject_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_subjects_subject_id ON users_subjects USING btree (subject_id);


--
-- Name: fk__users_subjects_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_subjects_user_id ON users_subjects USING btree (user_id);


--
-- Name: fk__virtual_classroom_lessons_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__virtual_classroom_lessons_lesson_id ON virtual_classroom_lessons USING btree (lesson_id);


--
-- Name: fk__virtual_classroom_lessons_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__virtual_classroom_lessons_user_id ON virtual_classroom_lessons USING btree (user_id);


--
-- Name: index_bookmarks_on_bookmarkable_type_bookmarkable_id_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_bookmarks_on_bookmarkable_type_bookmarkable_id_user_id ON bookmarks USING btree (bookmarkable_type, bookmarkable_id, user_id);


--
-- Name: index_locations_on_ancestry; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_locations_on_ancestry ON locations USING btree (ancestry);


--
-- Name: index_reports_on_reportable_type_and_reportable_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_reports_on_reportable_type_and_reportable_id_and_user_id ON reports USING btree (reportable_type, reportable_id, user_id);


--
-- Name: index_slides_on_position_and_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_slides_on_position_and_lesson_id ON slides USING btree ("position", lesson_id);


--
-- Name: index_taggings_on_taggable_type_and_taggable_id_and_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_taggings_on_taggable_type_and_taggable_id_and_tag_id ON taggings USING btree (taggable_type, taggable_id, tag_id);


--
-- Name: index_tags_on_word; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_word ON tags USING btree (word);


--
-- Name: index_users_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_active ON users USING btree (active);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_confirmed; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_confirmed ON users USING btree (confirmed);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_password_token ON users USING btree (password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_bookmarks_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT fk_bookmarks_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_documents_slides_document_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_slides
    ADD CONSTRAINT fk_documents_slides_document_id FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE;


--
-- Name: fk_documents_slides_slide_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_slides
    ADD CONSTRAINT fk_documents_slides_slide_id FOREIGN KEY (slide_id) REFERENCES slides(id) ON DELETE CASCADE;


--
-- Name: fk_documents_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT fk_documents_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_lessons_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT fk_lessons_parent_id FOREIGN KEY (parent_id) REFERENCES lessons(id) ON DELETE SET NULL;


--
-- Name: fk_lessons_school_level_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT fk_lessons_school_level_id FOREIGN KEY (school_level_id) REFERENCES school_levels(id);


--
-- Name: fk_lessons_subject_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT fk_lessons_subject_id FOREIGN KEY (subject_id) REFERENCES subjects(id);


--
-- Name: fk_lessons_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT fk_lessons_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_likes_lesson_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT fk_likes_lesson_id FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE;


--
-- Name: fk_likes_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT fk_likes_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_mailing_list_addresses_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailing_list_addresses
    ADD CONSTRAINT fk_mailing_list_addresses_group_id FOREIGN KEY (group_id) REFERENCES mailing_list_groups(id) ON DELETE CASCADE;


--
-- Name: fk_mailing_list_groups_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mailing_list_groups
    ADD CONSTRAINT fk_mailing_list_groups_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_media_elements_slides_media_element_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_elements_slides
    ADD CONSTRAINT fk_media_elements_slides_media_element_id FOREIGN KEY (media_element_id) REFERENCES media_elements(id) ON DELETE CASCADE;


--
-- Name: fk_media_elements_slides_slide_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_elements_slides
    ADD CONSTRAINT fk_media_elements_slides_slide_id FOREIGN KEY (slide_id) REFERENCES slides(id) ON DELETE CASCADE;


--
-- Name: fk_media_elements_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_elements
    ADD CONSTRAINT fk_media_elements_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_notifications_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_purchases_location_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY purchases
    ADD CONSTRAINT fk_purchases_location_id FOREIGN KEY (location_id) REFERENCES locations(id);


--
-- Name: fk_reports_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT fk_reports_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_slides_lesson_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slides
    ADD CONSTRAINT fk_slides_lesson_id FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE;


--
-- Name: fk_taggings_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT fk_taggings_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- Name: fk_users_location_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_location_id FOREIGN KEY (location_id) REFERENCES locations(id);


--
-- Name: fk_users_purchase_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_purchase_id FOREIGN KEY (purchase_id) REFERENCES purchases(id);


--
-- Name: fk_users_school_level_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_school_level_id FOREIGN KEY (school_level_id) REFERENCES school_levels(id);


--
-- Name: fk_users_subjects_subject_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_subjects
    ADD CONSTRAINT fk_users_subjects_subject_id FOREIGN KEY (subject_id) REFERENCES subjects(id);


--
-- Name: fk_users_subjects_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_subjects
    ADD CONSTRAINT fk_users_subjects_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_virtual_classroom_lessons_lesson_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY virtual_classroom_lessons
    ADD CONSTRAINT fk_virtual_classroom_lessons_lesson_id FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE;


--
-- Name: fk_virtual_classroom_lessons_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY virtual_classroom_lessons
    ADD CONSTRAINT fk_virtual_classroom_lessons_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20120923120617');

INSERT INTO schema_migrations (version) VALUES ('20120924120617');

INSERT INTO schema_migrations (version) VALUES ('20120924121212');

INSERT INTO schema_migrations (version) VALUES ('20120924121636');

INSERT INTO schema_migrations (version) VALUES ('20120924121650');

INSERT INTO schema_migrations (version) VALUES ('20120924121714');

INSERT INTO schema_migrations (version) VALUES ('20120924121814');

INSERT INTO schema_migrations (version) VALUES ('20120924121937');

INSERT INTO schema_migrations (version) VALUES ('20120924122254');

INSERT INTO schema_migrations (version) VALUES ('20120924122935');

INSERT INTO schema_migrations (version) VALUES ('20120924123433');

INSERT INTO schema_migrations (version) VALUES ('20120924123913');

INSERT INTO schema_migrations (version) VALUES ('20120924125156');

INSERT INTO schema_migrations (version) VALUES ('20120924125333');

INSERT INTO schema_migrations (version) VALUES ('20120924125729');

INSERT INTO schema_migrations (version) VALUES ('20120924125840');

INSERT INTO schema_migrations (version) VALUES ('20120924130035');

INSERT INTO schema_migrations (version) VALUES ('20120926153638');

INSERT INTO schema_migrations (version) VALUES ('20120926153643');

INSERT INTO schema_migrations (version) VALUES ('20120927141837');

INSERT INTO schema_migrations (version) VALUES ('20121206140304');

INSERT INTO schema_migrations (version) VALUES ('20130131093624');

INSERT INTO schema_migrations (version) VALUES ('20130131094635');

INSERT INTO schema_migrations (version) VALUES ('20130709101814');

INSERT INTO schema_migrations (version) VALUES ('20130709121200');
