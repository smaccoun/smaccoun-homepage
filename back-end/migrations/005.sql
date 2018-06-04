CREATE TABLE public.blog_post_tags
(
    blog_post_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    CONSTRAINT blog_post_tags_blog_posts_id_fk FOREIGN KEY (blog_post_id) REFERENCES blog_posts (id),
    CONSTRAINT blog_post_tags_tags_id_fk FOREIGN KEY (tag_id) REFERENCES tags (id)
);

CREATE OR REPLACE FUNCTION mk_blog_post(
  p_title TEXT,
  p_content TEXT,
  p_submit_status TEXT,
  p_tags TEXT[]
)
RETURNS TABLE(
   r_id UUID
  ,r_title TEXT
  ,r_content TEXT
  ,r_submit_status TEXT
  ,r_tags TEXT[]
  ,r_updated_at TIMESTAMP WITH TIME ZONE
  ,r_created_at TIMESTAMP WITH TIME ZONE
)
AS $$
  WITH
  all_tags AS
      ( SELECT unnest(p_tags) as a_tag
      ),
  tag_insert AS
      (INSERT INTO tags(name, updated_at)
        SELECT a_tag AS name, now() as updated_at
        FROM all_tags
        RETURNING id AS tag_id, name
      ),
  post_insert AS
      (INSERT INTO blog_posts (id, title, content, submit_status, created_at, updated_at)
          VALUES (default, p_title, p_content, p_submit_status, default, now())
       RETURNING *
      ),
  blog_post_tag_insert AS
    (INSERT INTO blog_post_tags (blog_post_id, tag_id)
     SELECT pi.id, ti.tag_id
     FROM post_insert pi
     CROSS JOIN tag_insert ti
     RETURNING blog_post_id, tag_id
    )
  SELECT
      bp.id
    , bp.title
    , bp.content
    , bp.submit_status
    , array_agg(t.name)
    , bp.updated_at
    , bp.created_at
  FROM post_insert bp
  JOIN blog_post_tag_insert bpi ON bpi.blog_post_id = bp.id
  JOIN tag_insert t ON t.tag_id = bpi.tag_id
  GROUP BY
      bp.id
    , bp.title
    , bp.content
    , bp.submit_status
    , bp.updated_at
    , bp.created_at
$$ LANGUAGE SQL;

CREATE OR REPLACE VIEW blog_post_vw AS
  SELECT
    bp.id
  , bp.title
  , bp.content
  , bp.submit_status
  , array_agg(t.name)
  , bp.updated_at
  , bp.created_at
  FROM blog_posts bp
  JOIN blog_post_tags bpt ON bp.id = bpt.blog_post_id
  JOIN tags t ON bpt.tag_id = t.id
  GROUP BY
      bp.id
    , bp.title
    , bp.content
    , bp.submit_status
    , bp.updated_at
    , bp.created_at;

