-- Insert mock data for series and episodes for production
-- This migration adds four series with four episodes each

-- First Series: "Mommy Don't Cry"
INSERT INTO public.series (id, title, description, genre, cover_url, is_published)
VALUES (
  '1f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
  'Mommy Don''t Cry',
  'A heartbreaking tale of a mother''s sacrifice and resilience through difficult times. Follow this emotional journey as she navigates life''s challenges to protect her child.',
  'Drama',
  'https://d14c63magvk61v.cloudfront.net/mommy_dont_cry_cover.jpg',
  true
);

-- Episodes for "Mommy Don't Cry"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost)
VALUES
  (
    '2a1b87c3-9e5d-4a4b-8a2c-1c8f7a6c6f5e',
    '1f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    '01We3iVm55Xm99Vw02hr5aw7L9sODiOYbNhRvFfGhjMX8',
    'https://stream.mux.com/y49njZYGmdM35qp7L1S45uQ9s01QTUHYqUzJJfted5YA.m3u8',
    1,
    'free',
    NULL
  ),
  (
    '2a2b87c3-9e5d-4a4b-8a2c-2c8f7a6c6f5e',
    '1f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'upEGQzHrrkneYdGe00TJ2XK4cPhHjv22Jhn1tX578KmQ',
    'https://stream.mux.com/5oaQHrNFlOpI00iu8OPgM7GTiKIb3nEH2SZ9jWU2mn5w.m3u8',
    2,
    'free',
    NULL
  ),
  (
    '2a3b87c3-9e5d-4a4b-8a2c-3c8f7a6c6f5e',
    '1f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    '7kJyKlmpLLzXOW49JdR01j4DhSzQVKjSbPZXOP2DpGu8',
    'https://stream.mux.com/jun6nKPczRB2LYWrCC65ex7gi3zT1WrGEtP9iYBEWOc.m3u8',
    3,
    'vip',
    NULL
  ),
  (
    '2a4b87c3-9e5d-4a4b-8a2c-4c8f7a6c6f5e',
    '1f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'GV302G1TpEgOVjza00a5v00Nx1DGEk5nzoz7bifENqEtFA',
    'https://stream.mux.com/9QdXDUeYFLMCnPUAToIn7wtWuc3gUnPv6ih400kFOqQE.m3u8',
    4,
    'vip',
    NULL
  );

-- Second Series: "Childhood Sweethearts"
INSERT INTO public.series (id, title, description, genre, cover_url, is_published)
VALUES (
  '3f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
  'Childhood Sweethearts',
  'Two childhood friends reconnect years later only to discover their feelings never faded. Will their past history and current circumstances allow their love to blossom?',
  'Romance',
  'https://d14c63magvk61v.cloudfront.net/childhood_sweethearts_cover.jpg',
  true
);

-- Episodes for "Childhood Sweethearts"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost)
VALUES
  (
    '4a1b87c3-9e5d-4a4b-8a2c-1c8f7a6c6f5e',
    '3f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    '9B1smW8u00LrIpzMvb8aHCp7sGY22Dly1R3UW74UjliI',
    'https://stream.mux.com/Y6PNDpLo300upr7lwD01H01SvntIi8JsPVx35gNVS02qY2A.m3u8',
    1,
    'free',
    NULL
  ),
  (
    '4a2b87c3-9e5d-4a4b-8a2c-2c8f7a6c6f5e',
    '3f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'qUi600jKuItcKi00UFtsQA7J01oFU02SxFq00mUr4gyLuvu4',
    'https://stream.mux.com/85gSBDEq89DfrOa3xnjO94nCkrLQwBF6KiFHmHnXON8.m3u8',
    2,
    'free',
    NULL
  ),
  (
    '4a3b87c3-9e5d-4a4b-8a2c-3c8f7a6c6f5e',
    '3f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'lq01IO16EVcdbsc2kO5K4rRdUFjIiWZcqGyKUnh7Ftw00',
    'https://stream.mux.com/gjGwfMX2Au01ZB401ZlameOUvOsv69h3eErECWq7FC6aY.m3u8',
    3,
    'vip',
    NULL
  ),
  (
    '4a4b87c3-9e5d-4a4b-8a2c-4c8f7a6c6f5e',
    '3f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'JS6ArEUWp9TNgok8ALtmO01wQkS00u900K2naJzuAMmREY',
    'https://stream.mux.com/E4zHCTr00wXgojal2qy2vEIGXJA3w02FGW302lNoz8tdt8.m3u8',
    4,
    'vip',
    NULL
  );

