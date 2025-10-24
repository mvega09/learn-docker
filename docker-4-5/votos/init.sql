CREATE TABLE IF NOT EXISTS poll_options (
    id SERIAL PRIMARY KEY,
    option_name VARCHAR(50) UNIQUE NOT NULL,
    vote_count INTEGER DEFAULT 0
);

INSERT INTO poll_options (option_name, vote_count) VALUES 
    ('Computer Vision', 0),
    ('Data', 0),
    ('ML', 0),
    ('Web', 0)
ON CONFLICT (option_name) DO NOTHING;