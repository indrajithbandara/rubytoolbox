SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

--
-- Name: categories_update_name_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION categories_update_name_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    new.name_tsvector := to_tsvector('pg_catalog.simple', coalesce(new.name, ''));
    RETURN NEW;
END;
$$;


--
-- Name: projects_update_description_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION projects_update_description_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    new.description_tsvector := to_tsvector('pg_catalog.simple', coalesce(new.description, ''));
    RETURN NEW;
END;
$$;


--
-- Name: projects_update_permalink_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION projects_update_permalink_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    new.permalink_tsvector := to_tsvector('pg_catalog.simple', coalesce(new.permalink, ''));
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    permalink citext NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_group_permalink citext NOT NULL,
    name_tsvector tsvector
);


--
-- Name: categorizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categorizations (
    id bigint NOT NULL,
    category_permalink citext NOT NULL,
    project_permalink character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categorizations_id_seq OWNED BY categorizations.id;


--
-- Name: category_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE category_groups (
    permalink citext NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: github_repos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE github_repos (
    path citext NOT NULL,
    stargazers_count integer NOT NULL,
    forks_count integer NOT NULL,
    watchers_count integer NOT NULL,
    description character varying,
    homepage_url character varying,
    repo_created_at timestamp without time zone,
    repo_updated_at timestamp without time zone,
    repo_pushed_at timestamp without time zone,
    has_issues boolean,
    has_projects boolean,
    has_downloads boolean,
    has_wiki boolean,
    has_pages boolean,
    archived boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    permalink character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rubygem_name character varying,
    github_repo_path citext,
    score numeric(5,2),
    description text,
    permalink_tsvector tsvector,
    description_tsvector tsvector,
    CONSTRAINT check_project_permalink_and_rubygem_name_parity CHECK (((rubygem_name IS NULL) OR ((rubygem_name)::text = (permalink)::text)))
);


--
-- Name: rubygems; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rubygems (
    name character varying NOT NULL,
    downloads integer NOT NULL,
    current_version character varying NOT NULL,
    authors character varying,
    description text,
    licenses character varying[] DEFAULT '{}'::character varying[],
    bug_tracker_url character varying,
    changelog_url character varying,
    documentation_url character varying,
    homepage_url character varying,
    mailing_list_url character varying,
    source_code_url character varying,
    wiki_url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_release_on date,
    latest_release_on date,
    releases_count integer,
    reverse_dependencies_count integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categorizations ALTER COLUMN id SET DEFAULT nextval('categorizations_id_seq'::regclass);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categorizations
    ADD CONSTRAINT categorizations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: categorizations_unique_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX categorizations_unique_index ON categorizations USING btree (category_permalink, project_permalink);


--
-- Name: index_categories_on_category_group_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_category_group_permalink ON categories USING btree (category_group_permalink);


--
-- Name: index_categories_on_name_tsvector; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_name_tsvector ON categories USING gin (name_tsvector);


--
-- Name: index_categories_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_categories_on_permalink ON categories USING btree (permalink);


--
-- Name: index_categorizations_on_category_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categorizations_on_category_permalink ON categorizations USING btree (category_permalink);


--
-- Name: index_categorizations_on_project_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categorizations_on_project_permalink ON categorizations USING btree (project_permalink);


--
-- Name: index_category_groups_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_category_groups_on_permalink ON category_groups USING btree (permalink);


--
-- Name: index_github_repos_on_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_github_repos_on_path ON github_repos USING btree (path);


--
-- Name: index_projects_on_description_tsvector; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_description_tsvector ON projects USING gin (description_tsvector);


--
-- Name: index_projects_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_permalink ON projects USING btree (permalink);


--
-- Name: index_projects_on_permalink_tsvector; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_permalink_tsvector ON projects USING gin (permalink_tsvector);


--
-- Name: index_projects_on_rubygem_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_rubygem_name ON projects USING btree (rubygem_name);


--
-- Name: index_rubygems_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_rubygems_on_name ON rubygems USING btree (name);


--
-- Name: categories_update_name_tsvector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER categories_update_name_tsvector_trigger BEFORE INSERT OR UPDATE ON categories FOR EACH ROW EXECUTE PROCEDURE categories_update_name_tsvector_trigger();


--
-- Name: projects_update_description_tsvector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER projects_update_description_tsvector_trigger BEFORE INSERT OR UPDATE ON projects FOR EACH ROW EXECUTE PROCEDURE projects_update_description_tsvector_trigger();


--
-- Name: projects_update_permalink_tsvector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER projects_update_permalink_tsvector_trigger BEFORE INSERT OR UPDATE ON projects FOR EACH ROW EXECUTE PROCEDURE projects_update_permalink_tsvector_trigger();


--
-- Name: fk_rails_1c87ed593b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categorizations
    ADD CONSTRAINT fk_rails_1c87ed593b FOREIGN KEY (category_permalink) REFERENCES categories(permalink);


--
-- Name: fk_rails_2f82cbb022; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categorizations
    ADD CONSTRAINT fk_rails_2f82cbb022 FOREIGN KEY (project_permalink) REFERENCES projects(permalink);


--
-- Name: fk_rails_4bd2d3273a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_rails_4bd2d3273a FOREIGN KEY (category_group_permalink) REFERENCES category_groups(permalink);


--
-- Name: fk_rails_ddb4eb0108; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_rails_ddb4eb0108 FOREIGN KEY (rubygem_name) REFERENCES rubygems(name);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO "schema_migrations" (version) VALUES
('20171026191745'),
('20171026202351'),
('20171026220117'),
('20171026221717'),
('20171028210534'),
('20171230223928'),
('20180103193038'),
('20180103194335'),
('20180103233845'),
('20180104223026'),
('20180105234511'),
('20180114223052'),
('20180118191419'),
('20180126213034'),
('20180126214714'),
('20180127203832'),
('20180127211755'),
('20180221214013');


