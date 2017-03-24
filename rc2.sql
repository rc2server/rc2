--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

ALTER TABLE IF EXISTS ONLY public.sessionrecord DROP CONSTRAINT IF EXISTS sessionrecord_wspace_fk;
ALTER TABLE IF EXISTS ONLY public.sessionimage DROP CONSTRAINT IF EXISTS sessionimage_sessionrec_fk;
ALTER TABLE IF EXISTS ONLY public.rcworkspacedata DROP CONSTRAINT IF EXISTS rcworkspacedata_id_fkey;
ALTER TABLE IF EXISTS ONLY public.rcworkspace DROP CONSTRAINT IF EXISTS rcworkspace_userid_fkey;
ALTER TABLE IF EXISTS ONLY public.rcworkspace DROP CONSTRAINT IF EXISTS rcworkspace_projectid_fkey;
ALTER TABLE IF EXISTS ONLY public.rcuser DROP CONSTRAINT IF EXISTS rcuser_ldapid_fkey;
ALTER TABLE IF EXISTS ONLY public.rcproject DROP CONSTRAINT IF EXISTS rcproject_userid_fkey;
ALTER TABLE IF EXISTS ONLY public.rcfiledata DROP CONSTRAINT IF EXISTS rcfiledata_file_fk;
ALTER TABLE IF EXISTS ONLY public.rcfile DROP CONSTRAINT IF EXISTS rcfile_wspaceid_fkey;
ALTER TABLE IF EXISTS ONLY public.logentry DROP CONSTRAINT IF EXISTS logentry_uaid_fkey;
ALTER TABLE IF EXISTS ONLY public.logentry DROP CONSTRAINT IF EXISTS logentry_appid_fkey;
ALTER TABLE IF EXISTS ONLY public.crashdata DROP CONSTRAINT IF EXISTS crashdata_userid_fkey;
DROP TRIGGER IF EXISTS rcworkspace_update_version ON public.rcworkspace;
DROP TRIGGER IF EXISTS rcworkspace_update_lastmod ON public.rcworkspace;
DROP TRIGGER IF EXISTS rcuser_update_version ON public.rcuser;
DROP TRIGGER IF EXISTS rcuser_update_lastmod ON public.rcuser;
DROP TRIGGER IF EXISTS rcproject_update_version ON public.rcproject;
DROP TRIGGER IF EXISTS rcproject_update_lastmod ON public.rcproject;
DROP TRIGGER IF EXISTS rcfile_trigger_notifyu ON public.rcfile;
DROP TRIGGER IF EXISTS rcfile_trigger_notifyi ON public.rcfile;
DROP TRIGGER IF EXISTS rcfile_trigger_notifyd ON public.rcfile;
DROP INDEX IF EXISTS public.tokens_idx;
DROP INDEX IF EXISTS public.sessionimage_sessionrec_idx;
DROP INDEX IF EXISTS public.rcuser_login_idx;
DROP INDEX IF EXISTS public.rcuser_email_idx;
ALTER TABLE IF EXISTS ONLY public.sessionrecord DROP CONSTRAINT IF EXISTS sessionrecord_pkey;
ALTER TABLE IF EXISTS ONLY public.sessionimage DROP CONSTRAINT IF EXISTS sessionimage_pkey;
ALTER TABLE IF EXISTS ONLY public.rcworkspacedata DROP CONSTRAINT IF EXISTS rcworkspacedata_pkey;
ALTER TABLE IF EXISTS ONLY public.rcworkspace DROP CONSTRAINT IF EXISTS rcworkspace_uniqueid_key;
ALTER TABLE IF EXISTS ONLY public.rcworkspace DROP CONSTRAINT IF EXISTS rcworkspace_pkey;
ALTER TABLE IF EXISTS ONLY public.rcuser DROP CONSTRAINT IF EXISTS rcuser_pkey;
ALTER TABLE IF EXISTS ONLY public.rcuser DROP CONSTRAINT IF EXISTS rcuser_login_unique;
ALTER TABLE IF EXISTS ONLY public.rctemplate DROP CONSTRAINT IF EXISTS rctemplate_pkey;
ALTER TABLE IF EXISTS ONLY public.rctemplate DROP CONSTRAINT IF EXISTS rctemplate_name_key;
ALTER TABLE IF EXISTS ONLY public.rcproject DROP CONSTRAINT IF EXISTS rcproject_pkey;
ALTER TABLE IF EXISTS ONLY public.rcnoance DROP CONSTRAINT IF EXISTS rcnoance_pkey;
ALTER TABLE IF EXISTS ONLY public.rcfiledata DROP CONSTRAINT IF EXISTS rcfiledata_pkey;
ALTER TABLE IF EXISTS ONLY public.rcfile DROP CONSTRAINT IF EXISTS rcfile_pkey;
ALTER TABLE IF EXISTS ONLY public.logua DROP CONSTRAINT IF EXISTS logua_pkey;
ALTER TABLE IF EXISTS ONLY public.logintokens DROP CONSTRAINT IF EXISTS logintokens_pkey;
ALTER TABLE IF EXISTS ONLY public.logentry DROP CONSTRAINT IF EXISTS logentry_pkey;
ALTER TABLE IF EXISTS ONLY public.logapp DROP CONSTRAINT IF EXISTS logapp_pkey;
ALTER TABLE IF EXISTS ONLY public.ldapserver DROP CONSTRAINT IF EXISTS ldapserver_pkey;
ALTER TABLE IF EXISTS ONLY public.crashdata DROP CONSTRAINT IF EXISTS crashdata_pkey;
DROP TABLE IF EXISTS public.metadata;
DROP TABLE IF EXISTS public.sessionrecord;
DROP SEQUENCE IF EXISTS public.sessionrecord_seq;
DROP TABLE IF EXISTS public.sessionimage;
DROP SEQUENCE IF EXISTS public.sessionimage_seq;
DROP TABLE IF EXISTS public.rcworkspacedata;
DROP TABLE IF EXISTS public.rcworkspace;
DROP SEQUENCE IF EXISTS public.rcworkspace_seq;
DROP TABLE IF EXISTS public.rcuser;
DROP SEQUENCE IF EXISTS public.rcuser_seq;
DROP TABLE IF EXISTS public.rctemplate;
DROP SEQUENCE IF EXISTS public.rctemplate_seq;
DROP TABLE IF EXISTS public.rcproject;
DROP SEQUENCE IF EXISTS public.rcproject_seq;
DROP TABLE IF EXISTS public.rcnoance;
DROP SEQUENCE IF EXISTS public.rcnoance_seq;
DROP TABLE IF EXISTS public.rcfiledata;
DROP TABLE IF EXISTS public.rcfile;
DROP SEQUENCE IF EXISTS public.rcfile_seq;
DROP TABLE IF EXISTS public.logua;
DROP SEQUENCE IF EXISTS public.logua_seq;
DROP TABLE IF EXISTS public.logintokens;
DROP SEQUENCE IF EXISTS public.logintokens_seq;
DROP TABLE IF EXISTS public.logentry;
DROP SEQUENCE IF EXISTS public.logentry_seq;
DROP TABLE IF EXISTS public.logapp;
DROP SEQUENCE IF EXISTS public.logapp_seq;
DROP TABLE IF EXISTS public.ldapserver;
DROP TABLE IF EXISTS public.crashdata;
DROP SEQUENCE IF EXISTS public.crashdata_seq;
DROP FUNCTION IF EXISTS public.update_version_column();
DROP FUNCTION IF EXISTS public.update_lastmodified_column();
DROP FUNCTION IF EXISTS public.rcfile_notifyu();
DROP FUNCTION IF EXISTS public.rcfile_notifyi();
DROP FUNCTION IF EXISTS public.rcfile_notifyd();
DROP FUNCTION IF EXISTS public.rc2createuser(login character varying, fname character varying, lname character varying, email character varying, password character varying);

