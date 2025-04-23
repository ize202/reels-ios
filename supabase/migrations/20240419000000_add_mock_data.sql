-- Migration: Add mock data for testing
-- Description: Creates a test series with 6 episodes
-- Author: Claude
-- Date: 2024-04-19

-- Create a test series
INSERT INTO public.series (id, title, description, genre, cover_url, is_published, created_at)
VALUES (
  'e4d2b180-de91-4d0e-9d35-0342b9b12a36', -- Fixed UUID for easy reference
  'Red Flags: New Beginnings',
  'After losing everything in a fire, Maya moves to a small coastal town to rebuild her life. But when mysterious incidents begin occurring in her new apartment, she discovers dark secrets about the town and its residents that will change her life forever.',
  'Drama/Mystery',
  'https://picsum.photos/seed/reels-drama/500/750', -- Placeholder image
  TRUE, -- Published
  NOW()
);

-- Add episodes to the series
-- Episode 1 (free)
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, created_at)
VALUES (
  '3a7ed1d5-a57b-4a56-8250-dffc23684ab1',
  'e4d2b180-de91-4d0e-9d35-0342b9b12a36',
  'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
  'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
  1,
  'free',
  NOW() - INTERVAL '7 days'
);

-- Episode 2 (free)
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, created_at)
VALUES (
  'b2c85e9a-3f39-4b9a-9e4c-9d5b4e8f1f0e',
  'e4d2b180-de91-4d0e-9d35-0342b9b12a36',
  'EeqU77wx2R008tSwCJ02UWwjyJkuE5plD5lCR02X5T5aeA',
  'https://stream.mux.com/a99mFdkBhVqKY02sKAagV00JpTjmj5nIohSrlCWWYvnAw.m3u8',
  2,
  'free',
  NOW() - INTERVAL '6 days'
);

-- Episode 3 (coin unlock)
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES (
  'c3d96f0b-4f4a-5c0a-af5d-ae6c5f9f2a1f',
  'e4d2b180-de91-4d0e-9d35-0342b9b12a36',
  'RZPTZ4AFVq81483f00mYXxE0246xc6fXsXW00IxD02wHG1U',
  'https://stream.mux.com/5VtbivAvTnPe8YMXl2nk7jlh3tem00WXH5iwPj6cfanU.m3u8',
  3,
  'coin',
  5,
  NOW() - INTERVAL '5 days'
);

-- Episode 4 (ad unlock)
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, created_at)
VALUES (
  'd4e07a1c-5a5b-6a1b-ba6e-bf7d6a0b3a2a',
  'e4d2b180-de91-4d0e-9d35-0342b9b12a36',
  'wmw1mQW7000115d402Cy28khFx7H8rVECU3zvc006Gw34Rk',
  'https://stream.mux.com/mYp00r01JZUIljcgfCPwnZ7oVAyvtA7VnTCI1hVjTWxLc.m3u8',
  4,
  'ad',
  NOW() - INTERVAL '4 days'
);

-- Episode 5 (coin unlock - higher cost)
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES (
  'e5f18a2d-6a6c-7a2c-ca7f-ca8e7a1a4a3a',
  'e4d2b180-de91-4d0e-9d35-0342b9b12a36',
  'EZQlRkwffb02w2XAzQSVva00YuwhZEN4k00IgpMzWS34JA',
  'https://stream.mux.com/sNbCrjYKweVQIUQJvPh91OyqsfryrfsDaHnbkpFHsmU.m3u8',
  5,
  'coin',
  10,
  NOW() - INTERVAL '3 days'
);

-- Episode 6 (vip only)
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, created_at)
VALUES (
  'f6a29a3e-7a7d-8a3d-da8a-da9f8a2a5a4a',
  'e4d2b180-de91-4d0e-9d35-0342b9b12a36',
  'oQwZJr01L1XlpdnO4mv8GXUkGsa3vZ02q7k9i7n4rYB18',
  'https://stream.mux.com/uZbQThWEoPeINdBB7KtNrdmao3s021r9F4E6Eti5YxWk.m3u8',
  6,
  'vip',
  NOW() - INTERVAL '2 days'
); 