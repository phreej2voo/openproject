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
-- Name: versions_name; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public.versions_name (provider = icu, locale = 'und-u-kn-true');


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id bigint NOT NULL,
    text text,
    show_until date,
    active boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: attachable_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachable_journals (
    id bigint NOT NULL,
    journal_id bigint NOT NULL,
    attachment_id bigint NOT NULL,
    filename character varying NOT NULL
);


--
-- Name: attachable_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attachable_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachable_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attachable_journals_id_seq OWNED BY public.attachable_journals.id;


--
-- Name: attachment_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachment_journals (
    id bigint NOT NULL,
    container_id bigint,
    container_type character varying(30),
    filename character varying NOT NULL,
    disk_filename character varying NOT NULL,
    filesize bigint NOT NULL,
    content_type character varying,
    digest character varying(40) NOT NULL,
    downloads integer NOT NULL,
    author_id bigint NOT NULL,
    description text
);


--
-- Name: attachment_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attachment_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachment_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attachment_journals_id_seq OWNED BY public.attachment_journals.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    id bigint NOT NULL,
    container_id bigint,
    container_type character varying(30),
    filename character varying DEFAULT ''::character varying NOT NULL,
    disk_filename character varying DEFAULT ''::character varying NOT NULL,
    filesize bigint DEFAULT 0 NOT NULL,
    content_type character varying DEFAULT ''::character varying,
    digest character varying(40) DEFAULT ''::character varying NOT NULL,
    downloads integer DEFAULT 0 NOT NULL,
    author_id bigint NOT NULL,
    created_at timestamp with time zone,
    description character varying,
    file character varying,
    fulltext text,
    fulltext_tsv tsvector,
    file_tsv tsvector,
    updated_at timestamp with time zone,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: attribute_help_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_help_texts (
    id bigint NOT NULL,
    help_text text NOT NULL,
    type character varying NOT NULL,
    attribute_name character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: attribute_help_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_help_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_help_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_help_texts_id_seq OWNED BY public.attribute_help_texts.id;


--
-- Name: auth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_providers (
    id bigint NOT NULL,
    type character varying NOT NULL,
    display_name character varying NOT NULL,
    slug character varying NOT NULL,
    available boolean DEFAULT true NOT NULL,
    limit_self_registration boolean DEFAULT false NOT NULL,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    creator_id bigint NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: auth_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_providers_id_seq OWNED BY public.auth_providers.id;


--
-- Name: bcf_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bcf_comments (
    id bigint NOT NULL,
    uuid text,
    journal_id bigint,
    issue_id bigint,
    viewpoint_id bigint,
    reply_to bigint
);


--
-- Name: bcf_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bcf_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bcf_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bcf_comments_id_seq OWNED BY public.bcf_comments.id;


--
-- Name: bcf_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bcf_issues (
    id bigint NOT NULL,
    uuid text,
    markup xml,
    work_package_id bigint,
    stage character varying,
    index integer,
    labels text[] DEFAULT '{}'::text[],
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: bcf_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bcf_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bcf_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bcf_issues_id_seq OWNED BY public.bcf_issues.id;


--
-- Name: bcf_viewpoints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bcf_viewpoints (
    id bigint NOT NULL,
    uuid text,
    viewpoint_name text,
    issue_id bigint,
    json_viewpoint jsonb,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: bcf_viewpoints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bcf_viewpoints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bcf_viewpoints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bcf_viewpoints_id_seq OWNED BY public.bcf_viewpoints.id;


--
-- Name: budget_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_journals (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    author_id bigint NOT NULL,
    subject character varying NOT NULL,
    description text,
    fixed_date date NOT NULL
);


--
-- Name: budget_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budget_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budget_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budget_journals_id_seq OWNED BY public.budget_journals.id;


--
-- Name: budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budgets (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    author_id bigint NOT NULL,
    subject character varying NOT NULL,
    description text NOT NULL,
    fixed_date date NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budgets_id_seq OWNED BY public.budgets.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    assigned_to_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.changes (
    id bigint NOT NULL,
    changeset_id bigint NOT NULL,
    action character varying(1) DEFAULT ''::character varying NOT NULL,
    path text NOT NULL,
    from_path text,
    from_revision character varying,
    revision character varying,
    branch character varying
);


--
-- Name: changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.changes_id_seq OWNED BY public.changes.id;


--
-- Name: changeset_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.changeset_journals (
    id bigint NOT NULL,
    repository_id bigint NOT NULL,
    revision character varying NOT NULL,
    committer character varying,
    committed_on timestamp with time zone NOT NULL,
    comments text,
    commit_date date,
    scmid character varying,
    user_id bigint
);


--
-- Name: changeset_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.changeset_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changeset_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.changeset_journals_id_seq OWNED BY public.changeset_journals.id;


--
-- Name: changesets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.changesets (
    id bigint NOT NULL,
    repository_id bigint NOT NULL,
    revision character varying NOT NULL,
    committer character varying,
    committed_on timestamp with time zone NOT NULL,
    comments text,
    commit_date date,
    scmid character varying,
    user_id bigint
);


--
-- Name: changesets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.changesets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changesets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.changesets_id_seq OWNED BY public.changesets.id;


--
-- Name: changesets_work_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.changesets_work_packages (
    changeset_id bigint NOT NULL,
    work_package_id bigint NOT NULL
);


--
-- Name: colors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.colors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    hexcode character varying NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: colors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.colors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: colors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.colors_id_seq OWNED BY public.colors.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    commented_type character varying(30) DEFAULT ''::character varying NOT NULL,
    commented_id bigint NOT NULL,
    author_id bigint NOT NULL,
    comments text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: cost_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cost_entries (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    project_id bigint NOT NULL,
    work_package_id bigint NOT NULL,
    cost_type_id bigint NOT NULL,
    units double precision NOT NULL,
    spent_on date NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comments character varying NOT NULL,
    blocked boolean DEFAULT false NOT NULL,
    overridden_costs numeric(15,4),
    costs numeric(15,4),
    rate_id bigint,
    tyear integer NOT NULL,
    tmonth integer NOT NULL,
    tweek integer NOT NULL,
    logged_by_id bigint
);


--
-- Name: cost_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cost_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cost_entries_id_seq OWNED BY public.cost_entries.id;


--
-- Name: cost_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cost_queries (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    project_id bigint,
    name character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    serialized character varying(2000) NOT NULL
);


--
-- Name: cost_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cost_queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cost_queries_id_seq OWNED BY public.cost_queries.id;


--
-- Name: cost_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cost_types (
    id bigint NOT NULL,
    name character varying NOT NULL,
    unit character varying NOT NULL,
    unit_plural character varying NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cost_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cost_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cost_types_id_seq OWNED BY public.cost_types.id;


--
-- Name: custom_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_actions (
    id bigint NOT NULL,
    name character varying,
    actions text,
    description text,
    "position" integer
);


--
-- Name: custom_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_actions_id_seq OWNED BY public.custom_actions.id;


--
-- Name: custom_actions_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_actions_projects (
    id bigint NOT NULL,
    project_id bigint,
    custom_action_id bigint
);


--
-- Name: custom_actions_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_actions_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_actions_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_actions_projects_id_seq OWNED BY public.custom_actions_projects.id;


--
-- Name: custom_actions_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_actions_roles (
    id bigint NOT NULL,
    role_id bigint,
    custom_action_id bigint
);


--
-- Name: custom_actions_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_actions_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_actions_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_actions_roles_id_seq OWNED BY public.custom_actions_roles.id;


--
-- Name: custom_actions_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_actions_statuses (
    id bigint NOT NULL,
    status_id bigint,
    custom_action_id bigint
);


--
-- Name: custom_actions_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_actions_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_actions_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_actions_statuses_id_seq OWNED BY public.custom_actions_statuses.id;


--
-- Name: custom_actions_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_actions_types (
    id bigint NOT NULL,
    type_id bigint,
    custom_action_id bigint
);


--
-- Name: custom_actions_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_actions_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_actions_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_actions_types_id_seq OWNED BY public.custom_actions_types.id;


--
-- Name: custom_field_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_field_sections (
    id bigint NOT NULL,
    "position" integer,
    name character varying,
    type character varying,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: custom_field_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_field_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_field_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_field_sections_id_seq OWNED BY public.custom_field_sections.id;


--
-- Name: custom_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_fields (
    id bigint NOT NULL,
    type character varying(30) DEFAULT ''::character varying NOT NULL,
    field_format character varying(30) DEFAULT ''::character varying NOT NULL,
    regexp character varying DEFAULT ''::character varying,
    min_length integer DEFAULT 0 NOT NULL,
    max_length integer DEFAULT 0 NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    is_for_all boolean DEFAULT false NOT NULL,
    is_filter boolean DEFAULT true NOT NULL,
    "position" integer DEFAULT 1,
    searchable boolean DEFAULT false,
    editable boolean DEFAULT true,
    admin_only boolean DEFAULT false NOT NULL,
    multi_value boolean DEFAULT false,
    default_value text,
    name character varying DEFAULT NULL::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    content_right_to_left boolean DEFAULT false,
    allow_non_open_versions boolean DEFAULT false,
    custom_field_section_id bigint,
    position_in_custom_field_section integer
);


--
-- Name: custom_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_fields_id_seq OWNED BY public.custom_fields.id;


--
-- Name: custom_fields_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_fields_projects (
    custom_field_id bigint NOT NULL,
    project_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- Name: custom_fields_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_fields_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_fields_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_fields_projects_id_seq OWNED BY public.custom_fields_projects.id;


--
-- Name: custom_fields_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_fields_types (
    custom_field_id bigint NOT NULL,
    type_id bigint NOT NULL
);


--
-- Name: custom_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_options (
    id bigint NOT NULL,
    custom_field_id bigint,
    "position" integer,
    default_value boolean,
    value text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: custom_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_options_id_seq OWNED BY public.custom_options.id;


--
-- Name: custom_styles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_styles (
    id bigint NOT NULL,
    logo character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    favicon character varying,
    touch_icon character varying,
    theme character varying DEFAULT 'OpenProject (default)'::character varying,
    theme_logo character varying,
    export_logo character varying,
    export_cover character varying,
    export_cover_text_color character varying
);


--
-- Name: custom_styles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_styles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_styles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_styles_id_seq OWNED BY public.custom_styles.id;


--
-- Name: custom_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_values (
    id bigint NOT NULL,
    customized_type character varying(30) DEFAULT ''::character varying NOT NULL,
    customized_id bigint NOT NULL,
    custom_field_id bigint NOT NULL,
    value text
);


--
-- Name: custom_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_values_id_seq OWNED BY public.custom_values.id;


--
-- Name: customizable_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customizable_journals (
    id bigint NOT NULL,
    journal_id bigint NOT NULL,
    custom_field_id bigint NOT NULL,
    value text
);


--
-- Name: customizable_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customizable_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customizable_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customizable_journals_id_seq OWNED BY public.customizable_journals.id;


--
-- Name: deploy_status_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_status_checks (
    id bigint NOT NULL,
    deploy_target_id bigint,
    github_pull_request_id bigint,
    core_sha text NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: deploy_status_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deploy_status_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deploy_status_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deploy_status_checks_id_seq OWNED BY public.deploy_status_checks.id;


--
-- Name: deploy_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_targets (
    id bigint NOT NULL,
    type text NOT NULL,
    host text NOT NULL,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: deploy_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deploy_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deploy_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deploy_targets_id_seq OWNED BY public.deploy_targets.id;


--
-- Name: design_colors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.design_colors (
    id bigint NOT NULL,
    variable character varying,
    hexcode character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: design_colors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.design_colors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_colors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.design_colors_id_seq OWNED BY public.design_colors.id;


--
-- Name: document_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_journals (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    category_id bigint NOT NULL,
    title character varying(60) NOT NULL,
    description text
);


--
-- Name: document_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_journals_id_seq OWNED BY public.document_journals.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    category_id bigint NOT NULL,
    title character varying(60) DEFAULT ''::character varying NOT NULL,
    description text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: done_statuses_for_project; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.done_statuses_for_project (
    project_id bigint,
    status_id bigint
);


--
-- Name: emoji_reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emoji_reactions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    reactable_type character varying NOT NULL,
    reactable_id bigint NOT NULL,
    reaction character varying NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: emoji_reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emoji_reactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emoji_reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emoji_reactions_id_seq OWNED BY public.emoji_reactions.id;


--
-- Name: enabled_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enabled_modules (
    id bigint NOT NULL,
    project_id bigint,
    name character varying NOT NULL
);


--
-- Name: enabled_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enabled_modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enabled_modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enabled_modules_id_seq OWNED BY public.enabled_modules.id;


--
-- Name: enterprise_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enterprise_tokens (
    id bigint NOT NULL,
    encoded_token text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: enterprise_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enterprise_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enterprise_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enterprise_tokens_id_seq OWNED BY public.enterprise_tokens.id;


--
-- Name: enumerations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enumerations (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    "position" integer DEFAULT 1,
    is_default boolean DEFAULT false NOT NULL,
    type character varying,
    active boolean DEFAULT true NOT NULL,
    project_id bigint,
    parent_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    color_id bigint
);


--
-- Name: enumerations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enumerations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enumerations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enumerations_id_seq OWNED BY public.enumerations.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exports (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    type character varying
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exports_id_seq OWNED BY public.exports.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    favored_type character varying NOT NULL,
    favored_id bigint NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: file_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_links (
    id bigint NOT NULL,
    storage_id bigint,
    creator_id bigint NOT NULL,
    container_id bigint,
    container_type character varying,
    origin_id character varying,
    origin_name character varying,
    origin_created_by_name character varying,
    origin_last_modified_by_name character varying,
    origin_mime_type character varying,
    origin_created_at timestamp with time zone,
    origin_updated_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: file_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_links_id_seq OWNED BY public.file_links.id;


--
-- Name: forums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forums (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    description character varying,
    "position" integer DEFAULT 1,
    topics_count integer DEFAULT 0 NOT NULL,
    messages_count integer DEFAULT 0 NOT NULL,
    last_message_id bigint
);


--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forums_id_seq OWNED BY public.forums.id;


--
-- Name: github_check_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_check_runs (
    id bigint NOT NULL,
    github_pull_request_id bigint NOT NULL,
    github_id bigint NOT NULL,
    github_html_url character varying NOT NULL,
    app_id bigint NOT NULL,
    github_app_owner_avatar_url character varying NOT NULL,
    status character varying NOT NULL,
    name character varying NOT NULL,
    conclusion character varying,
    output_title character varying,
    output_summary character varying,
    details_url character varying,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: github_check_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.github_check_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_check_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.github_check_runs_id_seq OWNED BY public.github_check_runs.id;


--
-- Name: github_pull_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_pull_requests (
    id bigint NOT NULL,
    github_user_id bigint,
    merged_by_id bigint,
    github_id bigint,
    number integer NOT NULL,
    github_html_url character varying NOT NULL,
    state character varying NOT NULL,
    repository character varying NOT NULL,
    github_updated_at timestamp with time zone,
    title character varying,
    body text,
    draft boolean,
    merged boolean,
    merged_at timestamp with time zone,
    comments_count integer,
    review_comments_count integer,
    additions_count integer,
    deletions_count integer,
    changed_files_count integer,
    labels json,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    repository_html_url character varying,
    merge_commit_sha text
);


--
-- Name: github_pull_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.github_pull_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_pull_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.github_pull_requests_id_seq OWNED BY public.github_pull_requests.id;


--
-- Name: github_pull_requests_work_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_pull_requests_work_packages (
    github_pull_request_id bigint NOT NULL,
    work_package_id bigint NOT NULL
);


--
-- Name: github_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_users (
    id bigint NOT NULL,
    github_id bigint NOT NULL,
    github_login character varying NOT NULL,
    github_html_url character varying NOT NULL,
    github_avatar_url character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: github_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.github_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: github_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.github_users_id_seq OWNED BY public.github_users.id;


--
-- Name: gitlab_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gitlab_issues (
    id bigint NOT NULL,
    gitlab_user_id bigint,
    gitlab_id bigint,
    number integer NOT NULL,
    gitlab_html_url character varying NOT NULL,
    state character varying NOT NULL,
    repository character varying NOT NULL,
    gitlab_updated_at timestamp(6) with time zone,
    title character varying,
    body text,
    labels json,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: gitlab_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gitlab_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gitlab_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gitlab_issues_id_seq OWNED BY public.gitlab_issues.id;


--
-- Name: gitlab_issues_work_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gitlab_issues_work_packages (
    gitlab_issue_id bigint NOT NULL,
    work_package_id bigint NOT NULL
);


--
-- Name: gitlab_merge_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gitlab_merge_requests (
    id bigint NOT NULL,
    gitlab_user_id bigint,
    merged_by_id bigint,
    gitlab_id bigint,
    number integer NOT NULL,
    gitlab_html_url character varying NOT NULL,
    state character varying NOT NULL,
    repository character varying NOT NULL,
    gitlab_updated_at timestamp with time zone,
    title character varying,
    body text,
    draft boolean,
    merged boolean,
    merged_at timestamp with time zone,
    labels json,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: gitlab_merge_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gitlab_merge_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gitlab_merge_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gitlab_merge_requests_id_seq OWNED BY public.gitlab_merge_requests.id;


--
-- Name: gitlab_merge_requests_work_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gitlab_merge_requests_work_packages (
    gitlab_merge_request_id bigint NOT NULL,
    work_package_id bigint NOT NULL
);


--
-- Name: gitlab_pipelines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gitlab_pipelines (
    id bigint NOT NULL,
    gitlab_merge_request_id bigint NOT NULL,
    gitlab_id bigint NOT NULL,
    gitlab_html_url character varying NOT NULL,
    project_id bigint NOT NULL,
    gitlab_user_avatar_url character varying NOT NULL,
    status character varying NOT NULL,
    name character varying NOT NULL,
    details_url character varying,
    ci_details json,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    username text,
    commit_id text
);


--
-- Name: gitlab_pipelines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gitlab_pipelines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gitlab_pipelines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gitlab_pipelines_id_seq OWNED BY public.gitlab_pipelines.id;


--
-- Name: gitlab_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gitlab_users (
    id bigint NOT NULL,
    gitlab_id bigint NOT NULL,
    gitlab_name character varying NOT NULL,
    gitlab_username character varying NOT NULL,
    gitlab_email character varying NOT NULL,
    gitlab_avatar_url character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: gitlab_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gitlab_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gitlab_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gitlab_users_id_seq OWNED BY public.gitlab_users.id;


--
-- Name: good_job_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_batches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    description text,
    serialized_properties jsonb,
    on_finish text,
    on_success text,
    on_discard text,
    callback_queue_name text,
    callback_priority integer,
    enqueued_at timestamp(6) with time zone,
    discarded_at timestamp(6) with time zone,
    finished_at timestamp(6) with time zone
);


--
-- Name: good_job_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_executions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    active_job_id uuid NOT NULL,
    job_class text,
    queue_name text,
    serialized_params jsonb,
    scheduled_at timestamp(6) with time zone,
    finished_at timestamp(6) with time zone,
    error text,
    error_event smallint,
    error_backtrace text[],
    process_id uuid,
    duration interval
);


--
-- Name: good_job_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_processes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    state jsonb,
    lock_type smallint
);


--
-- Name: good_job_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_job_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    key text,
    value jsonb
);


--
-- Name: good_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.good_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    queue_name text,
    priority integer,
    serialized_params jsonb,
    scheduled_at timestamp(6) with time zone,
    performed_at timestamp(6) with time zone,
    finished_at timestamp(6) with time zone,
    error text,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    active_job_id uuid,
    concurrency_key text,
    cron_key text,
    retried_good_job_id uuid,
    cron_at timestamp(6) with time zone,
    batch_id uuid,
    batch_callback_id uuid,
    is_discrete boolean,
    executions_count integer,
    job_class text,
    error_event smallint,
    labels text[],
    locked_by_id uuid,
    locked_at timestamp(6) with time zone
);


--
-- Name: grid_widgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grid_widgets (
    id bigint NOT NULL,
    start_row integer NOT NULL,
    end_row integer NOT NULL,
    start_column integer NOT NULL,
    end_column integer NOT NULL,
    identifier character varying,
    options text,
    grid_id bigint
);


--
-- Name: grid_widgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grid_widgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grid_widgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grid_widgets_id_seq OWNED BY public.grid_widgets.id;


--
-- Name: grids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grids (
    id bigint NOT NULL,
    row_count integer NOT NULL,
    column_count integer NOT NULL,
    type character varying,
    user_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint,
    name text,
    options text
);


--
-- Name: grids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grids_id_seq OWNED BY public.grids.id;


--
-- Name: group_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_users (
    group_id bigint NOT NULL,
    user_id bigint NOT NULL,
    id bigint NOT NULL
);


--
-- Name: group_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_users_id_seq OWNED BY public.group_users.id;


--
-- Name: hierarchical_item_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hierarchical_item_hierarchies (
    ancestor_id integer NOT NULL,
    descendant_id integer NOT NULL,
    generations integer NOT NULL
);


--
-- Name: hierarchical_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hierarchical_items (
    id bigint NOT NULL,
    parent_id integer,
    sort_order integer,
    label character varying,
    short character varying,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    custom_field_id bigint,
    position_cache bigint
);


--
-- Name: hierarchical_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hierarchical_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hierarchical_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hierarchical_items_id_seq OWNED BY public.hierarchical_items.id;


--
-- Name: ical_token_query_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ical_token_query_assignments (
    id bigint NOT NULL,
    ical_token_id bigint,
    query_id bigint,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    name character varying NOT NULL
);


--
-- Name: ical_token_query_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ical_token_query_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ical_token_query_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ical_token_query_assignments_id_seq OWNED BY public.ical_token_query_assignments.id;


--
-- Name: ifc_models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ifc_models (
    id bigint NOT NULL,
    title character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint,
    uploader_id bigint,
    is_default boolean DEFAULT false NOT NULL,
    conversion_status integer DEFAULT 0,
    conversion_error_message text
);


--
-- Name: ifc_models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ifc_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ifc_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ifc_models_id_seq OWNED BY public.ifc_models.id;


--
-- Name: job_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_statuses (
    id bigint NOT NULL,
    reference_type character varying,
    reference_id bigint,
    message character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status character varying DEFAULT 'in_queue'::character varying,
    user_id bigint,
    job_id character varying,
    payload jsonb,
    CONSTRAINT delayed_job_statuses_status_check CHECK (((status IS NULL) OR ((status)::text = ANY ((ARRAY['in_queue'::character varying, 'error'::character varying, 'in_process'::character varying, 'success'::character varying, 'failure'::character varying, 'cancelled'::character varying])::text[]))))
);


--
-- Name: job_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_statuses_id_seq OWNED BY public.job_statuses.id;


--
-- Name: journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journals (
    id bigint NOT NULL,
    journable_type character varying,
    journable_id bigint,
    user_id bigint NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    data_type character varying NOT NULL,
    data_id bigint NOT NULL,
    cause jsonb DEFAULT '{}'::jsonb,
    validity_period tstzrange,
    CONSTRAINT journals_validity_period_not_empty CHECK (((NOT isempty(validity_period)) AND (validity_period IS NOT NULL)))
);


--
-- Name: journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journals_id_seq OWNED BY public.journals.id;


--
-- Name: labor_budget_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.labor_budget_items (
    id bigint NOT NULL,
    budget_id bigint NOT NULL,
    hours double precision NOT NULL,
    user_id bigint,
    comments character varying DEFAULT ''::character varying NOT NULL,
    amount numeric(15,4)
);


--
-- Name: labor_budget_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.labor_budget_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labor_budget_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.labor_budget_items_id_seq OWNED BY public.labor_budget_items.id;


--
-- Name: last_project_folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.last_project_folders (
    id bigint NOT NULL,
    project_storage_id bigint NOT NULL,
    origin_folder_id character varying,
    mode character varying DEFAULT 'inactive'::character varying NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    CONSTRAINT last_project_folders_mode_check CHECK (((mode)::text = ANY ((ARRAY['inactive'::character varying, 'manual'::character varying, 'automatic'::character varying])::text[])))
);


--
-- Name: TABLE last_project_folders; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.last_project_folders IS 'This table contains the last used project folder IDs for a project storage per mode.';


--
-- Name: last_project_folders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.last_project_folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: last_project_folders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.last_project_folders_id_seq OWNED BY public.last_project_folders.id;


--
-- Name: ldap_auth_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ldap_auth_sources (
    id bigint NOT NULL,
    name character varying(60) DEFAULT ''::character varying NOT NULL,
    host character varying(60),
    port integer,
    account character varying,
    account_password character varying DEFAULT ''::character varying,
    base_dn character varying,
    attr_login character varying(30),
    attr_firstname character varying(30),
    attr_lastname character varying(30),
    attr_mail character varying(30),
    onthefly_register boolean DEFAULT false NOT NULL,
    attr_admin character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    tls_mode integer DEFAULT 0 NOT NULL,
    filter_string text,
    verify_peer boolean DEFAULT true NOT NULL,
    tls_certificate_string text
);


--
-- Name: ldap_auth_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ldap_auth_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ldap_auth_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ldap_auth_sources_id_seq OWNED BY public.ldap_auth_sources.id;


--
-- Name: ldap_groups_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ldap_groups_memberships (
    id bigint NOT NULL,
    user_id bigint,
    group_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ldap_groups_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ldap_groups_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ldap_groups_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ldap_groups_memberships_id_seq OWNED BY public.ldap_groups_memberships.id;


--
-- Name: ldap_groups_synchronized_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ldap_groups_synchronized_filters (
    id bigint NOT NULL,
    name character varying,
    group_name_attribute character varying,
    filter_string character varying,
    ldap_auth_source_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    base_dn text,
    sync_users boolean DEFAULT false NOT NULL
);


--
-- Name: ldap_groups_synchronized_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ldap_groups_synchronized_filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ldap_groups_synchronized_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ldap_groups_synchronized_filters_id_seq OWNED BY public.ldap_groups_synchronized_filters.id;


--
-- Name: ldap_groups_synchronized_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ldap_groups_synchronized_groups (
    id bigint NOT NULL,
    group_id bigint,
    ldap_auth_source_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    dn text,
    users_count integer DEFAULT 0 NOT NULL,
    filter_id bigint,
    sync_users boolean DEFAULT false NOT NULL
);


--
-- Name: ldap_groups_synchronized_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ldap_groups_synchronized_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ldap_groups_synchronized_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ldap_groups_synchronized_groups_id_seq OWNED BY public.ldap_groups_synchronized_groups.id;


--
-- Name: material_budget_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.material_budget_items (
    id bigint NOT NULL,
    budget_id bigint NOT NULL,
    units double precision NOT NULL,
    cost_type_id bigint,
    comments character varying DEFAULT ''::character varying NOT NULL,
    amount numeric(15,4)
);


--
-- Name: material_budget_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.material_budget_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: material_budget_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.material_budget_items_id_seq OWNED BY public.material_budget_items.id;


--
-- Name: meeting_agenda_item_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_agenda_item_journals (
    id bigint NOT NULL,
    journal_id integer,
    agenda_item_id integer,
    author_id integer,
    title character varying,
    notes text,
    "position" integer,
    duration_in_minutes integer,
    start_time timestamp(6) with time zone,
    end_time timestamp(6) with time zone,
    work_package_id integer,
    item_type smallint,
    presenter_id bigint
);


--
-- Name: meeting_agenda_item_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_agenda_item_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_agenda_item_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_agenda_item_journals_id_seq OWNED BY public.meeting_agenda_item_journals.id;


--
-- Name: meeting_agenda_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_agenda_items (
    id bigint NOT NULL,
    meeting_id bigint,
    author_id bigint,
    title character varying,
    notes text,
    "position" integer,
    duration_in_minutes integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    work_package_id bigint,
    item_type smallint DEFAULT 0,
    lock_version integer DEFAULT 0 NOT NULL,
    presenter_id bigint,
    meeting_section_id bigint
);


--
-- Name: meeting_agenda_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_agenda_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_agenda_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_agenda_items_id_seq OWNED BY public.meeting_agenda_items.id;


--
-- Name: meeting_content_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_content_journals (
    id bigint NOT NULL,
    meeting_id bigint,
    author_id bigint,
    text text,
    locked boolean
);


--
-- Name: meeting_content_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_content_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_content_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_content_journals_id_seq OWNED BY public.meeting_content_journals.id;


--
-- Name: meeting_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_contents (
    id bigint NOT NULL,
    type character varying,
    meeting_id bigint,
    author_id bigint,
    text text,
    lock_version integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    locked boolean DEFAULT false
);


--
-- Name: meeting_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_contents_id_seq OWNED BY public.meeting_contents.id;


--
-- Name: meeting_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_journals (
    id bigint NOT NULL,
    title character varying,
    author_id bigint,
    project_id bigint,
    location character varying,
    start_time timestamp with time zone,
    duration double precision,
    state integer DEFAULT 0 NOT NULL
);


--
-- Name: meeting_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_journals_id_seq OWNED BY public.meeting_journals.id;


--
-- Name: meeting_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_participants (
    id bigint NOT NULL,
    user_id bigint,
    meeting_id bigint,
    email character varying,
    name character varying,
    invited boolean,
    attended boolean,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: meeting_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_participants_id_seq OWNED BY public.meeting_participants.id;


--
-- Name: meeting_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_sections (
    id bigint NOT NULL,
    "position" integer,
    title character varying,
    meeting_id bigint NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: meeting_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_sections_id_seq OWNED BY public.meeting_sections.id;


--
-- Name: meetings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meetings (
    id bigint NOT NULL,
    title character varying,
    author_id bigint,
    project_id bigint,
    location character varying,
    start_time timestamp with time zone,
    duration double precision,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    type character varying DEFAULT 'Meeting'::character varying NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    recurring_meeting_id bigint,
    template boolean DEFAULT false NOT NULL
);


--
-- Name: meetings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meetings_id_seq OWNED BY public.meetings.id;


--
-- Name: member_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.member_roles (
    id bigint NOT NULL,
    member_id bigint NOT NULL,
    role_id bigint NOT NULL,
    inherited_from bigint
);


--
-- Name: member_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.member_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: member_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.member_roles_id_seq OWNED BY public.member_roles.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    project_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    entity_type character varying,
    entity_id bigint
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.members_id_seq OWNED BY public.members.id;


--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_items (
    id bigint NOT NULL,
    name character varying,
    title character varying,
    parent_id bigint,
    options text,
    navigatable_id bigint,
    type character varying
);


--
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menu_items_id_seq OWNED BY public.menu_items.id;


--
-- Name: message_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_journals (
    id bigint NOT NULL,
    forum_id bigint NOT NULL,
    parent_id bigint,
    subject character varying NOT NULL,
    content text,
    author_id bigint,
    locked boolean,
    sticky integer
);


--
-- Name: message_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_journals_id_seq OWNED BY public.message_journals.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id bigint NOT NULL,
    forum_id bigint NOT NULL,
    parent_id bigint,
    subject character varying DEFAULT ''::character varying NOT NULL,
    content text,
    author_id bigint,
    replies_count integer DEFAULT 0 NOT NULL,
    last_reply_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    locked boolean DEFAULT false,
    sticky integer DEFAULT 0,
    sticked_on timestamp with time zone
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news (
    id bigint NOT NULL,
    project_id bigint,
    title character varying DEFAULT ''::character varying NOT NULL,
    summary character varying DEFAULT ''::character varying,
    description text,
    author_id bigint NOT NULL,
    created_at timestamp with time zone,
    comments_count integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_id_seq OWNED BY public.news.id;


--
-- Name: news_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_journals (
    id bigint NOT NULL,
    project_id bigint,
    title character varying NOT NULL,
    summary character varying,
    description text,
    author_id bigint NOT NULL,
    comments_count integer NOT NULL
);


--
-- Name: news_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_journals_id_seq OWNED BY public.news_journals.id;


--
-- Name: non_working_days; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_working_days (
    id bigint NOT NULL,
    name character varying NOT NULL,
    date date NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: non_working_days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_working_days_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_working_days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.non_working_days_id_seq OWNED BY public.non_working_days.id;


--
-- Name: notification_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_settings (
    id bigint NOT NULL,
    project_id bigint,
    user_id bigint NOT NULL,
    watched boolean DEFAULT true,
    mentioned boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    work_package_commented boolean DEFAULT false,
    work_package_created boolean DEFAULT false,
    work_package_processed boolean DEFAULT false,
    work_package_prioritized boolean DEFAULT false,
    work_package_scheduled boolean DEFAULT false,
    news_added boolean DEFAULT false,
    news_commented boolean DEFAULT false,
    document_added boolean DEFAULT false,
    forum_messages boolean DEFAULT false,
    wiki_page_added boolean DEFAULT false,
    wiki_page_updated boolean DEFAULT false,
    membership_added boolean DEFAULT false,
    membership_updated boolean DEFAULT false,
    start_date integer DEFAULT 1,
    due_date integer DEFAULT 1,
    overdue integer,
    assignee boolean DEFAULT true NOT NULL,
    responsible boolean DEFAULT true NOT NULL,
    shared boolean DEFAULT true NOT NULL
);


--
-- Name: notification_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_settings_id_seq OWNED BY public.notification_settings.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    subject text,
    read_ian boolean DEFAULT false,
    reason smallint,
    recipient_id bigint NOT NULL,
    actor_id bigint,
    resource_type character varying NOT NULL,
    resource_id bigint NOT NULL,
    journal_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    mail_reminder_sent boolean DEFAULT false,
    mail_alert_sent boolean
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    scopes character varying,
    code_challenge character varying,
    code_challenge_method character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    owner_type character varying,
    owner_id bigint,
    client_credentials_user_id bigint,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    integration_type character varying,
    integration_id bigint,
    enabled boolean DEFAULT true NOT NULL,
    builtin boolean DEFAULT false NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: oauth_client_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_client_tokens (
    id bigint NOT NULL,
    oauth_client_id bigint NOT NULL,
    user_id bigint NOT NULL,
    access_token character varying,
    refresh_token character varying,
    token_type character varying,
    expires_in integer,
    scope character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL
);


--
-- Name: oauth_client_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_client_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_client_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_client_tokens_id_seq OWNED BY public.oauth_client_tokens.id;


--
-- Name: oauth_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_clients (
    id bigint NOT NULL,
    client_id character varying NOT NULL,
    client_secret character varying,
    integration_type character varying NOT NULL,
    integration_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: oauth_clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_clients_id_seq OWNED BY public.oauth_clients.id;


--
-- Name: oidc_user_session_links; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oidc_user_session_links (
    id bigint NOT NULL,
    oidc_session character varying NOT NULL,
    session_id bigint,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: oidc_user_session_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oidc_user_session_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oidc_user_session_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oidc_user_session_links_id_seq OWNED BY public.oidc_user_session_links.id;


--
-- Name: oidc_user_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oidc_user_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    access_token character varying NOT NULL,
    refresh_token character varying,
    audiences jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: oidc_user_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oidc_user_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oidc_user_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oidc_user_tokens_id_seq OWNED BY public.oidc_user_tokens.id;


--
-- Name: ordered_work_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ordered_work_packages (
    id bigint NOT NULL,
    "position" integer NOT NULL,
    query_id bigint,
    work_package_id bigint
);


--
-- Name: ordered_work_packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ordered_work_packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ordered_work_packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ordered_work_packages_id_seq OWNED BY public.ordered_work_packages.id;


--
-- Name: paper_trail_audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paper_trail_audits (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    stack text,
    object jsonb,
    object_changes jsonb,
    created_at timestamp(6) with time zone
);


--
-- Name: paper_trail_audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.paper_trail_audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paper_trail_audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.paper_trail_audits_id_seq OWNED BY public.paper_trail_audits.id;


--
-- Name: project_custom_field_project_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_custom_field_project_mappings (
    id bigint NOT NULL,
    custom_field_id bigint,
    project_id bigint,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: project_custom_field_project_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_custom_field_project_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_custom_field_project_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_custom_field_project_mappings_id_seq OWNED BY public.project_custom_field_project_mappings.id;


--
-- Name: project_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_journals (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description text,
    public boolean NOT NULL,
    parent_id bigint,
    identifier character varying NOT NULL,
    active boolean NOT NULL,
    templated boolean NOT NULL,
    status_code integer,
    status_explanation text
);


--
-- Name: project_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_journals_id_seq OWNED BY public.project_journals.id;


--
-- Name: project_life_cycle_step_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_life_cycle_step_definitions (
    id bigint NOT NULL,
    type character varying,
    name character varying,
    "position" integer,
    color_id bigint,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: project_life_cycle_step_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_life_cycle_step_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_life_cycle_step_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_life_cycle_step_definitions_id_seq OWNED BY public.project_life_cycle_step_definitions.id;


--
-- Name: project_life_cycle_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_life_cycle_steps (
    id bigint NOT NULL,
    type character varying,
    start_date date,
    end_date date,
    active boolean DEFAULT false NOT NULL,
    project_id bigint,
    definition_id bigint,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: project_life_cycle_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_life_cycle_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_life_cycle_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_life_cycle_steps_id_seq OWNED BY public.project_life_cycle_steps.id;


--
-- Name: project_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_queries (
    id bigint NOT NULL,
    name character varying NOT NULL,
    user_id bigint NOT NULL,
    filters json DEFAULT '[]'::json,
    selects json DEFAULT '[]'::json,
    orders json DEFAULT '[]'::json,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    public boolean DEFAULT false NOT NULL
);


--
-- Name: project_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_queries_id_seq OWNED BY public.project_queries.id;


--
-- Name: project_storages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_storages (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    storage_id bigint NOT NULL,
    creator_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_folder_id character varying,
    project_folder_mode character varying NOT NULL,
    CONSTRAINT project_storages_project_folder_mode_check CHECK (((project_folder_mode)::text = ANY ((ARRAY['inactive'::character varying, 'manual'::character varying, 'automatic'::character varying])::text[])))
);


--
-- Name: project_storages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_storages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_storages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.project_storages_id_seq OWNED BY public.project_storages.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    description text,
    public boolean DEFAULT true NOT NULL,
    parent_id bigint,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    identifier character varying NOT NULL,
    lft integer,
    rgt integer,
    active boolean DEFAULT true NOT NULL,
    templated boolean DEFAULT false NOT NULL,
    status_code integer,
    status_explanation text,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: projects_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_types (
    project_id bigint NOT NULL,
    type_id bigint NOT NULL
);


--
-- Name: queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.queries (
    id bigint NOT NULL,
    project_id bigint,
    name character varying NOT NULL,
    filters text,
    user_id bigint NOT NULL,
    public boolean DEFAULT false NOT NULL,
    column_names text,
    sort_criteria text,
    group_by character varying,
    display_sums boolean DEFAULT false NOT NULL,
    timeline_visible boolean DEFAULT false,
    show_hierarchies boolean DEFAULT false,
    timeline_zoom_level integer DEFAULT 5,
    timeline_labels text,
    highlighting_mode text,
    highlighted_attributes text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    display_representation text,
    starred boolean DEFAULT false,
    include_subprojects boolean NOT NULL,
    timestamps character varying
);


--
-- Name: queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.queries_id_seq OWNED BY public.queries.id;


--
-- Name: rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rates (
    id bigint NOT NULL,
    valid_from date NOT NULL,
    rate numeric(15,4) NOT NULL,
    type character varying NOT NULL,
    project_id bigint,
    user_id bigint,
    cost_type_id bigint
);


--
-- Name: rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rates_id_seq OWNED BY public.rates.id;


--
-- Name: recaptcha_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recaptcha_entries (
    id integer NOT NULL,
    user_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version integer NOT NULL
);


--
-- Name: recaptcha_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recaptcha_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recaptcha_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recaptcha_entries_id_seq OWNED BY public.recaptcha_entries.id;


--
-- Name: recurring_meetings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurring_meetings (
    id bigint NOT NULL,
    start_time timestamp(6) with time zone,
    end_date date,
    title text,
    frequency integer DEFAULT 0 NOT NULL,
    end_after integer DEFAULT 0 NOT NULL,
    iterations integer,
    project_id bigint,
    author_id bigint,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    "interval" integer DEFAULT 1 NOT NULL
);


--
-- Name: recurring_meetings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurring_meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurring_meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurring_meetings_id_seq OWNED BY public.recurring_meetings.id;


--
-- Name: relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relations (
    id bigint NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    lag integer,
    description text,
    relation_type character varying
);


--
-- Name: relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relations_id_seq OWNED BY public.relations.id;


--
-- Name: reminder_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reminder_notifications (
    id bigint NOT NULL,
    reminder_id bigint,
    notification_id bigint,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: reminder_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reminder_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminder_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reminder_notifications_id_seq OWNED BY public.reminder_notifications.id;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reminders (
    id bigint NOT NULL,
    remindable_type character varying NOT NULL,
    remindable_id bigint NOT NULL,
    creator_id bigint NOT NULL,
    remind_at timestamp(6) with time zone NOT NULL,
    completed_at timestamp(6) with time zone,
    job_id character varying,
    note text,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reminders_id_seq OWNED BY public.reminders.id;


--
-- Name: remote_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remote_identities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    oauth_client_id bigint NOT NULL,
    origin_user_id character varying NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: remote_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.remote_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: remote_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.remote_identities_id_seq OWNED BY public.remote_identities.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    url character varying DEFAULT ''::character varying NOT NULL,
    login character varying(60) DEFAULT ''::character varying,
    password character varying DEFAULT ''::character varying,
    root_url character varying DEFAULT ''::character varying,
    type character varying,
    path_encoding character varying(64),
    log_encoding character varying(64),
    scm_type character varying NOT NULL,
    required_storage_bytes bigint DEFAULT 0 NOT NULL,
    storage_updated_at timestamp with time zone
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id bigint NOT NULL,
    permission character varying,
    role_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_permissions_id_seq OWNED BY public.role_permissions.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    "position" integer DEFAULT 1,
    builtin integer DEFAULT 0 NOT NULL,
    type character varying(30) DEFAULT 'Role'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: scheduled_meetings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_meetings (
    id bigint NOT NULL,
    recurring_meeting_id bigint NOT NULL,
    meeting_id bigint,
    start_time timestamp(6) with time zone NOT NULL,
    cancelled boolean DEFAULT false NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);


--
-- Name: scheduled_meetings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scheduled_meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scheduled_meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scheduled_meetings_id_seq OWNED BY public.scheduled_meetings.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.sessions (
    id bigint NOT NULL,
    session_id character varying NOT NULL,
    data text,
    updated_at timestamp with time zone,
    user_id bigint
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    value text,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statuses (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    is_closed boolean DEFAULT false NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    "position" integer DEFAULT 1,
    default_done_ratio integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    color_id bigint,
    is_readonly boolean DEFAULT false,
    excluded_from_totals boolean DEFAULT false NOT NULL
);


--
-- Name: statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.statuses_id_seq OWNED BY public.statuses.id;


--
-- Name: storages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storages (
    id bigint NOT NULL,
    provider_type character varying NOT NULL,
    name character varying NOT NULL,
    host character varying,
    creator_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    provider_fields jsonb DEFAULT '{}'::jsonb NOT NULL,
    health_status character varying DEFAULT 'pending'::character varying NOT NULL,
    health_changed_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    health_reason character varying,
    health_checked_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT storages_health_status_check CHECK (((health_status)::text = ANY ((ARRAY['pending'::character varying, 'healthy'::character varying, 'unhealthy'::character varying])::text[])))
);


--
-- Name: storages_file_links_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storages_file_links_journals (
    id bigint NOT NULL,
    journal_id bigint NOT NULL,
    file_link_id bigint NOT NULL,
    link_name character varying NOT NULL,
    storage_name character varying
);


--
-- Name: storages_file_links_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.storages_file_links_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: storages_file_links_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.storages_file_links_journals_id_seq OWNED BY public.storages_file_links_journals.id;


--
-- Name: storages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.storages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: storages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.storages_id_seq OWNED BY public.storages.id;


--
-- Name: time_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_entries (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    work_package_id bigint,
    hours double precision,
    comments character varying,
    activity_id bigint,
    spent_on date NOT NULL,
    tyear integer NOT NULL,
    tmonth integer NOT NULL,
    tweek integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    overridden_costs numeric(15,4),
    costs numeric(15,4),
    rate_id bigint,
    logged_by_id bigint NOT NULL,
    ongoing boolean DEFAULT false NOT NULL,
    start_time integer,
    time_zone character varying
);


--
-- Name: time_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.time_entries_id_seq OWNED BY public.time_entries.id;


--
-- Name: time_entry_activities_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_entry_activities_projects (
    id bigint NOT NULL,
    activity_id bigint NOT NULL,
    project_id bigint NOT NULL,
    active boolean DEFAULT true
);


--
-- Name: time_entry_activities_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_entry_activities_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_entry_activities_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.time_entry_activities_projects_id_seq OWNED BY public.time_entry_activities_projects.id;


--
-- Name: time_entry_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_entry_journals (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    work_package_id bigint,
    hours double precision,
    comments character varying,
    activity_id bigint,
    spent_on date NOT NULL,
    tyear integer NOT NULL,
    tmonth integer NOT NULL,
    tweek integer NOT NULL,
    overridden_costs numeric(15,2),
    costs numeric(15,2),
    rate_id bigint,
    logged_by_id bigint NOT NULL,
    start_time integer,
    time_zone character varying
);


--
-- Name: time_entry_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_entry_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_entry_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.time_entry_journals_id_seq OWNED BY public.time_entry_journals.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    id bigint NOT NULL,
    user_id bigint,
    type character varying,
    value character varying(128) DEFAULT ''::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_on timestamp with time zone,
    data json
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: two_factor_authentication_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.two_factor_authentication_devices (
    id bigint NOT NULL,
    type character varying,
    "default" boolean DEFAULT false NOT NULL,
    active boolean DEFAULT false NOT NULL,
    channel character varying NOT NULL,
    phone_number character varying,
    identifier character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    last_used_at integer,
    otp_secret text,
    user_id bigint,
    webauthn_external_id character varying,
    webauthn_public_key character varying,
    webauthn_sign_count bigint DEFAULT 0 NOT NULL
);


--
-- Name: two_factor_authentication_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.two_factor_authentication_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: two_factor_authentication_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.two_factor_authentication_devices_id_seq OWNED BY public.two_factor_authentication_devices.id;


--
-- Name: types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.types (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    "position" integer DEFAULT 1,
    is_in_roadmap boolean DEFAULT true NOT NULL,
    is_milestone boolean DEFAULT false NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    color_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    is_standard boolean DEFAULT false NOT NULL,
    attribute_groups text,
    description text,
    patterns text
);


--
-- Name: types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.types_id_seq OWNED BY public.types.id;


--
-- Name: user_passwords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_passwords (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    hashed_password character varying(128) NOT NULL,
    salt character varying(64),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    type character varying NOT NULL
);


--
-- Name: user_passwords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_passwords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_passwords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_passwords_id_seq OWNED BY public.user_passwords.id;


--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_preferences (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) with time zone DEFAULT '2025-02-12 15:21:49.159525+08'::timestamp with time zone NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT '2025-02-12 15:21:49.159525+08'::timestamp with time zone NOT NULL
);


--
-- Name: user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_preferences_id_seq OWNED BY public.user_preferences.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    login character varying(256) DEFAULT ''::character varying NOT NULL,
    firstname character varying DEFAULT ''::character varying NOT NULL,
    lastname character varying DEFAULT ''::character varying NOT NULL,
    mail character varying DEFAULT ''::character varying NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    last_login_on timestamp with time zone,
    language character varying(5) DEFAULT ''::character varying,
    ldap_auth_source_id bigint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    type character varying,
    identity_url character varying,
    first_login boolean DEFAULT true NOT NULL,
    force_password_change boolean DEFAULT false,
    failed_login_count integer DEFAULT 0,
    last_failed_login_on timestamp with time zone,
    consented_at timestamp with time zone,
    webauthn_id character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: version_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_settings (
    id bigint NOT NULL,
    project_id bigint,
    version_id bigint,
    display integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: version_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.version_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.version_settings_id_seq OWNED BY public.version_settings.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL COLLATE public.versions_name,
    description character varying DEFAULT ''::character varying,
    effective_date date,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    wiki_page_title character varying,
    status character varying DEFAULT 'open'::character varying,
    sharing character varying DEFAULT 'none'::character varying NOT NULL,
    start_date date
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.views (
    id bigint NOT NULL,
    query_id bigint NOT NULL,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    type character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.views_id_seq OWNED BY public.views.id;


--
-- Name: watchers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.watchers (
    id bigint NOT NULL,
    watchable_type character varying DEFAULT ''::character varying NOT NULL,
    watchable_id bigint NOT NULL,
    user_id bigint
);


--
-- Name: watchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.watchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: watchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.watchers_id_seq OWNED BY public.watchers.id;


--
-- Name: webhooks_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks_events (
    id bigint NOT NULL,
    name character varying,
    webhooks_webhook_id bigint
);


--
-- Name: webhooks_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_events_id_seq OWNED BY public.webhooks_events.id;


--
-- Name: webhooks_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks_logs (
    id bigint NOT NULL,
    webhooks_webhook_id bigint,
    event_name character varying,
    url character varying,
    request_headers text,
    request_body text,
    response_code integer,
    response_headers text,
    response_body text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: webhooks_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_logs_id_seq OWNED BY public.webhooks_logs.id;


--
-- Name: webhooks_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks_projects (
    id bigint NOT NULL,
    project_id bigint,
    webhooks_webhook_id bigint
);


--
-- Name: webhooks_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_projects_id_seq OWNED BY public.webhooks_projects.id;


--
-- Name: webhooks_webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks_webhooks (
    id bigint NOT NULL,
    name character varying,
    url text,
    description text NOT NULL,
    secret character varying,
    enabled boolean NOT NULL,
    all_projects boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: webhooks_webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_webhooks_id_seq OWNED BY public.webhooks_webhooks.id;


--
-- Name: wiki_page_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_page_journals (
    id bigint NOT NULL,
    author_id bigint,
    text text
);


--
-- Name: wiki_page_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_page_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_page_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_page_journals_id_seq OWNED BY public.wiki_page_journals.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_pages (
    id bigint NOT NULL,
    wiki_id bigint NOT NULL,
    title character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    parent_id bigint,
    slug character varying NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    author_id bigint NOT NULL,
    text text,
    lock_version integer NOT NULL
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_pages_id_seq OWNED BY public.wiki_pages.id;


--
-- Name: wiki_redirects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_redirects (
    id bigint NOT NULL,
    wiki_id bigint NOT NULL,
    title character varying,
    redirects_to character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: wiki_redirects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_redirects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_redirects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_redirects_id_seq OWNED BY public.wiki_redirects.id;


--
-- Name: wikis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wikis (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    start_page character varying NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: wikis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wikis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wikis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wikis_id_seq OWNED BY public.wikis.id;


--
-- Name: work_package_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_package_hierarchies (
    ancestor_id integer NOT NULL,
    descendant_id integer NOT NULL,
    generations integer NOT NULL
);


--
-- Name: work_package_journals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_package_journals (
    id bigint NOT NULL,
    type_id bigint NOT NULL,
    project_id bigint NOT NULL,
    subject character varying NOT NULL,
    description text,
    due_date date,
    category_id bigint,
    status_id bigint NOT NULL,
    assigned_to_id bigint,
    priority_id bigint NOT NULL,
    version_id bigint,
    author_id bigint NOT NULL,
    done_ratio integer,
    estimated_hours double precision,
    start_date date,
    parent_id bigint,
    responsible_id bigint,
    budget_id bigint,
    story_points integer,
    remaining_hours double precision,
    derived_estimated_hours double precision,
    schedule_manually boolean,
    duration integer,
    ignore_non_working_days boolean NOT NULL,
    derived_remaining_hours double precision,
    derived_done_ratio integer
);


--
-- Name: work_package_journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_package_journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_package_journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_package_journals_id_seq OWNED BY public.work_package_journals.id;


--
-- Name: work_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_packages (
    id bigint NOT NULL,
    type_id bigint NOT NULL,
    project_id bigint NOT NULL,
    subject character varying DEFAULT ''::character varying NOT NULL,
    description text,
    due_date date,
    category_id bigint,
    status_id bigint NOT NULL,
    assigned_to_id bigint,
    priority_id bigint,
    version_id bigint,
    author_id bigint NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    done_ratio integer,
    estimated_hours double precision,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    start_date date,
    responsible_id bigint,
    budget_id bigint,
    "position" integer,
    story_points integer,
    remaining_hours double precision,
    derived_estimated_hours double precision,
    schedule_manually boolean DEFAULT false,
    parent_id bigint,
    duration integer,
    ignore_non_working_days boolean DEFAULT false NOT NULL,
    derived_remaining_hours double precision,
    derived_done_ratio integer,
    project_life_cycle_step_id bigint,
    CONSTRAINT work_packages_due_larger_start_date CHECK ((due_date >= start_date))
);


--
-- Name: work_packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_packages_id_seq OWNED BY public.work_packages.id;


--
-- Name: workflows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflows (
    id bigint NOT NULL,
    type_id bigint NOT NULL,
    old_status_id bigint NOT NULL,
    new_status_id bigint NOT NULL,
    role_id bigint NOT NULL,
    assignee boolean DEFAULT false NOT NULL,
    author boolean DEFAULT false NOT NULL
);


--
-- Name: workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflows_id_seq OWNED BY public.workflows.id;


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: attachable_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachable_journals ALTER COLUMN id SET DEFAULT nextval('public.attachable_journals_id_seq'::regclass);


--
-- Name: attachment_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachment_journals ALTER COLUMN id SET DEFAULT nextval('public.attachment_journals_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: attribute_help_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_help_texts ALTER COLUMN id SET DEFAULT nextval('public.attribute_help_texts_id_seq'::regclass);


--
-- Name: auth_providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_providers ALTER COLUMN id SET DEFAULT nextval('public.auth_providers_id_seq'::regclass);


--
-- Name: bcf_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_comments ALTER COLUMN id SET DEFAULT nextval('public.bcf_comments_id_seq'::regclass);


--
-- Name: bcf_issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_issues ALTER COLUMN id SET DEFAULT nextval('public.bcf_issues_id_seq'::regclass);


--
-- Name: bcf_viewpoints id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_viewpoints ALTER COLUMN id SET DEFAULT nextval('public.bcf_viewpoints_id_seq'::regclass);


--
-- Name: budget_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_journals ALTER COLUMN id SET DEFAULT nextval('public.budget_journals_id_seq'::regclass);


--
-- Name: budgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets ALTER COLUMN id SET DEFAULT nextval('public.budgets_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: changes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes ALTER COLUMN id SET DEFAULT nextval('public.changes_id_seq'::regclass);


--
-- Name: changeset_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changeset_journals ALTER COLUMN id SET DEFAULT nextval('public.changeset_journals_id_seq'::regclass);


--
-- Name: changesets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changesets ALTER COLUMN id SET DEFAULT nextval('public.changesets_id_seq'::regclass);


--
-- Name: colors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.colors ALTER COLUMN id SET DEFAULT nextval('public.colors_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: cost_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_entries ALTER COLUMN id SET DEFAULT nextval('public.cost_entries_id_seq'::regclass);


--
-- Name: cost_queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_queries ALTER COLUMN id SET DEFAULT nextval('public.cost_queries_id_seq'::regclass);


--
-- Name: cost_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_types ALTER COLUMN id SET DEFAULT nextval('public.cost_types_id_seq'::regclass);


--
-- Name: custom_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions ALTER COLUMN id SET DEFAULT nextval('public.custom_actions_id_seq'::regclass);


--
-- Name: custom_actions_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_projects ALTER COLUMN id SET DEFAULT nextval('public.custom_actions_projects_id_seq'::regclass);


--
-- Name: custom_actions_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_roles ALTER COLUMN id SET DEFAULT nextval('public.custom_actions_roles_id_seq'::regclass);


--
-- Name: custom_actions_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_statuses ALTER COLUMN id SET DEFAULT nextval('public.custom_actions_statuses_id_seq'::regclass);


--
-- Name: custom_actions_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_types ALTER COLUMN id SET DEFAULT nextval('public.custom_actions_types_id_seq'::regclass);


--
-- Name: custom_field_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_sections ALTER COLUMN id SET DEFAULT nextval('public.custom_field_sections_id_seq'::regclass);


--
-- Name: custom_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields ALTER COLUMN id SET DEFAULT nextval('public.custom_fields_id_seq'::regclass);


--
-- Name: custom_fields_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields_projects ALTER COLUMN id SET DEFAULT nextval('public.custom_fields_projects_id_seq'::regclass);


--
-- Name: custom_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_options ALTER COLUMN id SET DEFAULT nextval('public.custom_options_id_seq'::regclass);


--
-- Name: custom_styles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_styles ALTER COLUMN id SET DEFAULT nextval('public.custom_styles_id_seq'::regclass);


--
-- Name: custom_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_values ALTER COLUMN id SET DEFAULT nextval('public.custom_values_id_seq'::regclass);


--
-- Name: customizable_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customizable_journals ALTER COLUMN id SET DEFAULT nextval('public.customizable_journals_id_seq'::regclass);


--
-- Name: deploy_status_checks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploy_status_checks ALTER COLUMN id SET DEFAULT nextval('public.deploy_status_checks_id_seq'::regclass);


--
-- Name: deploy_targets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploy_targets ALTER COLUMN id SET DEFAULT nextval('public.deploy_targets_id_seq'::regclass);


--
-- Name: design_colors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_colors ALTER COLUMN id SET DEFAULT nextval('public.design_colors_id_seq'::regclass);


--
-- Name: document_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_journals ALTER COLUMN id SET DEFAULT nextval('public.document_journals_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: emoji_reactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emoji_reactions ALTER COLUMN id SET DEFAULT nextval('public.emoji_reactions_id_seq'::regclass);


--
-- Name: enabled_modules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enabled_modules ALTER COLUMN id SET DEFAULT nextval('public.enabled_modules_id_seq'::regclass);


--
-- Name: enterprise_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enterprise_tokens ALTER COLUMN id SET DEFAULT nextval('public.enterprise_tokens_id_seq'::regclass);


--
-- Name: enumerations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enumerations ALTER COLUMN id SET DEFAULT nextval('public.enumerations_id_seq'::regclass);


--
-- Name: exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports ALTER COLUMN id SET DEFAULT nextval('public.exports_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: file_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_links ALTER COLUMN id SET DEFAULT nextval('public.file_links_id_seq'::regclass);


--
-- Name: forums id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forums ALTER COLUMN id SET DEFAULT nextval('public.forums_id_seq'::regclass);


--
-- Name: github_check_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_check_runs ALTER COLUMN id SET DEFAULT nextval('public.github_check_runs_id_seq'::regclass);


--
-- Name: github_pull_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_pull_requests ALTER COLUMN id SET DEFAULT nextval('public.github_pull_requests_id_seq'::regclass);


--
-- Name: github_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_users ALTER COLUMN id SET DEFAULT nextval('public.github_users_id_seq'::regclass);


--
-- Name: gitlab_issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_issues ALTER COLUMN id SET DEFAULT nextval('public.gitlab_issues_id_seq'::regclass);


--
-- Name: gitlab_merge_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_merge_requests ALTER COLUMN id SET DEFAULT nextval('public.gitlab_merge_requests_id_seq'::regclass);


--
-- Name: gitlab_pipelines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_pipelines ALTER COLUMN id SET DEFAULT nextval('public.gitlab_pipelines_id_seq'::regclass);


--
-- Name: gitlab_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_users ALTER COLUMN id SET DEFAULT nextval('public.gitlab_users_id_seq'::regclass);


--
-- Name: grid_widgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grid_widgets ALTER COLUMN id SET DEFAULT nextval('public.grid_widgets_id_seq'::regclass);


--
-- Name: grids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grids ALTER COLUMN id SET DEFAULT nextval('public.grids_id_seq'::regclass);


--
-- Name: group_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users ALTER COLUMN id SET DEFAULT nextval('public.group_users_id_seq'::regclass);


--
-- Name: hierarchical_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hierarchical_items ALTER COLUMN id SET DEFAULT nextval('public.hierarchical_items_id_seq'::regclass);


--
-- Name: ical_token_query_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ical_token_query_assignments ALTER COLUMN id SET DEFAULT nextval('public.ical_token_query_assignments_id_seq'::regclass);


--
-- Name: ifc_models id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ifc_models ALTER COLUMN id SET DEFAULT nextval('public.ifc_models_id_seq'::regclass);


--
-- Name: job_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_statuses ALTER COLUMN id SET DEFAULT nextval('public.job_statuses_id_seq'::regclass);


--
-- Name: journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journals ALTER COLUMN id SET DEFAULT nextval('public.journals_id_seq'::regclass);


--
-- Name: labor_budget_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labor_budget_items ALTER COLUMN id SET DEFAULT nextval('public.labor_budget_items_id_seq'::regclass);


--
-- Name: last_project_folders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.last_project_folders ALTER COLUMN id SET DEFAULT nextval('public.last_project_folders_id_seq'::regclass);


--
-- Name: ldap_auth_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_auth_sources ALTER COLUMN id SET DEFAULT nextval('public.ldap_auth_sources_id_seq'::regclass);


--
-- Name: ldap_groups_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_groups_memberships ALTER COLUMN id SET DEFAULT nextval('public.ldap_groups_memberships_id_seq'::regclass);


--
-- Name: ldap_groups_synchronized_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_groups_synchronized_filters ALTER COLUMN id SET DEFAULT nextval('public.ldap_groups_synchronized_filters_id_seq'::regclass);


--
-- Name: ldap_groups_synchronized_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_groups_synchronized_groups ALTER COLUMN id SET DEFAULT nextval('public.ldap_groups_synchronized_groups_id_seq'::regclass);


--
-- Name: material_budget_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_budget_items ALTER COLUMN id SET DEFAULT nextval('public.material_budget_items_id_seq'::regclass);


--
-- Name: meeting_agenda_item_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_item_journals ALTER COLUMN id SET DEFAULT nextval('public.meeting_agenda_item_journals_id_seq'::regclass);


--
-- Name: meeting_agenda_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_items ALTER COLUMN id SET DEFAULT nextval('public.meeting_agenda_items_id_seq'::regclass);


--
-- Name: meeting_content_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_content_journals ALTER COLUMN id SET DEFAULT nextval('public.meeting_content_journals_id_seq'::regclass);


--
-- Name: meeting_contents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_contents ALTER COLUMN id SET DEFAULT nextval('public.meeting_contents_id_seq'::regclass);


--
-- Name: meeting_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_journals ALTER COLUMN id SET DEFAULT nextval('public.meeting_journals_id_seq'::regclass);


--
-- Name: meeting_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_participants ALTER COLUMN id SET DEFAULT nextval('public.meeting_participants_id_seq'::regclass);


--
-- Name: meeting_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_sections ALTER COLUMN id SET DEFAULT nextval('public.meeting_sections_id_seq'::regclass);


--
-- Name: meetings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meetings ALTER COLUMN id SET DEFAULT nextval('public.meetings_id_seq'::regclass);


--
-- Name: member_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_roles ALTER COLUMN id SET DEFAULT nextval('public.member_roles_id_seq'::regclass);


--
-- Name: members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members ALTER COLUMN id SET DEFAULT nextval('public.members_id_seq'::regclass);


--
-- Name: menu_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items ALTER COLUMN id SET DEFAULT nextval('public.menu_items_id_seq'::regclass);


--
-- Name: message_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_journals ALTER COLUMN id SET DEFAULT nextval('public.message_journals_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: news id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news ALTER COLUMN id SET DEFAULT nextval('public.news_id_seq'::regclass);


--
-- Name: news_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_journals ALTER COLUMN id SET DEFAULT nextval('public.news_journals_id_seq'::regclass);


--
-- Name: non_working_days id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_working_days ALTER COLUMN id SET DEFAULT nextval('public.non_working_days_id_seq'::regclass);


--
-- Name: notification_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_settings ALTER COLUMN id SET DEFAULT nextval('public.notification_settings_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: oauth_client_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_client_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_client_tokens_id_seq'::regclass);


--
-- Name: oauth_clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients ALTER COLUMN id SET DEFAULT nextval('public.oauth_clients_id_seq'::regclass);


--
-- Name: oidc_user_session_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_user_session_links ALTER COLUMN id SET DEFAULT nextval('public.oidc_user_session_links_id_seq'::regclass);


--
-- Name: oidc_user_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_user_tokens ALTER COLUMN id SET DEFAULT nextval('public.oidc_user_tokens_id_seq'::regclass);


--
-- Name: ordered_work_packages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordered_work_packages ALTER COLUMN id SET DEFAULT nextval('public.ordered_work_packages_id_seq'::regclass);


--
-- Name: paper_trail_audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_trail_audits ALTER COLUMN id SET DEFAULT nextval('public.paper_trail_audits_id_seq'::regclass);


--
-- Name: project_custom_field_project_mappings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_custom_field_project_mappings ALTER COLUMN id SET DEFAULT nextval('public.project_custom_field_project_mappings_id_seq'::regclass);


--
-- Name: project_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_journals ALTER COLUMN id SET DEFAULT nextval('public.project_journals_id_seq'::regclass);


--
-- Name: project_life_cycle_step_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_life_cycle_step_definitions ALTER COLUMN id SET DEFAULT nextval('public.project_life_cycle_step_definitions_id_seq'::regclass);


--
-- Name: project_life_cycle_steps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_life_cycle_steps ALTER COLUMN id SET DEFAULT nextval('public.project_life_cycle_steps_id_seq'::regclass);


--
-- Name: project_queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_queries ALTER COLUMN id SET DEFAULT nextval('public.project_queries_id_seq'::regclass);


--
-- Name: project_storages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_storages ALTER COLUMN id SET DEFAULT nextval('public.project_storages_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.queries ALTER COLUMN id SET DEFAULT nextval('public.queries_id_seq'::regclass);


--
-- Name: rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates ALTER COLUMN id SET DEFAULT nextval('public.rates_id_seq'::regclass);


--
-- Name: recaptcha_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recaptcha_entries ALTER COLUMN id SET DEFAULT nextval('public.recaptcha_entries_id_seq'::regclass);


--
-- Name: recurring_meetings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_meetings ALTER COLUMN id SET DEFAULT nextval('public.recurring_meetings_id_seq'::regclass);


--
-- Name: relations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relations ALTER COLUMN id SET DEFAULT nextval('public.relations_id_seq'::regclass);


--
-- Name: reminder_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminder_notifications ALTER COLUMN id SET DEFAULT nextval('public.reminder_notifications_id_seq'::regclass);


--
-- Name: reminders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders ALTER COLUMN id SET DEFAULT nextval('public.reminders_id_seq'::regclass);


--
-- Name: remote_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remote_identities ALTER COLUMN id SET DEFAULT nextval('public.remote_identities_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: role_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions ALTER COLUMN id SET DEFAULT nextval('public.role_permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: scheduled_meetings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_meetings ALTER COLUMN id SET DEFAULT nextval('public.scheduled_meetings_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statuses ALTER COLUMN id SET DEFAULT nextval('public.statuses_id_seq'::regclass);


--
-- Name: storages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages ALTER COLUMN id SET DEFAULT nextval('public.storages_id_seq'::regclass);


--
-- Name: storages_file_links_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages_file_links_journals ALTER COLUMN id SET DEFAULT nextval('public.storages_file_links_journals_id_seq'::regclass);


--
-- Name: time_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entries ALTER COLUMN id SET DEFAULT nextval('public.time_entries_id_seq'::regclass);


--
-- Name: time_entry_activities_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entry_activities_projects ALTER COLUMN id SET DEFAULT nextval('public.time_entry_activities_projects_id_seq'::regclass);


--
-- Name: time_entry_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entry_journals ALTER COLUMN id SET DEFAULT nextval('public.time_entry_journals_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: two_factor_authentication_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.two_factor_authentication_devices ALTER COLUMN id SET DEFAULT nextval('public.two_factor_authentication_devices_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.types ALTER COLUMN id SET DEFAULT nextval('public.types_id_seq'::regclass);


--
-- Name: user_passwords id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_passwords ALTER COLUMN id SET DEFAULT nextval('public.user_passwords_id_seq'::regclass);


--
-- Name: user_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences ALTER COLUMN id SET DEFAULT nextval('public.user_preferences_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: version_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_settings ALTER COLUMN id SET DEFAULT nextval('public.version_settings_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views ALTER COLUMN id SET DEFAULT nextval('public.views_id_seq'::regclass);


--
-- Name: watchers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers ALTER COLUMN id SET DEFAULT nextval('public.watchers_id_seq'::regclass);


--
-- Name: webhooks_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_events ALTER COLUMN id SET DEFAULT nextval('public.webhooks_events_id_seq'::regclass);


--
-- Name: webhooks_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_logs ALTER COLUMN id SET DEFAULT nextval('public.webhooks_logs_id_seq'::regclass);


--
-- Name: webhooks_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_projects ALTER COLUMN id SET DEFAULT nextval('public.webhooks_projects_id_seq'::regclass);


--
-- Name: webhooks_webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_webhooks_id_seq'::regclass);


--
-- Name: wiki_page_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_journals ALTER COLUMN id SET DEFAULT nextval('public.wiki_page_journals_id_seq'::regclass);


--
-- Name: wiki_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages ALTER COLUMN id SET DEFAULT nextval('public.wiki_pages_id_seq'::regclass);


--
-- Name: wiki_redirects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_redirects ALTER COLUMN id SET DEFAULT nextval('public.wiki_redirects_id_seq'::regclass);


--
-- Name: wikis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wikis ALTER COLUMN id SET DEFAULT nextval('public.wikis_id_seq'::regclass);


--
-- Name: work_package_journals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_package_journals ALTER COLUMN id SET DEFAULT nextval('public.work_package_journals_id_seq'::regclass);


--
-- Name: work_packages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_packages ALTER COLUMN id SET DEFAULT nextval('public.work_packages_id_seq'::regclass);


--
-- Name: workflows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows ALTER COLUMN id SET DEFAULT nextval('public.workflows_id_seq'::regclass);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: attachable_journals attachable_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachable_journals
    ADD CONSTRAINT attachable_journals_pkey PRIMARY KEY (id);


--
-- Name: attachment_journals attachment_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachment_journals
    ADD CONSTRAINT attachment_journals_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: attribute_help_texts attribute_help_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_help_texts
    ADD CONSTRAINT attribute_help_texts_pkey PRIMARY KEY (id);


--
-- Name: auth_providers auth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_providers
    ADD CONSTRAINT auth_providers_pkey PRIMARY KEY (id);


--
-- Name: bcf_comments bcf_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_comments
    ADD CONSTRAINT bcf_comments_pkey PRIMARY KEY (id);


--
-- Name: bcf_issues bcf_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_issues
    ADD CONSTRAINT bcf_issues_pkey PRIMARY KEY (id);


--
-- Name: bcf_viewpoints bcf_viewpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_viewpoints
    ADD CONSTRAINT bcf_viewpoints_pkey PRIMARY KEY (id);


--
-- Name: budget_journals budget_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_journals
    ADD CONSTRAINT budget_journals_pkey PRIMARY KEY (id);


--
-- Name: budgets budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: changes changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes
    ADD CONSTRAINT changes_pkey PRIMARY KEY (id);


--
-- Name: changeset_journals changeset_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changeset_journals
    ADD CONSTRAINT changeset_journals_pkey PRIMARY KEY (id);


--
-- Name: changesets changesets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changesets
    ADD CONSTRAINT changesets_pkey PRIMARY KEY (id);


--
-- Name: colors colors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT colors_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: cost_entries cost_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_entries
    ADD CONSTRAINT cost_entries_pkey PRIMARY KEY (id);


--
-- Name: cost_queries cost_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_queries
    ADD CONSTRAINT cost_queries_pkey PRIMARY KEY (id);


--
-- Name: cost_types cost_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_types
    ADD CONSTRAINT cost_types_pkey PRIMARY KEY (id);


--
-- Name: custom_actions custom_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions
    ADD CONSTRAINT custom_actions_pkey PRIMARY KEY (id);


--
-- Name: custom_actions_projects custom_actions_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_projects
    ADD CONSTRAINT custom_actions_projects_pkey PRIMARY KEY (id);


--
-- Name: custom_actions_roles custom_actions_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_roles
    ADD CONSTRAINT custom_actions_roles_pkey PRIMARY KEY (id);


--
-- Name: custom_actions_statuses custom_actions_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_statuses
    ADD CONSTRAINT custom_actions_statuses_pkey PRIMARY KEY (id);


--
-- Name: custom_actions_types custom_actions_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_actions_types
    ADD CONSTRAINT custom_actions_types_pkey PRIMARY KEY (id);


--
-- Name: custom_field_sections custom_field_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_sections
    ADD CONSTRAINT custom_field_sections_pkey PRIMARY KEY (id);


--
-- Name: custom_fields custom_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields
    ADD CONSTRAINT custom_fields_pkey PRIMARY KEY (id);


--
-- Name: custom_fields_projects custom_fields_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields_projects
    ADD CONSTRAINT custom_fields_projects_pkey PRIMARY KEY (id);


--
-- Name: custom_options custom_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_options
    ADD CONSTRAINT custom_options_pkey PRIMARY KEY (id);


--
-- Name: custom_styles custom_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_styles
    ADD CONSTRAINT custom_styles_pkey PRIMARY KEY (id);


--
-- Name: custom_values custom_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_values
    ADD CONSTRAINT custom_values_pkey PRIMARY KEY (id);


--
-- Name: customizable_journals customizable_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customizable_journals
    ADD CONSTRAINT customizable_journals_pkey PRIMARY KEY (id);


--
-- Name: deploy_status_checks deploy_status_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploy_status_checks
    ADD CONSTRAINT deploy_status_checks_pkey PRIMARY KEY (id);


--
-- Name: deploy_targets deploy_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploy_targets
    ADD CONSTRAINT deploy_targets_pkey PRIMARY KEY (id);


--
-- Name: design_colors design_colors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.design_colors
    ADD CONSTRAINT design_colors_pkey PRIMARY KEY (id);


--
-- Name: document_journals document_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_journals
    ADD CONSTRAINT document_journals_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: emoji_reactions emoji_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emoji_reactions
    ADD CONSTRAINT emoji_reactions_pkey PRIMARY KEY (id);


--
-- Name: enabled_modules enabled_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enabled_modules
    ADD CONSTRAINT enabled_modules_pkey PRIMARY KEY (id);


--
-- Name: enterprise_tokens enterprise_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enterprise_tokens
    ADD CONSTRAINT enterprise_tokens_pkey PRIMARY KEY (id);


--
-- Name: enumerations enumerations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enumerations
    ADD CONSTRAINT enumerations_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: file_links file_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_links
    ADD CONSTRAINT file_links_pkey PRIMARY KEY (id);


--
-- Name: forums forums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: github_check_runs github_check_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_check_runs
    ADD CONSTRAINT github_check_runs_pkey PRIMARY KEY (id);


--
-- Name: github_pull_requests github_pull_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_pull_requests
    ADD CONSTRAINT github_pull_requests_pkey PRIMARY KEY (id);


--
-- Name: github_users github_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.github_users
    ADD CONSTRAINT github_users_pkey PRIMARY KEY (id);


--
-- Name: gitlab_issues gitlab_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_issues
    ADD CONSTRAINT gitlab_issues_pkey PRIMARY KEY (id);


--
-- Name: gitlab_merge_requests gitlab_merge_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_merge_requests
    ADD CONSTRAINT gitlab_merge_requests_pkey PRIMARY KEY (id);


--
-- Name: gitlab_pipelines gitlab_pipelines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_pipelines
    ADD CONSTRAINT gitlab_pipelines_pkey PRIMARY KEY (id);


--
-- Name: gitlab_users gitlab_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gitlab_users
    ADD CONSTRAINT gitlab_users_pkey PRIMARY KEY (id);


--
-- Name: good_job_batches good_job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_batches
    ADD CONSTRAINT good_job_batches_pkey PRIMARY KEY (id);


--
-- Name: good_job_executions good_job_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_executions
    ADD CONSTRAINT good_job_executions_pkey PRIMARY KEY (id);


--
-- Name: good_job_processes good_job_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_processes
    ADD CONSTRAINT good_job_processes_pkey PRIMARY KEY (id);


--
-- Name: good_job_settings good_job_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_job_settings
    ADD CONSTRAINT good_job_settings_pkey PRIMARY KEY (id);


--
-- Name: good_jobs good_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.good_jobs
    ADD CONSTRAINT good_jobs_pkey PRIMARY KEY (id);


--
-- Name: grid_widgets grid_widgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grid_widgets
    ADD CONSTRAINT grid_widgets_pkey PRIMARY KEY (id);


--
-- Name: grids grids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grids
    ADD CONSTRAINT grids_pkey PRIMARY KEY (id);


--
-- Name: group_users group_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT group_users_pkey PRIMARY KEY (id);


--
-- Name: hierarchical_items hierarchical_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hierarchical_items
    ADD CONSTRAINT hierarchical_items_pkey PRIMARY KEY (id);


--
-- Name: ical_token_query_assignments ical_token_query_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ical_token_query_assignments
    ADD CONSTRAINT ical_token_query_assignments_pkey PRIMARY KEY (id);


--
-- Name: ifc_models ifc_models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ifc_models
    ADD CONSTRAINT ifc_models_pkey PRIMARY KEY (id);


--
-- Name: job_statuses job_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_statuses
    ADD CONSTRAINT job_statuses_pkey PRIMARY KEY (id);


--
-- Name: journals journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journals
    ADD CONSTRAINT journals_pkey PRIMARY KEY (id);


--
-- Name: labor_budget_items labor_budget_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labor_budget_items
    ADD CONSTRAINT labor_budget_items_pkey PRIMARY KEY (id);


--
-- Name: last_project_folders last_project_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.last_project_folders
    ADD CONSTRAINT last_project_folders_pkey PRIMARY KEY (id);


--
-- Name: ldap_auth_sources ldap_auth_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_auth_sources
    ADD CONSTRAINT ldap_auth_sources_pkey PRIMARY KEY (id);


--
-- Name: ldap_groups_memberships ldap_groups_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_groups_memberships
    ADD CONSTRAINT ldap_groups_memberships_pkey PRIMARY KEY (id);


--
-- Name: ldap_groups_synchronized_filters ldap_groups_synchronized_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_groups_synchronized_filters
    ADD CONSTRAINT ldap_groups_synchronized_filters_pkey PRIMARY KEY (id);


--
-- Name: ldap_groups_synchronized_groups ldap_groups_synchronized_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_groups_synchronized_groups
    ADD CONSTRAINT ldap_groups_synchronized_groups_pkey PRIMARY KEY (id);


--
-- Name: material_budget_items material_budget_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_budget_items
    ADD CONSTRAINT material_budget_items_pkey PRIMARY KEY (id);


--
-- Name: meeting_agenda_item_journals meeting_agenda_item_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_item_journals
    ADD CONSTRAINT meeting_agenda_item_journals_pkey PRIMARY KEY (id);


--
-- Name: meeting_agenda_items meeting_agenda_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_items
    ADD CONSTRAINT meeting_agenda_items_pkey PRIMARY KEY (id);


--
-- Name: meeting_content_journals meeting_content_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_content_journals
    ADD CONSTRAINT meeting_content_journals_pkey PRIMARY KEY (id);


--
-- Name: meeting_contents meeting_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_contents
    ADD CONSTRAINT meeting_contents_pkey PRIMARY KEY (id);


--
-- Name: meeting_journals meeting_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_journals
    ADD CONSTRAINT meeting_journals_pkey PRIMARY KEY (id);


--
-- Name: meeting_participants meeting_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_participants
    ADD CONSTRAINT meeting_participants_pkey PRIMARY KEY (id);


--
-- Name: meeting_sections meeting_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_sections
    ADD CONSTRAINT meeting_sections_pkey PRIMARY KEY (id);


--
-- Name: meetings meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meetings
    ADD CONSTRAINT meetings_pkey PRIMARY KEY (id);


--
-- Name: member_roles member_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member_roles
    ADD CONSTRAINT member_roles_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- Name: message_journals message_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_journals
    ADD CONSTRAINT message_journals_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: news_journals news_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_journals
    ADD CONSTRAINT news_journals_pkey PRIMARY KEY (id);


--
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: journals non_overlapping_journals_validity_periods; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journals
    ADD CONSTRAINT non_overlapping_journals_validity_periods EXCLUDE USING gist (journable_id WITH =, journable_type WITH =, validity_period WITH &&) DEFERRABLE;


--
-- Name: non_working_days non_working_days_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_working_days
    ADD CONSTRAINT non_working_days_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_tokens oauth_client_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_client_tokens
    ADD CONSTRAINT oauth_client_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oidc_user_session_links oidc_user_session_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_user_session_links
    ADD CONSTRAINT oidc_user_session_links_pkey PRIMARY KEY (id);


--
-- Name: oidc_user_tokens oidc_user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_user_tokens
    ADD CONSTRAINT oidc_user_tokens_pkey PRIMARY KEY (id);


--
-- Name: ordered_work_packages ordered_work_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordered_work_packages
    ADD CONSTRAINT ordered_work_packages_pkey PRIMARY KEY (id);


--
-- Name: paper_trail_audits paper_trail_audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paper_trail_audits
    ADD CONSTRAINT paper_trail_audits_pkey PRIMARY KEY (id);


--
-- Name: project_custom_field_project_mappings project_custom_field_project_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_custom_field_project_mappings
    ADD CONSTRAINT project_custom_field_project_mappings_pkey PRIMARY KEY (id);


--
-- Name: project_journals project_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_journals
    ADD CONSTRAINT project_journals_pkey PRIMARY KEY (id);


--
-- Name: project_life_cycle_step_definitions project_life_cycle_step_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_life_cycle_step_definitions
    ADD CONSTRAINT project_life_cycle_step_definitions_pkey PRIMARY KEY (id);


--
-- Name: project_life_cycle_steps project_life_cycle_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_life_cycle_steps
    ADD CONSTRAINT project_life_cycle_steps_pkey PRIMARY KEY (id);


--
-- Name: project_queries project_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_queries
    ADD CONSTRAINT project_queries_pkey PRIMARY KEY (id);


--
-- Name: project_storages project_storages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_storages
    ADD CONSTRAINT project_storages_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: queries queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.queries
    ADD CONSTRAINT queries_pkey PRIMARY KEY (id);


--
-- Name: rates rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates
    ADD CONSTRAINT rates_pkey PRIMARY KEY (id);


--
-- Name: recaptcha_entries recaptcha_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recaptcha_entries
    ADD CONSTRAINT recaptcha_entries_pkey PRIMARY KEY (id);


--
-- Name: recurring_meetings recurring_meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_meetings
    ADD CONSTRAINT recurring_meetings_pkey PRIMARY KEY (id);


--
-- Name: relations relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relations
    ADD CONSTRAINT relations_pkey PRIMARY KEY (id);


--
-- Name: reminder_notifications reminder_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminder_notifications
    ADD CONSTRAINT reminder_notifications_pkey PRIMARY KEY (id);


--
-- Name: reminders reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: remote_identities remote_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remote_identities
    ADD CONSTRAINT remote_identities_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scheduled_meetings scheduled_meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_meetings
    ADD CONSTRAINT scheduled_meetings_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: statuses statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (id);


--
-- Name: storages_file_links_journals storages_file_links_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages_file_links_journals
    ADD CONSTRAINT storages_file_links_journals_pkey PRIMARY KEY (id);


--
-- Name: storages storages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages
    ADD CONSTRAINT storages_pkey PRIMARY KEY (id);


--
-- Name: time_entries time_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entries
    ADD CONSTRAINT time_entries_pkey PRIMARY KEY (id);


--
-- Name: time_entry_activities_projects time_entry_activities_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entry_activities_projects
    ADD CONSTRAINT time_entry_activities_projects_pkey PRIMARY KEY (id);


--
-- Name: time_entry_journals time_entry_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entry_journals
    ADD CONSTRAINT time_entry_journals_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: two_factor_authentication_devices two_factor_authentication_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.two_factor_authentication_devices
    ADD CONSTRAINT two_factor_authentication_devices_pkey PRIMARY KEY (id);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: user_passwords user_passwords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_passwords
    ADD CONSTRAINT user_passwords_pkey PRIMARY KEY (id);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: version_settings version_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_settings
    ADD CONSTRAINT version_settings_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: views views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT views_pkey PRIMARY KEY (id);


--
-- Name: watchers watchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_pkey PRIMARY KEY (id);


--
-- Name: webhooks_events webhooks_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_events
    ADD CONSTRAINT webhooks_events_pkey PRIMARY KEY (id);


--
-- Name: webhooks_logs webhooks_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_logs
    ADD CONSTRAINT webhooks_logs_pkey PRIMARY KEY (id);


--
-- Name: webhooks_projects webhooks_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_projects
    ADD CONSTRAINT webhooks_projects_pkey PRIMARY KEY (id);


--
-- Name: webhooks_webhooks webhooks_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_webhooks
    ADD CONSTRAINT webhooks_webhooks_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_journals wiki_page_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_journals
    ADD CONSTRAINT wiki_page_journals_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: wiki_redirects wiki_redirects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_redirects
    ADD CONSTRAINT wiki_redirects_pkey PRIMARY KEY (id);


--
-- Name: wikis wikis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wikis
    ADD CONSTRAINT wikis_pkey PRIMARY KEY (id);


--
-- Name: work_package_journals work_package_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_package_journals
    ADD CONSTRAINT work_package_journals_pkey PRIMARY KEY (id);


--
-- Name: work_packages work_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_packages
    ADD CONSTRAINT work_packages_pkey PRIMARY KEY (id);


--
-- Name: workflows workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- Name: changesets_changeset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changesets_changeset_id ON public.changes USING btree (changeset_id);


--
-- Name: changesets_repos_rev; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX changesets_repos_rev ON public.changesets USING btree (repository_id, revision);


--
-- Name: changesets_repos_scmid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changesets_repos_scmid ON public.changesets USING btree (repository_id, scmid);


--
-- Name: changesets_work_packages_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX changesets_work_packages_ids ON public.changesets_work_packages USING btree (changeset_id, work_package_id);


--
-- Name: custom_fields_types_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX custom_fields_types_unique ON public.custom_fields_types USING btree (custom_field_id, type_id);


--
-- Name: custom_values_customized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX custom_values_customized ON public.custom_values USING btree (customized_type, customized_id);


--
-- Name: documents_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_project_id ON public.documents USING btree (project_id);


--
-- Name: enabled_modules_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX enabled_modules_project_id ON public.enabled_modules USING btree (project_id);


--
-- Name: forums_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX forums_project_id ON public.forums USING btree (project_id);


--
-- Name: github_pr_wp_pr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX github_pr_wp_pr_id ON public.github_pull_requests_work_packages USING btree (github_pull_request_id);


--
-- Name: gitlab_issues_wp_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gitlab_issues_wp_issue_id ON public.gitlab_issues_work_packages USING btree (gitlab_issue_id);


--
-- Name: gitlab_mr_wp_mr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gitlab_mr_wp_mr_id ON public.gitlab_merge_requests_work_packages USING btree (gitlab_merge_request_id);


--
-- Name: group_user_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX group_user_ids ON public.group_users USING btree (group_id, user_id);


--
-- Name: idx_on_recurring_meeting_id_start_time_17110a55ba; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_recurring_meeting_id_start_time_17110a55ba ON public.scheduled_meetings USING btree (recurring_meeting_id, start_time);


--
-- Name: index_announcements_on_show_until_and_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_announcements_on_show_until_and_active ON public.announcements USING btree (show_until, active);


--
-- Name: index_attachable_journals_on_attachment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachable_journals_on_attachment_id ON public.attachable_journals USING btree (attachment_id);


--
-- Name: index_attachable_journals_on_journal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachable_journals_on_journal_id ON public.attachable_journals USING btree (journal_id);


--
-- Name: index_attachments_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_author_id ON public.attachments USING btree (author_id);


--
-- Name: index_attachments_on_container_id_and_container_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_container_id_and_container_type ON public.attachments USING btree (container_id, container_type);


--
-- Name: index_attachments_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_created_at ON public.attachments USING btree (created_at);


--
-- Name: index_attachments_on_file_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_file_tsv ON public.attachments USING gin (file_tsv);


--
-- Name: index_attachments_on_fulltext_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_fulltext_tsv ON public.attachments USING gin (fulltext_tsv);


--
-- Name: index_auth_providers_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_auth_providers_on_creator_id ON public.auth_providers USING btree (creator_id);


--
-- Name: index_auth_providers_on_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_auth_providers_on_display_name ON public.auth_providers USING btree (display_name);


--
-- Name: index_auth_providers_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_auth_providers_on_slug ON public.auth_providers USING btree (slug);


--
-- Name: index_bcf_comments_on_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bcf_comments_on_issue_id ON public.bcf_comments USING btree (issue_id);


--
-- Name: index_bcf_comments_on_journal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bcf_comments_on_journal_id ON public.bcf_comments USING btree (journal_id);


--
-- Name: index_bcf_comments_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bcf_comments_on_uuid ON public.bcf_comments USING btree (uuid);


--
-- Name: index_bcf_comments_on_uuid_and_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bcf_comments_on_uuid_and_issue_id ON public.bcf_comments USING btree (uuid, issue_id);


--
-- Name: index_bcf_comments_on_viewpoint_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bcf_comments_on_viewpoint_id ON public.bcf_comments USING btree (viewpoint_id);


--
-- Name: index_bcf_issues_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bcf_issues_on_uuid ON public.bcf_issues USING btree (uuid);


--
-- Name: index_bcf_issues_on_work_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bcf_issues_on_work_package_id ON public.bcf_issues USING btree (work_package_id);


--
-- Name: index_bcf_viewpoints_on_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bcf_viewpoints_on_issue_id ON public.bcf_viewpoints USING btree (issue_id);


--
-- Name: index_bcf_viewpoints_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bcf_viewpoints_on_uuid ON public.bcf_viewpoints USING btree (uuid);


--
-- Name: index_bcf_viewpoints_on_uuid_and_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bcf_viewpoints_on_uuid_and_issue_id ON public.bcf_viewpoints USING btree (uuid, issue_id);


--
-- Name: index_budgets_on_project_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_budgets_on_project_id_and_updated_at ON public.budgets USING btree (project_id, updated_at);


--
-- Name: index_categories_on_assigned_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_assigned_to_id ON public.categories USING btree (assigned_to_id);


--
-- Name: index_changesets_on_committed_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_changesets_on_committed_on ON public.changesets USING btree (committed_on);


--
-- Name: index_changesets_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_changesets_on_repository_id ON public.changesets USING btree (repository_id);


--
-- Name: index_changesets_on_repository_id_and_committed_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_changesets_on_repository_id_and_committed_on ON public.changesets USING btree (repository_id, committed_on);


--
-- Name: index_changesets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_changesets_on_user_id ON public.changesets USING btree (user_id);


--
-- Name: index_comments_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_author_id ON public.comments USING btree (author_id);


--
-- Name: index_comments_on_commented_id_and_commented_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commented_id_and_commented_type ON public.comments USING btree (commented_id, commented_type);


--
-- Name: index_cost_entries_on_logged_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cost_entries_on_logged_by_id ON public.cost_entries USING btree (logged_by_id);


--
-- Name: index_custom_actions_projects_on_custom_action_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_projects_on_custom_action_id ON public.custom_actions_projects USING btree (custom_action_id);


--
-- Name: index_custom_actions_projects_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_projects_on_project_id ON public.custom_actions_projects USING btree (project_id);


--
-- Name: index_custom_actions_roles_on_custom_action_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_roles_on_custom_action_id ON public.custom_actions_roles USING btree (custom_action_id);


--
-- Name: index_custom_actions_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_roles_on_role_id ON public.custom_actions_roles USING btree (role_id);


--
-- Name: index_custom_actions_statuses_on_custom_action_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_statuses_on_custom_action_id ON public.custom_actions_statuses USING btree (custom_action_id);


--
-- Name: index_custom_actions_statuses_on_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_statuses_on_status_id ON public.custom_actions_statuses USING btree (status_id);


--
-- Name: index_custom_actions_types_on_custom_action_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_types_on_custom_action_id ON public.custom_actions_types USING btree (custom_action_id);


--
-- Name: index_custom_actions_types_on_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_actions_types_on_type_id ON public.custom_actions_types USING btree (type_id);


--
-- Name: index_custom_fields_on_custom_field_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_fields_on_custom_field_section_id ON public.custom_fields USING btree (custom_field_section_id);


--
-- Name: index_custom_fields_on_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_fields_on_id_and_type ON public.custom_fields USING btree (id, type);


--
-- Name: index_custom_fields_projects_on_custom_field_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_custom_fields_projects_on_custom_field_id_and_project_id ON public.custom_fields_projects USING btree (custom_field_id, project_id);


--
-- Name: index_custom_options_on_custom_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_options_on_custom_field_id ON public.custom_options USING btree (custom_field_id);


--
-- Name: index_custom_options_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_options_on_value ON public.custom_options USING gin (value gin_trgm_ops);


--
-- Name: index_custom_values_on_custom_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_values_on_custom_field_id ON public.custom_values USING btree (custom_field_id);


--
-- Name: index_custom_values_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_values_on_value ON public.custom_values USING gin (value gin_trgm_ops);


--
-- Name: index_customizable_journals_on_custom_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customizable_journals_on_custom_field_id ON public.customizable_journals USING btree (custom_field_id);


--
-- Name: index_customizable_journals_on_journal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customizable_journals_on_journal_id ON public.customizable_journals USING btree (journal_id);


--
-- Name: index_deploy_status_checks_on_deploy_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deploy_status_checks_on_deploy_target_id ON public.deploy_status_checks USING btree (deploy_target_id);


--
-- Name: index_deploy_status_checks_on_github_pull_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deploy_status_checks_on_github_pull_request_id ON public.deploy_status_checks USING btree (github_pull_request_id);


--
-- Name: index_deploy_targets_on_host; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_deploy_targets_on_host ON public.deploy_targets USING btree (host);


--
-- Name: index_design_colors_on_variable; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_design_colors_on_variable ON public.design_colors USING btree (variable);


--
-- Name: index_documents_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_category_id ON public.documents USING btree (category_id);


--
-- Name: index_documents_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_created_at ON public.documents USING btree (created_at);


--
-- Name: index_emoji_reactions_on_reactable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emoji_reactions_on_reactable ON public.emoji_reactions USING btree (reactable_type, reactable_id);


--
-- Name: index_emoji_reactions_on_reaction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emoji_reactions_on_reaction ON public.emoji_reactions USING btree (reaction);


--
-- Name: index_emoji_reactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emoji_reactions_on_user_id ON public.emoji_reactions USING btree (user_id);


--
-- Name: index_emoji_reactions_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_emoji_reactions_uniqueness ON public.emoji_reactions USING btree (user_id, reactable_type, reactable_id, reaction);


--
-- Name: index_enabled_modules_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enabled_modules_on_name ON public.enabled_modules USING btree (name);


--
-- Name: index_enumerations_on_color_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enumerations_on_color_id ON public.enumerations USING btree (color_id);


--
-- Name: index_enumerations_on_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enumerations_on_id_and_type ON public.enumerations USING btree (id, type);


--
-- Name: index_enumerations_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enumerations_on_project_id ON public.enumerations USING btree (project_id);


--
-- Name: index_favorites_on_favored; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_favored ON public.favorites USING btree (favored_type, favored_id);


--
-- Name: index_favorites_on_favored_type_and_favored_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_favored_type_and_favored_id ON public.favorites USING btree (favored_type, favored_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_user_id ON public.favorites USING btree (user_id);


--
-- Name: index_favorites_on_user_id_and_favored_type_and_favored_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_favorites_on_user_id_and_favored_type_and_favored_id ON public.favorites USING btree (user_id, favored_type, favored_id);


--
-- Name: index_file_links_on_container_id_and_container_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_links_on_container_id_and_container_type ON public.file_links USING btree (container_id, container_type);


--
-- Name: index_file_links_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_links_on_creator_id ON public.file_links USING btree (creator_id);


--
-- Name: index_file_links_on_origin_id_and_storage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_links_on_origin_id_and_storage_id ON public.file_links USING btree (origin_id, storage_id);


--
-- Name: index_file_links_on_storage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_links_on_storage_id ON public.file_links USING btree (storage_id);


--
-- Name: index_forums_on_last_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forums_on_last_message_id ON public.forums USING btree (last_message_id);


--
-- Name: index_github_check_runs_on_github_pull_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_github_check_runs_on_github_pull_request_id ON public.github_check_runs USING btree (github_pull_request_id);


--
-- Name: index_github_pull_requests_on_github_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_github_pull_requests_on_github_user_id ON public.github_pull_requests USING btree (github_user_id);


--
-- Name: index_github_pull_requests_on_merged_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_github_pull_requests_on_merged_by_id ON public.github_pull_requests USING btree (merged_by_id);


--
-- Name: index_gitlab_issues_on_gitlab_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gitlab_issues_on_gitlab_user_id ON public.gitlab_issues USING btree (gitlab_user_id);


--
-- Name: index_gitlab_merge_requests_on_gitlab_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gitlab_merge_requests_on_gitlab_user_id ON public.gitlab_merge_requests USING btree (gitlab_user_id);


--
-- Name: index_gitlab_merge_requests_on_merged_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gitlab_merge_requests_on_merged_by_id ON public.gitlab_merge_requests USING btree (merged_by_id);


--
-- Name: index_gitlab_pipelines_on_gitlab_merge_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gitlab_pipelines_on_gitlab_merge_request_id ON public.gitlab_pipelines USING btree (gitlab_merge_request_id);


--
-- Name: index_good_job_executions_on_active_job_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_job_executions_on_active_job_id_and_created_at ON public.good_job_executions USING btree (active_job_id, created_at);


--
-- Name: index_good_job_executions_on_process_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_job_executions_on_process_id_and_created_at ON public.good_job_executions USING btree (process_id, created_at);


--
-- Name: index_good_job_jobs_for_candidate_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_job_jobs_for_candidate_lookup ON public.good_jobs USING btree (priority, created_at) WHERE (finished_at IS NULL);


--
-- Name: index_good_job_settings_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_good_job_settings_on_key ON public.good_job_settings USING btree (key);


--
-- Name: index_good_jobs_jobs_on_finished_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_jobs_on_finished_at ON public.good_jobs USING btree (finished_at) WHERE ((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL));


--
-- Name: index_good_jobs_jobs_on_priority_created_at_when_unfinished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_jobs_on_priority_created_at_when_unfinished ON public.good_jobs USING btree (priority DESC NULLS LAST, created_at) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_active_job_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_active_job_id_and_created_at ON public.good_jobs USING btree (active_job_id, created_at);


--
-- Name: index_good_jobs_on_batch_callback_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_batch_callback_id ON public.good_jobs USING btree (batch_callback_id) WHERE (batch_callback_id IS NOT NULL);


--
-- Name: index_good_jobs_on_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_batch_id ON public.good_jobs USING btree (batch_id) WHERE (batch_id IS NOT NULL);


--
-- Name: index_good_jobs_on_concurrency_key_when_unfinished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_concurrency_key_when_unfinished ON public.good_jobs USING btree (concurrency_key) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_cron_key_and_created_at_cond; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_cron_key_and_created_at_cond ON public.good_jobs USING btree (cron_key, created_at) WHERE (cron_key IS NOT NULL);


--
-- Name: index_good_jobs_on_cron_key_and_cron_at_cond; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_good_jobs_on_cron_key_and_cron_at_cond ON public.good_jobs USING btree (cron_key, cron_at) WHERE (cron_key IS NOT NULL);


--
-- Name: index_good_jobs_on_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_labels ON public.good_jobs USING gin (labels) WHERE (labels IS NOT NULL);


--
-- Name: index_good_jobs_on_locked_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_locked_by_id ON public.good_jobs USING btree (locked_by_id) WHERE (locked_by_id IS NOT NULL);


--
-- Name: index_good_jobs_on_priority_scheduled_at_unfinished_unlocked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_priority_scheduled_at_unfinished_unlocked ON public.good_jobs USING btree (priority, scheduled_at) WHERE ((finished_at IS NULL) AND (locked_by_id IS NULL));


--
-- Name: index_good_jobs_on_queue_name_and_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_queue_name_and_scheduled_at ON public.good_jobs USING btree (queue_name, scheduled_at) WHERE (finished_at IS NULL);


--
-- Name: index_good_jobs_on_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_good_jobs_on_scheduled_at ON public.good_jobs USING btree (scheduled_at) WHERE (finished_at IS NULL);


--
-- Name: index_grid_widgets_on_grid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grid_widgets_on_grid_id ON public.grid_widgets USING btree (grid_id);


--
-- Name: index_grids_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grids_on_project_id ON public.grids USING btree (project_id);


--
-- Name: index_grids_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grids_on_user_id ON public.grids USING btree (user_id);


--
-- Name: index_group_users_on_user_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_group_users_on_user_id_and_group_id ON public.group_users USING btree (user_id, group_id);


--
-- Name: index_hierarchical_items_on_custom_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hierarchical_items_on_custom_field_id ON public.hierarchical_items USING btree (custom_field_id);


--
-- Name: index_hierarchical_items_on_position_cache; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hierarchical_items_on_position_cache ON public.hierarchical_items USING btree (position_cache);


--
-- Name: index_ical_token_query_assignments_on_ical_token_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ical_token_query_assignments_on_ical_token_id ON public.ical_token_query_assignments USING btree (ical_token_id);


--
-- Name: index_ical_token_query_assignments_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ical_token_query_assignments_on_query_id ON public.ical_token_query_assignments USING btree (query_id);


--
-- Name: index_ifc_models_on_is_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ifc_models_on_is_default ON public.ifc_models USING btree (is_default);


--
-- Name: index_ifc_models_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ifc_models_on_project_id ON public.ifc_models USING btree (project_id);


--
-- Name: index_ifc_models_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ifc_models_on_uploader_id ON public.ifc_models USING btree (uploader_id);


--
-- Name: index_job_statuses_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_statuses_on_job_id ON public.job_statuses USING btree (job_id);


--
-- Name: index_job_statuses_on_reference_type_and_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_statuses_on_reference_type_and_reference_id ON public.job_statuses USING btree (reference_type, reference_id);


--
-- Name: index_job_statuses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_statuses_on_user_id ON public.job_statuses USING btree (user_id);


--
-- Name: index_journals_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_created_at ON public.journals USING btree (created_at);


--
-- Name: index_journals_on_data_id_and_data_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_journals_on_data_id_and_data_type ON public.journals USING btree (data_id, data_type);


--
-- Name: index_journals_on_journable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_journable_id ON public.journals USING btree (journable_id);


--
-- Name: index_journals_on_journable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_journable_type ON public.journals USING btree (journable_type);


--
-- Name: index_journals_on_journable_type_and_journable_id_and_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_journals_on_journable_type_and_journable_id_and_version ON public.journals USING btree (journable_type, journable_id, version);


--
-- Name: index_journals_on_notes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_notes ON public.journals USING gin (notes gin_trgm_ops);


--
-- Name: index_journals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journals_on_user_id ON public.journals USING btree (user_id);


--
-- Name: index_last_project_folders_on_project_storage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_last_project_folders_on_project_storage_id ON public.last_project_folders USING btree (project_storage_id);


--
-- Name: index_last_project_folders_on_project_storage_id_and_mode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_last_project_folders_on_project_storage_id_and_mode ON public.last_project_folders USING btree (project_storage_id, mode);


--
-- Name: index_ldap_groups_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ldap_groups_memberships_on_group_id ON public.ldap_groups_memberships USING btree (group_id);


--
-- Name: index_ldap_groups_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ldap_groups_memberships_on_user_id ON public.ldap_groups_memberships USING btree (user_id);


--
-- Name: index_ldap_groups_memberships_on_user_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ldap_groups_memberships_on_user_id_and_group_id ON public.ldap_groups_memberships USING btree (user_id, group_id);


--
-- Name: index_ldap_groups_synchronized_filters_on_ldap_auth_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ldap_groups_synchronized_filters_on_ldap_auth_source_id ON public.ldap_groups_synchronized_filters USING btree (ldap_auth_source_id);


--
-- Name: index_ldap_groups_synchronized_groups_on_filter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ldap_groups_synchronized_groups_on_filter_id ON public.ldap_groups_synchronized_groups USING btree (filter_id);


--
-- Name: index_ldap_groups_synchronized_groups_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ldap_groups_synchronized_groups_on_group_id ON public.ldap_groups_synchronized_groups USING btree (group_id);


--
-- Name: index_ldap_groups_synchronized_groups_on_ldap_auth_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ldap_groups_synchronized_groups_on_ldap_auth_source_id ON public.ldap_groups_synchronized_groups USING btree (ldap_auth_source_id);


--
-- Name: index_meeting_agenda_item_journals_on_presenter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_agenda_item_journals_on_presenter_id ON public.meeting_agenda_item_journals USING btree (presenter_id);


--
-- Name: index_meeting_agenda_items_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_agenda_items_on_author_id ON public.meeting_agenda_items USING btree (author_id);


--
-- Name: index_meeting_agenda_items_on_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_agenda_items_on_meeting_id ON public.meeting_agenda_items USING btree (meeting_id);


--
-- Name: index_meeting_agenda_items_on_meeting_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_agenda_items_on_meeting_section_id ON public.meeting_agenda_items USING btree (meeting_section_id);


--
-- Name: index_meeting_agenda_items_on_notes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_agenda_items_on_notes ON public.meeting_agenda_items USING gin (notes gin_trgm_ops);


--
-- Name: index_meeting_agenda_items_on_presenter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_agenda_items_on_presenter_id ON public.meeting_agenda_items USING btree (presenter_id);


--
-- Name: index_meeting_agenda_items_on_work_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_agenda_items_on_work_package_id ON public.meeting_agenda_items USING btree (work_package_id);


--
-- Name: index_meeting_sections_on_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_sections_on_meeting_id ON public.meeting_sections USING btree (meeting_id);


--
-- Name: index_meetings_on_project_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meetings_on_project_id_and_updated_at ON public.meetings USING btree (project_id, updated_at);


--
-- Name: index_meetings_on_recurring_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meetings_on_recurring_meeting_id ON public.meetings USING btree (recurring_meeting_id);


--
-- Name: index_member_roles_on_inherited_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_roles_on_inherited_from ON public.member_roles USING btree (inherited_from);


--
-- Name: index_member_roles_on_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_roles_on_member_id ON public.member_roles USING btree (member_id);


--
-- Name: index_member_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_member_roles_on_role_id ON public.member_roles USING btree (role_id);


--
-- Name: index_members_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_on_entity ON public.members USING btree (entity_type, entity_id);


--
-- Name: index_members_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_on_project_id ON public.members USING btree (project_id);


--
-- Name: index_members_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_on_user_id ON public.members USING btree (user_id);


--
-- Name: index_members_on_user_id_and_project_with_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_members_on_user_id_and_project_with_entity ON public.members USING btree (user_id, project_id, entity_type, entity_id) WHERE ((entity_type IS NOT NULL) AND (entity_id IS NOT NULL));


--
-- Name: index_members_on_user_id_and_project_without_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_members_on_user_id_and_project_without_entity ON public.members USING btree (user_id, project_id) WHERE ((entity_type IS NULL) AND (entity_id IS NULL));


--
-- Name: index_menu_items_on_navigatable_id_and_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_items_on_navigatable_id_and_title ON public.menu_items USING btree (navigatable_id, title);


--
-- Name: index_menu_items_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_items_on_parent_id ON public.menu_items USING btree (parent_id);


--
-- Name: index_messages_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_author_id ON public.messages USING btree (author_id);


--
-- Name: index_messages_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_created_at ON public.messages USING btree (created_at);


--
-- Name: index_messages_on_forum_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_forum_id_and_updated_at ON public.messages USING btree (forum_id, updated_at);


--
-- Name: index_messages_on_last_reply_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_last_reply_id ON public.messages USING btree (last_reply_id);


--
-- Name: index_news_journals_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_journals_on_project_id ON public.news_journals USING btree (project_id);


--
-- Name: index_news_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_on_author_id ON public.news USING btree (author_id);


--
-- Name: index_news_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_on_created_at ON public.news USING btree (created_at);


--
-- Name: index_news_on_project_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_on_project_id_and_created_at ON public.news USING btree (project_id, created_at);


--
-- Name: index_non_working_days_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_non_working_days_on_date ON public.non_working_days USING btree (date);


--
-- Name: index_notification_settings_on_document_added; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_document_added ON public.notification_settings USING btree (document_added);


--
-- Name: index_notification_settings_on_forum_messages; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_forum_messages ON public.notification_settings USING btree (forum_messages);


--
-- Name: index_notification_settings_on_membership_added; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_membership_added ON public.notification_settings USING btree (membership_added);


--
-- Name: index_notification_settings_on_membership_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_membership_updated ON public.notification_settings USING btree (membership_updated);


--
-- Name: index_notification_settings_on_news_added; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_news_added ON public.notification_settings USING btree (news_added);


--
-- Name: index_notification_settings_on_news_commented; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_news_commented ON public.notification_settings USING btree (news_commented);


--
-- Name: index_notification_settings_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_project_id ON public.notification_settings USING btree (project_id);


--
-- Name: index_notification_settings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_user_id ON public.notification_settings USING btree (user_id);


--
-- Name: index_notification_settings_on_wiki_page_added; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_wiki_page_added ON public.notification_settings USING btree (wiki_page_added);


--
-- Name: index_notification_settings_on_wiki_page_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_wiki_page_updated ON public.notification_settings USING btree (wiki_page_updated);


--
-- Name: index_notification_settings_on_work_package_commented; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_work_package_commented ON public.notification_settings USING btree (work_package_commented);


--
-- Name: index_notification_settings_on_work_package_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_work_package_created ON public.notification_settings USING btree (work_package_created);


--
-- Name: index_notification_settings_on_work_package_prioritized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_work_package_prioritized ON public.notification_settings USING btree (work_package_prioritized);


--
-- Name: index_notification_settings_on_work_package_processed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_work_package_processed ON public.notification_settings USING btree (work_package_processed);


--
-- Name: index_notification_settings_on_work_package_scheduled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_settings_on_work_package_scheduled ON public.notification_settings USING btree (work_package_scheduled);


--
-- Name: index_notification_settings_unique_project; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notification_settings_unique_project ON public.notification_settings USING btree (user_id, project_id) WHERE (project_id IS NOT NULL);


--
-- Name: index_notification_settings_unique_project_null; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notification_settings_unique_project_null ON public.notification_settings USING btree (user_id) WHERE (project_id IS NULL);


--
-- Name: index_notifications_on_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_actor_id ON public.notifications USING btree (actor_id);


--
-- Name: index_notifications_on_journal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_journal_id ON public.notifications USING btree (journal_id);


--
-- Name: index_notifications_on_mail_alert_sent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_mail_alert_sent ON public.notifications USING btree (mail_alert_sent);


--
-- Name: index_notifications_on_mail_reminder_sent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_mail_reminder_sent ON public.notifications USING btree (mail_reminder_sent);


--
-- Name: index_notifications_on_read_ian; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_read_ian ON public.notifications USING btree (read_ian);


--
-- Name: index_notifications_on_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_recipient_id ON public.notifications USING btree (recipient_id);


--
-- Name: index_notifications_on_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_resource ON public.notifications USING btree (resource_type, resource_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_integration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_integration ON public.oauth_applications USING btree (integration_type, integration_id);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_oauth_client_tokens_on_oauth_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_client_tokens_on_oauth_client_id ON public.oauth_client_tokens USING btree (oauth_client_id);


--
-- Name: index_oauth_client_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_client_tokens_on_user_id ON public.oauth_client_tokens USING btree (user_id);


--
-- Name: index_oauth_client_tokens_on_user_id_and_oauth_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_client_tokens_on_user_id_and_oauth_client_id ON public.oauth_client_tokens USING btree (user_id, oauth_client_id);


--
-- Name: index_oauth_clients_on_integration; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_clients_on_integration ON public.oauth_clients USING btree (integration_type, integration_id);


--
-- Name: index_oidc_user_session_links_on_oidc_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oidc_user_session_links_on_oidc_session ON public.oidc_user_session_links USING btree (oidc_session);


--
-- Name: index_oidc_user_session_links_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oidc_user_session_links_on_session_id ON public.oidc_user_session_links USING btree (session_id);


--
-- Name: index_oidc_user_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oidc_user_tokens_on_user_id ON public.oidc_user_tokens USING btree (user_id);


--
-- Name: index_ordered_work_packages_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordered_work_packages_on_position ON public.ordered_work_packages USING btree ("position");


--
-- Name: index_ordered_work_packages_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordered_work_packages_on_query_id ON public.ordered_work_packages USING btree (query_id);


--
-- Name: index_ordered_work_packages_on_work_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ordered_work_packages_on_work_package_id ON public.ordered_work_packages USING btree (work_package_id);


--
-- Name: index_paper_trail_audits_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_paper_trail_audits_on_item_type_and_item_id ON public.paper_trail_audits USING btree (item_type, item_id);


--
-- Name: index_project_cf_project_mappings_on_custom_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_cf_project_mappings_on_custom_field_id ON public.project_custom_field_project_mappings USING btree (custom_field_id);


--
-- Name: index_project_custom_field_project_mappings_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_custom_field_project_mappings_on_project_id ON public.project_custom_field_project_mappings USING btree (project_id);


--
-- Name: index_project_custom_field_project_mappings_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_project_custom_field_project_mappings_unique ON public.project_custom_field_project_mappings USING btree (project_id, custom_field_id);


--
-- Name: index_project_life_cycle_step_definitions_on_color_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_life_cycle_step_definitions_on_color_id ON public.project_life_cycle_step_definitions USING btree (color_id);


--
-- Name: index_project_life_cycle_step_definitions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_project_life_cycle_step_definitions_on_name ON public.project_life_cycle_step_definitions USING btree (name);


--
-- Name: index_project_life_cycle_steps_on_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_life_cycle_steps_on_definition_id ON public.project_life_cycle_steps USING btree (definition_id);


--
-- Name: index_project_life_cycle_steps_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_life_cycle_steps_on_project_id ON public.project_life_cycle_steps USING btree (project_id);


--
-- Name: index_project_life_cycle_steps_on_project_id_and_definition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_project_life_cycle_steps_on_project_id_and_definition_id ON public.project_life_cycle_steps USING btree (project_id, definition_id);


--
-- Name: index_project_queries_on_public; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_queries_on_public ON public.project_queries USING btree (public);


--
-- Name: index_project_queries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_queries_on_user_id ON public.project_queries USING btree (user_id);


--
-- Name: index_project_storages_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_storages_on_creator_id ON public.project_storages USING btree (creator_id);


--
-- Name: index_project_storages_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_storages_on_project_id ON public.project_storages USING btree (project_id);


--
-- Name: index_project_storages_on_project_id_and_storage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_project_storages_on_project_id_and_storage_id ON public.project_storages USING btree (project_id, storage_id);


--
-- Name: index_project_storages_on_storage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_storages_on_storage_id ON public.project_storages USING btree (storage_id);


--
-- Name: index_projects_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_active ON public.projects USING btree (active);


--
-- Name: index_projects_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_identifier ON public.projects USING btree (identifier);


--
-- Name: index_projects_on_lft; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_lft ON public.projects USING btree (lft);


--
-- Name: index_projects_on_lft_and_rgt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_lft_and_rgt ON public.projects USING btree (lft, rgt);


--
-- Name: index_projects_on_rgt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_rgt ON public.projects USING btree (rgt);


--
-- Name: index_queries_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_queries_on_project_id ON public.queries USING btree (project_id);


--
-- Name: index_queries_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_queries_on_updated_at ON public.queries USING btree (updated_at);


--
-- Name: index_queries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_queries_on_user_id ON public.queries USING btree (user_id);


--
-- Name: index_recaptcha_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recaptcha_entries_on_user_id ON public.recaptcha_entries USING btree (user_id);


--
-- Name: index_recurring_meetings_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recurring_meetings_on_author_id ON public.recurring_meetings USING btree (author_id);


--
-- Name: index_recurring_meetings_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recurring_meetings_on_project_id ON public.recurring_meetings USING btree (project_id);


--
-- Name: index_relations_on_from_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_relations_on_from_id ON public.relations USING btree (from_id);


--
-- Name: index_relations_on_from_id_and_to_id_and_relation_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_relations_on_from_id_and_to_id_and_relation_type ON public.relations USING btree (from_id, to_id, relation_type);


--
-- Name: index_relations_on_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_relations_on_to_id ON public.relations USING btree (to_id);


--
-- Name: index_relations_on_to_id_and_from_id_and_relation_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_relations_on_to_id_and_from_id_and_relation_type ON public.relations USING btree (to_id, from_id, relation_type);


--
-- Name: index_reminder_notifications_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminder_notifications_on_notification_id ON public.reminder_notifications USING btree (notification_id);


--
-- Name: index_reminder_notifications_on_reminder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminder_notifications_on_reminder_id ON public.reminder_notifications USING btree (reminder_id);


--
-- Name: index_reminder_notifications_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reminder_notifications_unique ON public.reminder_notifications USING btree (notification_id);


--
-- Name: index_reminders_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminders_on_creator_id ON public.reminders USING btree (creator_id);


--
-- Name: index_reminders_on_remindable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reminders_on_remindable ON public.reminders USING btree (remindable_type, remindable_id);


--
-- Name: index_remote_identities_on_oauth_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remote_identities_on_oauth_client_id ON public.remote_identities USING btree (oauth_client_id);


--
-- Name: index_remote_identities_on_origin_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remote_identities_on_origin_user_id ON public.remote_identities USING btree (origin_user_id);


--
-- Name: index_remote_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remote_identities_on_user_id ON public.remote_identities USING btree (user_id);


--
-- Name: index_remote_identities_on_user_id_and_oauth_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_remote_identities_on_user_id_and_oauth_client_id ON public.remote_identities USING btree (user_id, oauth_client_id);


--
-- Name: index_repositories_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_project_id ON public.repositories USING btree (project_id);


--
-- Name: index_role_permissions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_permissions_on_role_id ON public.role_permissions USING btree (role_id);


--
-- Name: index_scheduled_meetings_on_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scheduled_meetings_on_meeting_id ON public.scheduled_meetings USING btree (meeting_id);


--
-- Name: index_scheduled_meetings_on_recurring_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scheduled_meetings_on_recurring_meeting_id ON public.scheduled_meetings USING btree (recurring_meeting_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_settings_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_settings_on_name ON public.settings USING btree (name);


--
-- Name: index_statuses_on_color_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statuses_on_color_id ON public.statuses USING btree (color_id);


--
-- Name: index_statuses_on_is_closed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statuses_on_is_closed ON public.statuses USING btree (is_closed);


--
-- Name: index_statuses_on_is_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statuses_on_is_default ON public.statuses USING btree (is_default);


--
-- Name: index_statuses_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statuses_on_position ON public.statuses USING btree ("position");


--
-- Name: index_storages_file_links_journals_on_file_link_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_storages_file_links_journals_on_file_link_id ON public.storages_file_links_journals USING btree (file_link_id);


--
-- Name: index_storages_file_links_journals_on_journal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_storages_file_links_journals_on_journal_id ON public.storages_file_links_journals USING btree (journal_id);


--
-- Name: index_storages_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_storages_on_creator_id ON public.storages USING btree (creator_id);


--
-- Name: index_storages_on_host; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_storages_on_host ON public.storages USING btree (host);


--
-- Name: index_storages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_storages_on_name ON public.storages USING btree (name);


--
-- Name: index_teap_on_project_id_and_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teap_on_project_id_and_activity_id ON public.time_entry_activities_projects USING btree (project_id, activity_id);


--
-- Name: index_time_entries_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entries_on_activity_id ON public.time_entries USING btree (activity_id);


--
-- Name: index_time_entries_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entries_on_created_at ON public.time_entries USING btree (created_at);


--
-- Name: index_time_entries_on_logged_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entries_on_logged_by_id ON public.time_entries USING btree (logged_by_id);


--
-- Name: index_time_entries_on_ongoing; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entries_on_ongoing ON public.time_entries USING btree (ongoing);


--
-- Name: index_time_entries_on_project_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entries_on_project_id_and_updated_at ON public.time_entries USING btree (project_id, updated_at);


--
-- Name: index_time_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entries_on_user_id ON public.time_entries USING btree (user_id);


--
-- Name: index_time_entries_on_user_id_and_ongoing; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_time_entries_on_user_id_and_ongoing ON public.time_entries USING btree (user_id, ongoing) WHERE (ongoing = true);


--
-- Name: index_time_entry_activities_projects_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entry_activities_projects_on_active ON public.time_entry_activities_projects USING btree (active);


--
-- Name: index_time_entry_activities_projects_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entry_activities_projects_on_activity_id ON public.time_entry_activities_projects USING btree (activity_id);


--
-- Name: index_time_entry_activities_projects_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entry_activities_projects_on_project_id ON public.time_entry_activities_projects USING btree (project_id);


--
-- Name: index_time_entry_journals_on_logged_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entry_journals_on_logged_by_id ON public.time_entry_journals USING btree (logged_by_id);


--
-- Name: index_time_entry_journals_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_entry_journals_on_project_id ON public.time_entry_journals USING btree (project_id);


--
-- Name: index_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_user_id ON public.tokens USING btree (user_id);


--
-- Name: index_two_factor_authentication_devices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_two_factor_authentication_devices_on_user_id ON public.two_factor_authentication_devices USING btree (user_id);


--
-- Name: index_two_factor_authentication_devices_on_webauthn_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_two_factor_authentication_devices_on_webauthn_external_id ON public.two_factor_authentication_devices USING btree (webauthn_external_id);


--
-- Name: index_types_on_color_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_types_on_color_id ON public.types USING btree (color_id);


--
-- Name: index_user_passwords_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_passwords_on_user_id ON public.user_passwords USING btree (user_id);


--
-- Name: index_user_preferences_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_preferences_on_user_id ON public.user_preferences USING btree (user_id);


--
-- Name: index_user_prefs_settings_daily_reminders_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_prefs_settings_daily_reminders_enabled ON public.user_preferences USING gin ((((settings -> 'daily_reminders'::text) -> 'enabled'::text)));


--
-- Name: index_user_prefs_settings_daily_reminders_times; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_prefs_settings_daily_reminders_times ON public.user_preferences USING gin ((((settings -> 'daily_reminders'::text) -> 'times'::text)));


--
-- Name: index_user_prefs_settings_pause_reminders_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_prefs_settings_pause_reminders_enabled ON public.user_preferences USING btree (((((settings -> 'pause_reminders'::text) ->> 'enabled'::text))::boolean));


--
-- Name: index_user_prefs_settings_time_zone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_prefs_settings_time_zone ON public.user_preferences USING gin (((settings -> 'time_zone'::text)));


--
-- Name: index_user_prefs_settings_workdays; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_prefs_settings_workdays ON public.user_preferences USING gin (((settings -> 'workdays'::text)));


--
-- Name: index_users_on_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_id_and_type ON public.users USING btree (id, type);


--
-- Name: index_users_on_ldap_auth_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_ldap_auth_source_id ON public.users USING btree (ldap_auth_source_id);


--
-- Name: index_users_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_type ON public.users USING btree (type);


--
-- Name: index_users_on_type_and_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_type_and_login ON public.users USING btree (type, login);


--
-- Name: index_users_on_type_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_type_and_status ON public.users USING btree (type, status);


--
-- Name: index_version_settings_on_project_id_and_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_settings_on_project_id_and_version_id ON public.version_settings USING btree (project_id, version_id);


--
-- Name: index_versions_on_sharing; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_sharing ON public.versions USING btree (sharing);


--
-- Name: index_views_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_views_on_query_id ON public.views USING btree (query_id);


--
-- Name: index_watchers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_watchers_on_user_id ON public.watchers USING btree (user_id);


--
-- Name: index_watchers_on_watchable_id_and_watchable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_watchers_on_watchable_id_and_watchable_type ON public.watchers USING btree (watchable_id, watchable_type);


--
-- Name: index_webhooks_events_on_webhooks_webhook_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhooks_events_on_webhooks_webhook_id ON public.webhooks_events USING btree (webhooks_webhook_id);


--
-- Name: index_webhooks_logs_on_webhooks_webhook_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhooks_logs_on_webhooks_webhook_id ON public.webhooks_logs USING btree (webhooks_webhook_id);


--
-- Name: index_webhooks_projects_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhooks_projects_on_project_id ON public.webhooks_projects USING btree (project_id);


--
-- Name: index_webhooks_projects_on_webhooks_webhook_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhooks_projects_on_webhooks_webhook_id ON public.webhooks_projects USING btree (webhooks_webhook_id);


--
-- Name: index_wiki_pages_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_author_id ON public.wiki_pages USING btree (author_id);


--
-- Name: index_wiki_pages_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_parent_id ON public.wiki_pages USING btree (parent_id);


--
-- Name: index_wiki_pages_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_updated_at ON public.wiki_pages USING btree (updated_at);


--
-- Name: index_wiki_pages_on_wiki_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_wiki_id ON public.wiki_pages USING btree (wiki_id);


--
-- Name: index_wiki_redirects_on_wiki_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_redirects_on_wiki_id ON public.wiki_redirects USING btree (wiki_id);


--
-- Name: index_work_package_journals_on_assigned_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_assigned_to_id ON public.work_package_journals USING btree (assigned_to_id);


--
-- Name: index_work_package_journals_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_author_id ON public.work_package_journals USING btree (author_id);


--
-- Name: index_work_package_journals_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_category_id ON public.work_package_journals USING btree (category_id);


--
-- Name: index_work_package_journals_on_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_due_date ON public.work_package_journals USING btree (due_date);


--
-- Name: index_work_package_journals_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_parent_id ON public.work_package_journals USING btree (parent_id);


--
-- Name: index_work_package_journals_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_project_id ON public.work_package_journals USING btree (project_id);


--
-- Name: index_work_package_journals_on_responsible_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_responsible_id ON public.work_package_journals USING btree (responsible_id);


--
-- Name: index_work_package_journals_on_schedule_manually; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_schedule_manually ON public.work_package_journals USING btree (schedule_manually);


--
-- Name: index_work_package_journals_on_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_start_date ON public.work_package_journals USING btree (start_date);


--
-- Name: index_work_package_journals_on_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_status_id ON public.work_package_journals USING btree (status_id);


--
-- Name: index_work_package_journals_on_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_type_id ON public.work_package_journals USING btree (type_id);


--
-- Name: index_work_package_journals_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_package_journals_on_version_id ON public.work_package_journals USING btree (version_id);


--
-- Name: index_work_packages_on_assigned_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_assigned_to_id ON public.work_packages USING btree (assigned_to_id);


--
-- Name: index_work_packages_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_author_id ON public.work_packages USING btree (author_id);


--
-- Name: index_work_packages_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_category_id ON public.work_packages USING btree (category_id);


--
-- Name: index_work_packages_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_created_at ON public.work_packages USING btree (created_at);


--
-- Name: index_work_packages_on_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_due_date ON public.work_packages USING btree (due_date);


--
-- Name: index_work_packages_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_parent_id ON public.work_packages USING btree (parent_id);


--
-- Name: index_work_packages_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_project_id ON public.work_packages USING btree (project_id);


--
-- Name: index_work_packages_on_project_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_project_id_and_updated_at ON public.work_packages USING btree (project_id, updated_at);


--
-- Name: index_work_packages_on_project_life_cycle_step_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_project_life_cycle_step_id ON public.work_packages USING btree (project_life_cycle_step_id);


--
-- Name: index_work_packages_on_responsible_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_responsible_id ON public.work_packages USING btree (responsible_id);


--
-- Name: index_work_packages_on_schedule_manually; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_schedule_manually ON public.work_packages USING btree (schedule_manually) WHERE schedule_manually;


--
-- Name: index_work_packages_on_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_start_date ON public.work_packages USING btree (start_date);


--
-- Name: index_work_packages_on_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_status_id ON public.work_packages USING btree (status_id);


--
-- Name: index_work_packages_on_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_type_id ON public.work_packages USING btree (type_id);


--
-- Name: index_work_packages_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_updated_at ON public.work_packages USING btree (updated_at);


--
-- Name: index_work_packages_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_packages_on_version_id ON public.work_packages USING btree (version_id);


--
-- Name: index_workflows_on_new_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflows_on_new_status_id ON public.workflows USING btree (new_status_id);


--
-- Name: index_workflows_on_old_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflows_on_old_status_id ON public.workflows USING btree (old_status_id);


--
-- Name: index_workflows_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflows_on_role_id ON public.workflows USING btree (role_id);


--
-- Name: issue_categories_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX issue_categories_project_id ON public.categories USING btree (project_id);


--
-- Name: item_anc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX item_anc_desc_idx ON public.hierarchical_item_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: item_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX item_desc_idx ON public.hierarchical_item_hierarchies USING btree (descendant_id);


--
-- Name: messages_board_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_board_id ON public.messages USING btree (forum_id);


--
-- Name: messages_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_parent_id ON public.messages USING btree (parent_id);


--
-- Name: news_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX news_project_id ON public.news USING btree (project_id);


--
-- Name: projects_types_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_types_project_id ON public.projects_types USING btree (project_id);


--
-- Name: projects_types_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX projects_types_unique ON public.projects_types USING btree (project_id, type_id);


--
-- Name: time_entries_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX time_entries_issue_id ON public.time_entries USING btree (work_package_id);


--
-- Name: time_entries_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX time_entries_project_id ON public.time_entries USING btree (project_id);


--
-- Name: unique_index_gh_prs_wps_on_gh_pr_id_and_wp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_index_gh_prs_wps_on_gh_pr_id_and_wp_id ON public.github_pull_requests_work_packages USING btree (github_pull_request_id, work_package_id);


--
-- Name: unique_index_gl_issues_wps_on_gl_issue_id_and_wp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_index_gl_issues_wps_on_gl_issue_id_and_wp_id ON public.gitlab_issues_work_packages USING btree (gitlab_issue_id, work_package_id);


--
-- Name: unique_index_gl_mrs_wps_on_gl_mr_id_and_wp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_index_gl_mrs_wps_on_gl_mr_id_and_wp_id ON public.gitlab_merge_requests_work_packages USING btree (gitlab_merge_request_id, work_package_id);


--
-- Name: unique_inherited_role; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_inherited_role ON public.member_roles USING btree (member_id, role_id, inherited_from);


--
-- Name: unique_lastname_for_groups_and_placeholder_users; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_lastname_for_groups_and_placeholder_users ON public.users USING btree (lastname, type) WHERE (((type)::text = 'Group'::text) OR ((type)::text = 'PlaceholderUser'::text));


--
-- Name: versions_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_project_id ON public.versions USING btree (project_id);


--
-- Name: watchers_user_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX watchers_user_id_type ON public.watchers USING btree (user_id, watchable_type);


--
-- Name: wiki_pages_wiki_id_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX wiki_pages_wiki_id_slug ON public.wiki_pages USING btree (wiki_id, slug);


--
-- Name: wiki_pages_wiki_id_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wiki_pages_wiki_id_title ON public.wiki_pages USING btree (wiki_id, title);


--
-- Name: wiki_redirects_wiki_id_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wiki_redirects_wiki_id_title ON public.wiki_redirects USING btree (wiki_id, title);


--
-- Name: wikis_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wikis_project_id ON public.wikis USING btree (project_id);


--
-- Name: wkfs_role_type_old_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wkfs_role_type_old_status ON public.workflows USING btree (role_id, type_id, old_status_id);


--
-- Name: work_package_anc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX work_package_anc_desc_idx ON public.work_package_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: work_package_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX work_package_desc_idx ON public.work_package_hierarchies USING btree (descendant_id);


--
-- Name: work_package_journal_on_burndown_attributes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX work_package_journal_on_burndown_attributes ON public.work_package_journals USING btree (version_id, status_id, project_id, type_id);


--
-- Name: project_storages fk_rails_04546d7b88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_storages
    ADD CONSTRAINT fk_rails_04546d7b88 FOREIGN KEY (storage_id) REFERENCES public.storages(id) ON DELETE CASCADE;


--
-- Name: bcf_comments fk_rails_0571c4b386; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_comments
    ADD CONSTRAINT fk_rails_0571c4b386 FOREIGN KEY (reply_to) REFERENCES public.bcf_comments(id) ON DELETE SET NULL;


--
-- Name: notifications fk_rails_06a39bb8cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_06a39bb8cc FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: meeting_agenda_items fk_rails_06b94602d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_items
    ADD CONSTRAINT fk_rails_06b94602d9 FOREIGN KEY (presenter_id) REFERENCES public.users(id);


--
-- Name: two_factor_authentication_devices fk_rails_0b09e132e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.two_factor_authentication_devices
    ADD CONSTRAINT fk_rails_0b09e132e7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: workflows fk_rails_0c5f149c21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT fk_rails_0c5f149c21 FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification_settings fk_rails_0c95e91db7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT fk_rails_0c95e91db7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: cost_entries fk_rails_0d35f09506; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cost_entries
    ADD CONSTRAINT fk_rails_0d35f09506 FOREIGN KEY (logged_by_id) REFERENCES public.users(id);


--
-- Name: custom_fields_projects fk_rails_12fb30588e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields_projects
    ADD CONSTRAINT fk_rails_12fb30588e FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oidc_user_tokens fk_rails_1571e35480; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_user_tokens
    ADD CONSTRAINT fk_rails_1571e35480 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: remote_identities fk_rails_19e47f842b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remote_identities
    ADD CONSTRAINT fk_rails_19e47f842b FOREIGN KEY (oauth_client_id) REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: project_custom_field_project_mappings fk_rails_1a1f3f10e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_custom_field_project_mappings
    ADD CONSTRAINT fk_rails_1a1f3f10e9 FOREIGN KEY (custom_field_id) REFERENCES public.custom_fields(id);


--
-- Name: workflows fk_rails_2a8f410364; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT fk_rails_2a8f410364 FOREIGN KEY (type_id) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oauth_applications fk_rails_3d1f3b58d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT fk_rails_3d1f3b58d2 FOREIGN KEY (client_credentials_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: meeting_agenda_items fk_rails_3f56abf49c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_items
    ADD CONSTRAINT fk_rails_3f56abf49c FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: wiki_pages fk_rails_4189064f3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages
    ADD CONSTRAINT fk_rails_4189064f3f FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: reminder_notifications fk_rails_4398e72474; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminder_notifications
    ADD CONSTRAINT fk_rails_4398e72474 FOREIGN KEY (reminder_id) REFERENCES public.reminders(id);


--
-- Name: ldap_groups_synchronized_groups fk_rails_44dac1537e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ldap_groups_synchronized_groups
    ADD CONSTRAINT fk_rails_44dac1537e FOREIGN KEY (filter_id) REFERENCES public.ldap_groups_synchronized_filters(id);


--
-- Name: types fk_rails_46ceaf0e5b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.types
    ADD CONSTRAINT fk_rails_46ceaf0e5b FOREIGN KEY (color_id) REFERENCES public.colors(id) ON DELETE SET NULL;


--
-- Name: notification_settings fk_rails_496a500fda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT fk_rails_496a500fda FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: notifications fk_rails_4aea6afa11; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_4aea6afa11 FOREIGN KEY (recipient_id) REFERENCES public.users(id);


--
-- Name: project_life_cycle_step_definitions fk_rails_4b9851fb8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_life_cycle_step_definitions
    ADD CONSTRAINT fk_rails_4b9851fb8b FOREIGN KEY (color_id) REFERENCES public.colors(id);


--
-- Name: reminder_notifications fk_rails_4db3d8d95d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminder_notifications
    ADD CONSTRAINT fk_rails_4db3d8d95d FOREIGN KEY (notification_id) REFERENCES public.notifications(id);


--
-- Name: bcf_issues fk_rails_4e35bc3056; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_issues
    ADD CONSTRAINT fk_rails_4e35bc3056 FOREIGN KEY (work_package_id) REFERENCES public.work_packages(id) ON DELETE CASCADE;


--
-- Name: ifc_models fk_rails_4f53d4601c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ifc_models
    ADD CONSTRAINT fk_rails_4f53d4601c FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: webhooks_logs fk_rails_551257cdac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_logs
    ADD CONSTRAINT fk_rails_551257cdac FOREIGN KEY (webhooks_webhook_id) REFERENCES public.webhooks_webhooks(id) ON DELETE CASCADE;


--
-- Name: bcf_comments fk_rails_556ef6e73e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_comments
    ADD CONSTRAINT fk_rails_556ef6e73e FOREIGN KEY (viewpoint_id) REFERENCES public.bcf_viewpoints(id) ON DELETE SET NULL;


--
-- Name: notifications fk_rails_595318131c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_595318131c FOREIGN KEY (journal_id) REFERENCES public.journals(id) ON DELETE CASCADE;


--
-- Name: time_entry_activities_projects fk_rails_5b669d4f34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entry_activities_projects
    ADD CONSTRAINT fk_rails_5b669d4f34 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: oidc_user_session_links fk_rails_5e6a849f92; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oidc_user_session_links
    ADD CONSTRAINT fk_rails_5e6a849f92 FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: work_packages fk_rails_5edb6f06e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_packages
    ADD CONSTRAINT fk_rails_5edb6f06e6 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: meeting_sections fk_rails_613c652e16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_sections
    ADD CONSTRAINT fk_rails_613c652e16 FOREIGN KEY (meeting_id) REFERENCES public.meetings(id);


--
-- Name: file_links fk_rails_650ebb2e1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_links
    ADD CONSTRAINT fk_rails_650ebb2e1a FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: oauth_client_tokens fk_rails_65a92bfbf4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_client_tokens
    ADD CONSTRAINT fk_rails_65a92bfbf4 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workflows fk_rails_66af376b7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT fk_rails_66af376b7e FOREIGN KEY (new_status_id) REFERENCES public.statuses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: storages fk_rails_6c69bacb8d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages
    ADD CONSTRAINT fk_rails_6c69bacb8d FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: oauth_client_tokens fk_rails_6e922d4135; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_client_tokens
    ADD CONSTRAINT fk_rails_6e922d4135 FOREIGN KEY (oauth_client_id) REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: time_entries fk_rails_709864c72f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entries
    ADD CONSTRAINT fk_rails_709864c72f FOREIGN KEY (logged_by_id) REFERENCES public.users(id);


--
-- Name: recurring_meetings fk_rails_718ca7b915; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_meetings
    ADD CONSTRAINT fk_rails_718ca7b915 FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: last_project_folders fk_rails_73e1c678f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.last_project_folders
    ADD CONSTRAINT fk_rails_73e1c678f1 FOREIGN KEY (project_storage_id) REFERENCES public.project_storages(id) ON DELETE CASCADE;


--
-- Name: project_custom_field_project_mappings fk_rails_79aa0057e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_custom_field_project_mappings
    ADD CONSTRAINT fk_rails_79aa0057e4 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: bcf_comments fk_rails_7ac870008c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_comments
    ADD CONSTRAINT fk_rails_7ac870008c FOREIGN KEY (issue_id) REFERENCES public.bcf_issues(id) ON DELETE CASCADE;


--
-- Name: projects_types fk_rails_7c3935a107; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_types
    ADD CONSTRAINT fk_rails_7c3935a107 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: remote_identities fk_rails_7f8585fc1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remote_identities
    ADD CONSTRAINT fk_rails_7f8585fc1a FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: emoji_reactions fk_rails_80a9e7c3ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emoji_reactions
    ADD CONSTRAINT fk_rails_80a9e7c3ce FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: project_life_cycle_steps fk_rails_81938d1823; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_life_cycle_steps
    ADD CONSTRAINT fk_rails_81938d1823 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: recaptcha_entries fk_rails_890a90efa9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recaptcha_entries
    ADD CONSTRAINT fk_rails_890a90efa9 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: meeting_agenda_items fk_rails_9089886cdd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_items
    ADD CONSTRAINT fk_rails_9089886cdd FOREIGN KEY (meeting_id) REFERENCES public.meetings(id);


--
-- Name: work_packages fk_rails_931ad309e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_packages
    ADD CONSTRAINT fk_rails_931ad309e8 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: project_storages fk_rails_96ab713fe3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_storages
    ADD CONSTRAINT fk_rails_96ab713fe3 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: meeting_agenda_item_journals fk_rails_9b6296a185; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_agenda_item_journals
    ADD CONSTRAINT fk_rails_9b6296a185 FOREIGN KEY (presenter_id) REFERENCES public.users(id);


--
-- Name: recurring_meetings fk_rails_a0ea141e10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_meetings
    ADD CONSTRAINT fk_rails_a0ea141e10 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: webhooks_events fk_rails_a166925c91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_events
    ADD CONSTRAINT fk_rails_a166925c91 FOREIGN KEY (webhooks_webhook_id) REFERENCES public.webhooks_webhooks(id);


--
-- Name: file_links fk_rails_a29c1fb981; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_links
    ADD CONSTRAINT fk_rails_a29c1fb981 FOREIGN KEY (storage_id) REFERENCES public.storages(id) ON DELETE CASCADE;


--
-- Name: project_life_cycle_steps fk_rails_abc065fdb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_life_cycle_steps
    ADD CONSTRAINT fk_rails_abc065fdb1 FOREIGN KEY (definition_id) REFERENCES public.project_life_cycle_step_definitions(id);


--
-- Name: tokens fk_rails_ac8a5d0441; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT fk_rails_ac8a5d0441 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: project_storages fk_rails_acca00a591; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_storages
    ADD CONSTRAINT fk_rails_acca00a591 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: workflows fk_rails_b4628cffdf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT fk_rails_b4628cffdf FOREIGN KEY (old_status_id) REFERENCES public.statuses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: reminders fk_rails_b7e32f12b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT fk_rails_b7e32f12b2 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: time_entry_activities_projects fk_rails_bc6c409022; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entry_activities_projects
    ADD CONSTRAINT fk_rails_bc6c409022 FOREIGN KEY (activity_id) REFERENCES public.enumerations(id);


--
-- Name: hierarchical_items fk_rails_c67cbe751d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hierarchical_items
    ADD CONSTRAINT fk_rails_c67cbe751d FOREIGN KEY (custom_field_id) REFERENCES public.custom_fields(id);


--
-- Name: scheduled_meetings fk_rails_c79817dc8f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_meetings
    ADD CONSTRAINT fk_rails_c79817dc8f FOREIGN KEY (meeting_id) REFERENCES public.meetings(id) ON DELETE SET NULL;


--
-- Name: oauth_applications fk_rails_cc886e315a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT fk_rails_cc886e315a FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: favorites fk_rails_d15744e438; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_d15744e438 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: webhooks_projects fk_rails_d7ea5de5b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_projects
    ADD CONSTRAINT fk_rails_d7ea5de5b8 FOREIGN KEY (webhooks_webhook_id) REFERENCES public.webhooks_webhooks(id);


--
-- Name: projects_types fk_rails_da213a0c8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_types
    ADD CONSTRAINT fk_rails_da213a0c8b FOREIGN KEY (type_id) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_meetings fk_rails_dde1b994c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_meetings
    ADD CONSTRAINT fk_rails_dde1b994c5 FOREIGN KEY (recurring_meeting_id) REFERENCES public.recurring_meetings(id) ON DELETE CASCADE;


--
-- Name: storages_file_links_journals fk_rails_e007095e78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages_file_links_journals
    ADD CONSTRAINT fk_rails_e007095e78 FOREIGN KEY (journal_id) REFERENCES public.journals(id);


--
-- Name: ical_token_query_assignments fk_rails_e0ecbb71e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ical_token_query_assignments
    ADD CONSTRAINT fk_rails_e0ecbb71e6 FOREIGN KEY (ical_token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: custom_fields_projects fk_rails_e51cefe60d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields_projects
    ADD CONSTRAINT fk_rails_e51cefe60d FOREIGN KEY (custom_field_id) REFERENCES public.custom_fields(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: webhooks_projects fk_rails_e978b5e3d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks_projects
    ADD CONSTRAINT fk_rails_e978b5e3d7 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: ordered_work_packages fk_rails_e99c4d5dfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordered_work_packages
    ADD CONSTRAINT fk_rails_e99c4d5dfe FOREIGN KEY (query_id) REFERENCES public.queries(id) ON DELETE CASCADE;


--
-- Name: auth_providers fk_rails_e9bd348863; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_providers
    ADD CONSTRAINT fk_rails_e9bd348863 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: views fk_rails_ef3c430897; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT fk_rails_ef3c430897 FOREIGN KEY (query_id) REFERENCES public.queries(id);


--
-- Name: work_packages fk_rails_f2a8977aa1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_packages
    ADD CONSTRAINT fk_rails_f2a8977aa1 FOREIGN KEY (type_id) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ical_token_query_assignments fk_rails_f5e934437b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ical_token_query_assignments
    ADD CONSTRAINT fk_rails_f5e934437b FOREIGN KEY (query_id) REFERENCES public.queries(id) ON DELETE CASCADE;


--
-- Name: time_entry_journals fk_rails_f6e3d60ab5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_entry_journals
    ADD CONSTRAINT fk_rails_f6e3d60ab5 FOREIGN KEY (logged_by_id) REFERENCES public.users(id);


--
-- Name: bcf_viewpoints fk_rails_fa5c88e5be; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcf_viewpoints
    ADD CONSTRAINT fk_rails_fa5c88e5be FOREIGN KEY (issue_id) REFERENCES public.bcf_issues(id) ON DELETE CASCADE;


--
-- Name: ordered_work_packages fk_rails_fe038e4e03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordered_work_packages
    ADD CONSTRAINT fk_rails_fe038e4e03 FOREIGN KEY (work_package_id) REFERENCES public.work_packages(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250128164217'),
('20250117105334'),
('20250115100336'),
('20250108100511'),
('20250102161733'),
('20241217190533'),
('20241212131910'),
('20241211152749'),
('20241202112409'),
('20241202112408'),
('20241202112407'),
('20241202112406'),
('20241129135602'),
('20241128190428'),
('20241127161228'),
('20241126111225'),
('20241125161226'),
('20241125104347'),
('20241122143600'),
('20241121113638'),
('20241121094113'),
('20241120103858'),
('20241119131205'),
('20241030154245'),
('20241025072902'),
('20241015081341'),
('20241002151949'),
('20241001205821'),
('20240930122522'),
('20240924114246'),
('20240920152544'),
('20240917105829'),
('20240909151818'),
('20240829140616'),
('20240821121856'),
('20240820123011'),
('20240813131647'),
('20240808133947'),
('20240808125617'),
('20240806144333'),
('20240805104004'),
('20240801105918'),
('20240715183144'),
('20240703131639'),
('20240625075139'),
('20240624103354'),
('20240620115412'),
('20240611105232'),
('20240610130953'),
('20240527070439'),
('20240522073759'),
('20240519123921'),
('20240516102219'),
('20240513135928'),
('20240506091102'),
('20240502081436'),
('20240501093751'),
('20240501083852'),
('20240430143313'),
('20240426073948'),
('20240424160513'),
('20240424093311'),
('20240422141623'),
('20240418110249'),
('20240410060041'),
('20240408161233'),
('20240408132459'),
('20240408093541'),
('20240405135016'),
('20240405131352'),
('20240404074025'),
('20240402072213'),
('20240402065214'),
('20240328154805'),
('20240325150312'),
('20240313102951'),
('20240311111957'),
('20240307190126'),
('20240307102541'),
('20240307094432'),
('20240306154737'),
('20240306154736'),
('20240306154735'),
('20240306154734'),
('20240306083241'),
('20240229133250'),
('20240227154544'),
('20240222155909'),
('20240208100316'),
('20240207075946'),
('20240206173841'),
('20240206085104'),
('20240201115019'),
('20240131130149'),
('20240131130134'),
('20240123151252'),
('20240123151251'),
('20240123151250'),
('20240123151249'),
('20240123151248'),
('20240123151247'),
('20240123151246'),
('20240116165933'),
('20240115112549'),
('20240104172050'),
('20231227100753'),
('20231212131603'),
('20231208143303'),
('20231205143648'),
('20231201085450'),
('20231128080650'),
('20231123111357'),
('20231119192222'),
('20231109080454'),
('20231105194747'),
('20231031133334'),
('20231027102747'),
('20231026111049'),
('20231025144701'),
('20231024150429'),
('20231020154219'),
('20231017093339'),
('20231013114720'),
('20231012124745'),
('20231009135807'),
('20231005113307'),
('20231003151656'),
('20231002141527'),
('20230918135247'),
('20230912185647'),
('20230911102918'),
('20230911093530'),
('20230905126002'),
('20230905090205'),
('20230829151629'),
('20230829122717'),
('20230824130730'),
('20230823113310'),
('20230816141222'),
('20230810074642'),
('20230808140921'),
('20230808080001'),
('20230803113215'),
('20230802085026'),
('20230731153909'),
('20230726112130'),
('20230726061920'),
('20230725165505'),
('20230721123022'),
('20230718084649'),
('20230717104700'),
('20230713144232'),
('20230627133534'),
('20230622074222'),
('20230613155001'),
('20230608151123'),
('20230607101213'),
('20230606083221'),
('20230601082746'),
('20230531093004'),
('20230517075214'),
('20230512153303'),
('20230508150835'),
('20230502094813'),
('20230421154500'),
('20230420071113'),
('20230420063148'),
('20230328154645'),
('20230322135932'),
('20230321194150'),
('20230316080525'),
('20230315184533'),
('20230315183431'),
('20230315103437'),
('20230314165213'),
('20230314093106'),
('20230309104056'),
('20230306083203'),
('20230130134630'),
('20230123092649'),
('20230105134940'),
('20230105073117'),
('20221213092910'),
('20221202130039'),
('20221201140825'),
('20221130150352'),
('20221129074635'),
('20221122072857'),
('20221115082403'),
('20221029194419'),
('20221028070534'),
('20221027151959'),
('20221026132134'),
('20221018160449'),
('20221017184204'),
('20221017073431'),
('20220930133418'),
('20220929114423'),
('20220926124435'),
('20220922200908'),
('20220918165443'),
('20220911182835'),
('20220909153412'),
('20220831081937'),
('20220831073113'),
('20220830092057'),
('20220830074821'),
('20220818074159'),
('20220818074150'),
('20220817154403'),
('20220815072420'),
('20220811061024'),
('20220804112533'),
('20220714145356'),
('20220712165928'),
('20220712132505'),
('20220707192304'),
('20220629073727'),
('20220629061540'),
('20220622151721'),
('20220620132922'),
('20220615213015'),
('20220614132200'),
('20220608213712'),
('20220525154549'),
('20220518154147'),
('20220517113828'),
('20220511124930'),
('20220503093844'),
('20220428071221'),
('20220426132637'),
('20220414085531'),
('20220408080838'),
('20220323083000'),
('20220319211253'),
('20220302123642'),
('20220223095355'),
('20220202140507'),
('20220121090847'),
('20220113144759'),
('20220113144323'),
('20220106145037'),
('20211209092519'),
('20211130161501'),
('20211118203332'),
('20211117195121'),
('20211104151329'),
('20211103120946'),
('20211102161932'),
('20211101152840'),
('20211026061420'),
('20211022143726'),
('20211015110002'),
('20211015110001'),
('20211015110000'),
('20211011204301'),
('20211005135637'),
('20211005080304'),
('20210928133538'),
('20210922123908'),
('20210917190141'),
('20210915154656'),
('20210914065555'),
('20210910092414'),
('20210902201126'),
('20210825183540'),
('20210802114054'),
('20210726070813'),
('20210726065912'),
('20210713081724'),
('20210701082511'),
('20210701073944'),
('20210628185054'),
('20210618132206'),
('20210618125430'),
('20210616191052'),
('20210616145324'),
('20210615150558'),
('20210521080035'),
('20210519141244'),
('20210512121322'),
('20210510193438'),
('20210427065703'),
('20210407110000'),
('20210331085058'),
('20210310101840'),
('20210221230446'),
('20210219092709'),
('20210214205545'),
('20210127134438'),
('20210126112238'),
('20201125121949'),
('20201105154216'),
('20201005184411'),
('20201005120137'),
('20201001184404'),
('20200925084550'),
('20200924085508'),
('20200914092212'),
('20200907090753'),
('20200903064009'),
('20200820140526'),
('20200810152654'),
('20200807083952'),
('20200807083950'),
('20200803081038'),
('20200708065116'),
('20200625133727'),
('20200610124259'),
('20200610083854'),
('20200527130633'),
('20200522140244'),
('20200522131255'),
('20200504085933'),
('20200428105404'),
('20200427121606'),
('20200427082928'),
('20200422105623'),
('20200420133116'),
('20200420122713'),
('20200415131633'),
('20200403105252'),
('20200327074416'),
('20200326102408'),
('20200325101528'),
('20200310092237'),
('20200302100431'),
('20200220171133'),
('20200217155632'),
('20200217090016'),
('20200217061622'),
('20200206101135'),
('20200123163818'),
('20200115090742'),
('20200114091135'),
('20191216135213'),
('20191121140202'),
('20191119144123'),
('20191115141154'),
('20191114090353'),
('20191112111040'),
('20191106132533'),
('20191029155327'),
('20190923123858'),
('20190923111902'),
('20190920102446'),
('20190905130336'),
('20190826083604'),
('20190823090211'),
('20190724093332'),
('20190722082648'),
('20190719123448'),
('20190716071941'),
('20190710132957'),
('20190619143049'),
('20190618115620'),
('20190603060951'),
('20190527095959'),
('20190509071101'),
('20190507132517'),
('20190502102512'),
('20190411122815'),
('20190312083304'),
('20190301122554'),
('20190227163226'),
('20190220080647'),
('20190207155607'),
('20190205090102'),
('20190129083842'),
('20190124081710'),
('20181214103300'),
('20181121174153'),
('20181118193730'),
('20181112125034'),
('20181101132712'),
('20180924141838'),
('20180903110212'),
('20180830120550'),
('20180801072018'),
('20180717102331'),
('20180706150714'),
('20180524113516'),
('20180524084654'),
('20180518130559'),
('20180510184732'),
('20180504144320'),
('20180419061910'),
('20180323151208'),
('20180323140208'),
('20180323135408'),
('20180323133404'),
('20180323130704'),
('20180305130811'),
('20180221151038'),
('20180213155320'),
('20180125082205'),
('20180123092002'),
('20180122135443'),
('20180117065255'),
('20180116065518'),
('20180108132929'),
('20180105130053'),
('20171219145752'),
('20171218205557'),
('20171129145631'),
('20171106074835'),
('20171023190036'),
('20170829095701'),
('20170818063404'),
('20170705134348'),
('20170703075208'),
('20160331190036'),
('20130214130336'),
('20120214103300'),
('20100528100562'),
('10000000000000');