--
-- Name: rc2createuser(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rc2createuser(login character varying, fname character varying, lname character varying, email character varying, password character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
userId integer;
projectId integer;
BEGIN
INSERT INTO rcuser (login, firstname, lastname, email, passworddata) VALUES
(login, fname, lname, email, crypt(password, gen_salt('bf', 8))) RETURNING id INTO userId;
INSERT INTO rcproject (userid, name) VALUES (userId, 'default') RETURNING ID INTO projectId;
INSERT INTO rcworkspace (userid, projectid, name) VALUES (userId, projectId, 'default');
RETURN userId;
END;
$$;


--
-- Name: rcfile_notifyd(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rcfile_notifyd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
perform pg_notify(cast('rcfile' as text), 'd' || cast(old.id as text) || '/' || cast(old.wspaceid as text) || '/' || cast(old.version as text));
return new;
END;
$$;


--
-- Name: rcfile_notifyi(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rcfile_notifyi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
perform pg_notify(cast('rcfile' as text), 'i' || cast(new.id as text) || '/' || cast(new.wspaceid as text) || '/' || cast(new.version as text));
return new;
END;
$$;


--
-- Name: rcfile_notifyu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rcfile_notifyu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
perform pg_notify(cast('rcfile' as text), 'u' || cast(old.id as text) || '/' || cast(old.wspaceid as text) || '/' || cast(old.version as text));
return new;
END;
$$;


--
-- Name: update_lastmodified_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_lastmodified_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.lastmodified = now(); 
   RETURN NEW;
END;
$$;


--
-- Name: update_version_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_version_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.version = NEW.version + 1; 
   RETURN NEW;
END;
$$;

--
-- Name: metadata; Type: TABLE; Schema: public; Owner: rc2; Tablespace: 
--

CREATE TABLE metadata (
    key character varying(200) NOT NULL,
    valuestr character(200),
    valueint integer
);

--
-- Data for Name: metadata; Type: TABLE DATA; Schema: public; Owner: rc2
--

insert into metadata (key, valueint) values ('sqlSchemaVersion', 2);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: rc2; Tablespace: 
--

ALTER TABLE ONLY metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (key);


--
-- Name: crashdata_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE crashdata_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: crashdata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crashdata (
    id integer DEFAULT nextval('crashdata_seq'::regclass) NOT NULL,
    userid integer,
    reportdate timestamp without time zone DEFAULT now() NOT NULL,
    crashdata bytea
);


--
-- Name: logapp_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logapp_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logapp; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logapp (
    id integer DEFAULT nextval('logapp_seq'::regclass) NOT NULL,
    name character varying(40) NOT NULL,
    apikey character varying(40) NOT NULL
);


--
-- Name: logentry_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logentry_seq
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logentry; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logentry (
    id integer DEFAULT nextval('logentry_seq'::regclass) NOT NULL,
    appid integer NOT NULL,
    uaid integer,
    clientidentifier character varying(80),
    datereceived timestamp without time zone DEFAULT now() NOT NULL,
    level integer,
    context integer,
    versionstr character varying(60),
    message character varying(1024)
);


--
-- Name: logintokens_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logintokens_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logintokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logintokens (
    id integer DEFAULT nextval('logintokens_seq'::regclass) NOT NULL,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    userid integer NOT NULL,
    series_ident bigint NOT NULL,
    token_ident bigint NOT NULL
);


--
-- Name: logua_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logua_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logua; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logua (
    id integer DEFAULT nextval('logua_seq'::regclass) NOT NULL,
    uastring character varying(200) NOT NULL
);


--
-- Name: rcfile_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rcfile_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rcfile; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rcfile (
    id integer DEFAULT nextval('rcfile_seq'::regclass) NOT NULL,
    wspaceid integer NOT NULL,
    name character varying(200) NOT NULL,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    lastmodified timestamp without time zone DEFAULT now() NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    filesize integer,
    objtype character varying(10) DEFAULT 'file'::character varying
);


--
-- Name: rcfiledata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rcfiledata (
    id integer NOT NULL,
    bindata bytea
);


--
-- Name: rcnoance_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rcnoance_seq
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rcnoance; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rcnoance (
    id integer DEFAULT nextval('rcnoance_seq'::regclass) NOT NULL,
    userid integer NOT NULL,
    requesttime timestamp without time zone NOT NULL,
    action character varying(30) NOT NULL,
    noance character varying(100) NOT NULL
);


--
-- Name: rcproject_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rcproject_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rcproject; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rcproject (
    id integer DEFAULT nextval('rcproject_seq'::regclass) NOT NULL,
    name character varying(60) NOT NULL,
    userid integer NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    lastaccess timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: rctemplate_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rctemplate_seq
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rctemplate; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rctemplate (
    id integer DEFAULT nextval('rctemplate_seq'::regclass) NOT NULL,
    name character varying(20) NOT NULL,
    content text
);


--
-- Name: rcuser_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rcuser_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rcuser; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rcuser (
    id integer DEFAULT nextval('rcuser_seq'::regclass) NOT NULL,
    login character varying(40) NOT NULL,
    firstname character varying(20),
    lastname character varying(20),
    email character varying(80) NOT NULL,
    passworddata character varying(200),
    admin boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    lastmodified timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: rcworkspace_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rcworkspace_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rcworkspace; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rcworkspace (
    id integer DEFAULT nextval('rcworkspace_seq'::regclass) NOT NULL,
    name character varying(60) NOT NULL,
    userid integer NOT NULL,
    projectid integer NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    lastaccess timestamp without time zone DEFAULT now() NOT NULL,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    uniqueid character(36) DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: rcworkspacedata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rcworkspacedata (
    id integer NOT NULL,
    bindata bytea
);


--
-- Name: sessionimage_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessionimage_seq
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessionimage; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessionimage (
    id integer DEFAULT nextval('sessionimage_seq'::regclass) NOT NULL,
    sessionid integer NOT NULL,
    batchid integer DEFAULT 0 NOT NULL,
    name character varying(80) NOT NULL,
    title character varying(255),
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    imgdata bytea
);


--
-- Name: sessionrecord_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessionrecord_seq
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessionrecord; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessionrecord (
    id integer DEFAULT nextval('sessionrecord_seq'::regclass) NOT NULL,
    wspaceid integer NOT NULL,
    startdate timestamp without time zone DEFAULT now() NOT NULL,
    enddate timestamp without time zone
);


--
-- Name: crashdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crashdata
    ADD CONSTRAINT crashdata_pkey PRIMARY KEY (id);


--
-- Name: logapp_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logapp
    ADD CONSTRAINT logapp_pkey PRIMARY KEY (id);


--
-- Name: logentry_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logentry
    ADD CONSTRAINT logentry_pkey PRIMARY KEY (id);


--
-- Name: logintokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logintokens
    ADD CONSTRAINT logintokens_pkey PRIMARY KEY (id);


--
-- Name: logua_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logua
    ADD CONSTRAINT logua_pkey PRIMARY KEY (id);


--
-- Name: rcfile_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcfile
    ADD CONSTRAINT rcfile_pkey PRIMARY KEY (id);


--
-- Name: rcfiledata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcfiledata
    ADD CONSTRAINT rcfiledata_pkey PRIMARY KEY (id);


--
-- Name: rcnoance_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcnoance
    ADD CONSTRAINT rcnoance_pkey PRIMARY KEY (id);


--
-- Name: rcproject_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcproject
    ADD CONSTRAINT rcproject_pkey PRIMARY KEY (id);


--
-- Name: rctemplate_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rctemplate
    ADD CONSTRAINT rctemplate_name_key UNIQUE (name);


--
-- Name: rctemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rctemplate
    ADD CONSTRAINT rctemplate_pkey PRIMARY KEY (id);


--
-- Name: rcuser_login_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcuser
    ADD CONSTRAINT rcuser_login_unique UNIQUE (login);


--
-- Name: rcuser_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcuser
    ADD CONSTRAINT rcuser_pkey PRIMARY KEY (id);


--
-- Name: rcworkspace_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcworkspace
    ADD CONSTRAINT rcworkspace_pkey PRIMARY KEY (id);


--
-- Name: rcworkspace_uniqueid_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcworkspace
    ADD CONSTRAINT rcworkspace_uniqueid_key UNIQUE (uniqueid);


--
-- Name: rcworkspacedata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rcworkspacedata
    ADD CONSTRAINT rcworkspacedata_pkey PRIMARY KEY (id);


--
-- Name: sessionimage_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessionimage
    ADD CONSTRAINT sessionimage_pkey PRIMARY KEY (id);


--
-- Name: sessionrecord_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessionrecord
    ADD CONSTRAINT sessionrecord_pkey PRIMARY KEY (id);


--
-- Name: rcuser_email_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX rcuser_email_idx ON rcuser USING btree (email);


--
-- Name: rcuser_login_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX rcuser_login_idx ON rcuser USING btree (login);


--
-- Name: sessionimage_sessionrec_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX sessionimage_sessionrec_idx ON sessionimage USING btree (sessionid);


--
-- Name: tokens_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX tokens_idx ON logintokens USING btree (userid, series_ident);


--
-- Name: rcfile_trigger_notifyd; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcfile_trigger_notifyd AFTER DELETE ON rcfile FOR EACH ROW EXECUTE PROCEDURE rcfile_notifyd();


--
-- Name: rcfile_trigger_notifyi; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcfile_trigger_notifyi AFTER INSERT ON rcfile FOR EACH ROW EXECUTE PROCEDURE rcfile_notifyi();


--
-- Name: rcfile_trigger_notifyu; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcfile_trigger_notifyu AFTER UPDATE ON rcfile FOR EACH ROW EXECUTE PROCEDURE rcfile_notifyu();


--
-- Name: rcproject_update_lastmod; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcproject_update_lastmod BEFORE UPDATE ON rcproject FOR EACH ROW EXECUTE PROCEDURE update_lastmodified_column();


--
-- Name: rcproject_update_version; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcproject_update_version BEFORE UPDATE ON rcproject FOR EACH ROW EXECUTE PROCEDURE update_version_column();


--
-- Name: rcuser_update_lastmod; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcuser_update_lastmod BEFORE UPDATE ON rcuser FOR EACH ROW EXECUTE PROCEDURE update_lastmodified_column();


--
-- Name: rcuser_update_version; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcuser_update_version BEFORE UPDATE ON rcuser FOR EACH ROW EXECUTE PROCEDURE update_version_column();


--
-- Name: rcworkspace_update_lastmod; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcworkspace_update_lastmod BEFORE UPDATE ON rcworkspace FOR EACH ROW EXECUTE PROCEDURE update_lastmodified_column();


--
-- Name: rcworkspace_update_version; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rcworkspace_update_version BEFORE UPDATE ON rcworkspace FOR EACH ROW EXECUTE PROCEDURE update_version_column();


--
-- Name: crashdata_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY crashdata
    ADD CONSTRAINT crashdata_userid_fkey FOREIGN KEY (userid) REFERENCES rcuser(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: logentry_appid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logentry
    ADD CONSTRAINT logentry_appid_fkey FOREIGN KEY (appid) REFERENCES logapp(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: logentry_uaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logentry
    ADD CONSTRAINT logentry_uaid_fkey FOREIGN KEY (uaid) REFERENCES logua(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rcfile_wspaceid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rcfile
    ADD CONSTRAINT rcfile_wspaceid_fkey FOREIGN KEY (wspaceid) REFERENCES rcworkspace(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rcfiledata_file_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rcfiledata
    ADD CONSTRAINT rcfiledata_file_fk FOREIGN KEY (id) REFERENCES rcfile(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rcproject_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rcproject
    ADD CONSTRAINT rcproject_userid_fkey FOREIGN KEY (userid) REFERENCES rcuser(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rcworkspace_projectid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rcworkspace
    ADD CONSTRAINT rcworkspace_projectid_fkey FOREIGN KEY (projectid) REFERENCES rcproject(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: rcworkspacedata_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rcworkspacedata
    ADD CONSTRAINT rcworkspacedata_id_fkey FOREIGN KEY (id) REFERENCES rcworkspace(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sessionimage_sessionrec_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessionimage
    ADD CONSTRAINT sessionimage_sessionrec_fk FOREIGN KEY (sessionid) REFERENCES sessionrecord(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sessionrecord_wspace_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessionrecord
    ADD CONSTRAINT sessionrecord_wspace_fk FOREIGN KEY (wspaceid) REFERENCES rcworkspace(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

