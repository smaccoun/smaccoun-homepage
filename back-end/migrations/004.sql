CREATE TABLE public.tags
(
    id            UUID DEFAULT gen_random_uuid()         NOT NULL
	    CONSTRAINT tags_pkey 
	    PRIMARY KEY,
    name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE
);
