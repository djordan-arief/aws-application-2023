-- this file was manually created

INSERT INTO public.users(display_name, handle, cognito_user_id, email)
VALUES 
    ('Andrew Brown', 'andrewbrown', 'MOCK', 'andrew@exampro.com'),
    ('Andrew Bayko', 'bayko', 'MOCK', 'bayko@exampro.com');


INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES 
    (
        (SELECT uuid from public.users WHERE users.handle='andrewbrown' LIMIT 1),
        'This was imported as seed data',
        CURRENT_TIMESTAMP + interval '10 day'
    );