-- Third Series: "CEO Daddy"
INSERT INTO public.series (id, title, description, genre, cover_url, is_published)
VALUES (
  '5f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
  'CEO Daddy',
  'A high-powered CEO discovers he has a young daughter he never knew about. Watch as he navigates the challenges of sudden fatherhood while running his empire.',
  'Family',
  'https://d14c63magvk61v.cloudfront.net/ceo_daddy_cover.jpg',
  true
);

-- Episodes for "CEO Daddy"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost)
VALUES
  (
    '6a1b87c3-9e5d-4a4b-8a2c-1c8f7a6c6f5e',
    '5f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'pPbvFdpIuu5fg00Y800pm00ryYm5htqkxNQgonTgjVqKeE',
    'https://stream.mux.com/tB5ld01b00R4eyTTK8eCdv7KYfwarpbz8huvIGiqdTBk8.m3u8',
    1,
    'free',
    NULL
  ),
  (
    '6a2b87c3-9e5d-4a4b-8a2c-2c8f7a6c6f5e',
    '5f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'lHLLYVZzw1lHBpk00lekgkNWAS8js00cS01PZEKHIqUjv00',
    'https://stream.mux.com/WxOSX302KVEbvys7IjV7NHi6zyT78CjGK8yWbMBm9C7Q.m3u8',
    2,
    'free',
    NULL
  ),
  (
    '6a3b87c3-9e5d-4a4b-8a2c-3c8f7a6c6f5e',
    '5f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'cV2bqFaHxcSnhLjoxGdKjTj00hdh72US029uRikmQ3zt00',
    'https://stream.mux.com/yL4y1j3PE1cTlqEsvHrUBd8YcSn2uxkEGWrp4ODC7jk.m3u8',
    3,
    'vip',
    NULL
  ),
  (
    '6a4b87c3-9e5d-4a4b-8a2c-4c8f7a6c6f5e',
    '5f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'cqf1KojgXV8J246U00G4tmI01dV02PJvI9HMYYUhzy6els',
    'https://stream.mux.com/01NB01pjLjGy02c8BiDsztKhWFKPSpwzB6KZYK9OfvJFMY.m3u8',
    4,
    'vip',
    NULL
  );

-- Fourth Series: "CEO Daddy Season 2"
INSERT INTO public.series (id, title, description, genre, cover_url, is_published)
VALUES (
  '7f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
  'CEO Daddy: Season 2',
  'The story continues as our CEO dad faces new challenges balancing his professional life with the joys and struggles of raising his daughter.',
  'Family',
  'https://d14c63magvk61v.cloudfront.net/ceo_daddy_s2_cover.jpg',
  true
);

-- Episodes for "CEO Daddy Season 2"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost)
VALUES
  (
    '8a1b87c3-9e5d-4a4b-8a2c-1c8f7a6c6f5e',
    '7f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'XgW953Zi79O5DtGvQrnRjXgqMlyisI01Lwkt01D8hFUyU',
    'https://stream.mux.com/b7r2JZOuSpM7OPDhjt9KV5y8A202Bn1s8slLcqvrHxxw.m3u8',
    1,
    'free',
    NULL
  ),
  (
    '8a2b87c3-9e5d-4a4b-8a2c-2c8f7a6c6f5e',
    '7f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'sHs1fHEvQ79C4xC76ToI94nyMaFTJNKDMi1CDKy8CSM',
    'https://stream.mux.com/3uLRT53pLLMbpcpPHff00FL8ER8Rkx5lxq01v81l9qd01o.m3u8',
    2,
    'vip',
    NULL
  ),
  (
    '8a3b87c3-9e5d-4a4b-8a2c-3c8f7a6c6f5e',
    '7f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'oMXYl3lhpj2KeUZhuEKYAm1OQrx8cnRkec23aB702ayI',
    'https://stream.mux.com/IgPbctK02FFm4mg3r85M7ApugMC00If006yWgHJYXJ5JlE.m3u8',
    3,
    'vip',
    NULL
  ),
  (
    '8a4b87c3-9e5d-4a4b-8a2c-4c8f7a6c6f5e',
    '7f5c87a3-7e5d-4a4b-8a2c-5c8f7a6c6f5e',
    'yTvWiF02lWOFWnp1THOvwWYVnQsTQ3pkQMHgduQCQG1g',
    'https://stream.mux.com/phMR00443kAKE4kpAbZ9N9jsOQHHzMCs8v00Vavbojjd00.m3u8',
    4,
    'vip',
    NULL
  ); 