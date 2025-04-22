-- Migration: Insert mock data for series and episodes
-- Description: Adds initial test data for development
-- Author: Claude
-- Date: 2024-04-18

-- Insert two series
INSERT INTO public.series (id, title, description, genre, cover_url, is_published, created_at)
VALUES 
  -- Series 1: Romance drama
  ('d11b3f2a-a7a5-4e33-a920-8f4c60384e12', 
   'Love in 60 Seconds',
   'A heartwarming story about two strangers who keep meeting in an elevator, with each episode capturing their brief but meaningful encounters.',
   'Romance',
   'https://example.com/covers/love-in-60-seconds.jpg',
   true,
   now()),
   
  -- Series 2: Mystery thriller
  ('f4b8c31d-7c4e-4b8d-9c3a-1d5e6f7a8b9c',
   'The Last Message',
   'A gripping mystery where each episode reveals a new clue about a mysterious text message that predicts future events.',
   'Thriller',
   'https://example.com/covers/the-last-message.jpg',
   true,
   now());

-- Insert episodes for "Love in 60 Seconds"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES
  -- First 3 episodes free to hook users
  ('e1a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c',
   'd11b3f2a-a7a5-4e33-a920-8f4c60384e12',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   1, 'free', null, now()),
   
  ('e2b3c4d5-e6f7-4a8b-9c0d-1e2f3a4b5c6d',
   'd11b3f2a-a7a5-4e33-a920-8f4c60384e12',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   2, 'free', null, now()),
   
  ('e3c4d5e6-f7a8-4b9c-0d1e-2f3a4b5c6d7e',
   'd11b3f2a-a7a5-4e33-a920-8f4c60384e12',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   3, 'free', null, now()),
   
  -- Next episodes require coins
  ('e4d5e6f7-a8b9-4c0d-1e2f-3a4b5c6d7e8f',
   'd11b3f2a-a7a5-4e33-a920-8f4c60384e12',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   4, 'coin', 50, now()),
   
  ('e5e6f7a8-b9c0-4d1e-2f3a-4b5c6d7e8f9a',
   'd11b3f2a-a7a5-4e33-a920-8f4c60384e12',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   5, 'coin', 50, now());

-- Insert episodes for "The Last Message"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES
  -- First 2 episodes free
  ('f1a2b3c4-d5e6-4f7a-8b9c-0d1e2f3a4b5c',
   'f4b8c31d-7c4e-4b8d-9c3a-1d5e6f7a8b9c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   1, 'free', null, now()),
   
  ('f2b3c4d5-e6f7-4a8b-9c0d-1e2f3a4b5c6d',
   'f4b8c31d-7c4e-4b8d-9c3a-1d5e6f7a8b9c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   2, 'free', null, now()),
   
  -- Rest require coins (higher cost due to thriller genre)
  ('f3c4d5e6-f7a8-4b9c-0d1e-2f3a4b5c6d7e',
   'f4b8c31d-7c4e-4b8d-9c3a-1d5e6f7a8b9c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   3, 'coin', 75, now()),
   
  ('f4d5e6f7-a8b9-4c0d-1e2f-3a4b5c6d7e8f',
   'f4b8c31d-7c4e-4b8d-9c3a-1d5e6f7a8b9c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   4, 'coin', 75, now()); 