-- Migration: Add more mock data for series and episodes
-- Description: Adds additional test series and episodes for development
-- Author: Claude
-- Date: 2024-05-01

-- Insert four more series
INSERT INTO public.series (id, title, description, genre, cover_url, is_published, created_at)
VALUES 
  -- Series 3: Action
  ('a1b2c3d4-e5f6-47a7-8b9c-0d1e2f3a4b5c', 
   'Final Countdown',
   'A high-stakes action drama where a former spy has to complete impossible missions against the clock.',
   'Action',
   'https://example.com/covers/final-countdown.jpg',
   true,
   now()),
   
  -- Series 4: Comedy
  ('b2c3d4e5-f6a7-48b8-9c0d-1e2f3a4b5c6d',
   'Micro Office',
   'A hilarious comedy about the everyday absurdities of working in the world''s smallest startup.',
   'Comedy',
   'https://example.com/covers/micro-office.jpg',
   true,
   now()),
   
  -- Series 5: Sci-Fi
  ('c3d4e5f6-a7b8-49c9-0d1e-2f3a4b5c6d7e',
   'The Quantum Shift',
   'A mind-bending sci-fi series where alternate realities collide in 60-second windows.',
   'Sci-Fi',
   'https://example.com/covers/quantum-shift.jpg',
   true,
   now()),
   
  -- Series 6: Horror
  ('d4e5f6a7-b8c9-40d0-1e2f-3a4b5c6d7e8f',
   'Last Breath',
   'A terrifying horror series where characters experience their deepest fears in the final minute of their lives.',
   'Horror',
   'https://example.com/covers/last-breath.jpg',
   true,
   now());

-- Insert episodes for "Final Countdown"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES
  -- First 2 episodes free
  ('a1a2a3a4-a5a6-47a7-8a9a-0a1a2a3a4a5a',
   'a1b2c3d4-e5f6-47a7-8b9c-0d1e2f3a4b5c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   1, 'free', null, now()),
   
  ('a2a3a4a5-a6a7-48a8-9a0a-1a2a3a4a5a6a',
   'a1b2c3d4-e5f6-47a7-8b9c-0d1e2f3a4b5c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   2, 'free', null, now()),
   
  -- Paid episodes
  ('a3a4a5a6-a7a8-49a9-0a1a-2a3a4a5a6a7a',
   'a1b2c3d4-e5f6-47a7-8b9c-0d1e2f3a4b5c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   3, 'coin', 60, now()),
   
  ('a4a5a6a7-a8a9-40a0-1a2a-3a4a5a6a7a8a',
   'a1b2c3d4-e5f6-47a7-8b9c-0d1e2f3a4b5c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   4, 'coin', 60, now()),
   
  ('a5a6a7a8-a9a0-41a1-2a3a-4a5a6a7a8a9a',
   'a1b2c3d4-e5f6-47a7-8b9c-0d1e2f3a4b5c',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   5, 'coin', 60, now());

-- Insert episodes for "Micro Office"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES
  -- First 3 episodes free
  ('b1b2b3b4-b5b6-47b7-8b9b-0b1b2b3b4b5b',
   'b2c3d4e5-f6a7-48b8-9c0d-1e2f3a4b5c6d',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   1, 'free', null, now()),
   
  ('b2b3b4b5-b6b7-48b8-9b0b-1b2b3b4b5b6b',
   'b2c3d4e5-f6a7-48b8-9c0d-1e2f3a4b5c6d',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   2, 'free', null, now()),
   
  ('b3b4b5b6-b7b8-49b9-0b1b-2b3b4b5b6b7b',
   'b2c3d4e5-f6a7-48b8-9c0d-1e2f3a4b5c6d',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   3, 'free', null, now()),
   
  -- Paid episodes
  ('b4b5b6b7-b8b9-40b0-1b2b-3b4b5b6b7b8b',
   'b2c3d4e5-f6a7-48b8-9c0d-1e2f3a4b5c6d',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   4, 'coin', 40, now()),
   
  ('b5b6b7b8-b9b0-41b1-2b3b-4b5b6b7b8b9b',
   'b2c3d4e5-f6a7-48b8-9c0d-1e2f3a4b5c6d',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   5, 'coin', 40, now());

-- Insert episodes for "The Quantum Shift"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES
  -- First 2 episodes free
  ('c1c2c3c4-c5c6-47c7-8c9c-0c1c2c3c4c5c',
   'c3d4e5f6-a7b8-49c9-0d1e-2f3a4b5c6d7e',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   1, 'free', null, now()),
   
  ('c2c3c4c5-c6c7-48c8-9c0c-1c2c3c4c5c6c',
   'c3d4e5f6-a7b8-49c9-0d1e-2f3a4b5c6d7e',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   2, 'free', null, now()),
   
  -- Paid episodes - higher cost for sci-fi premium content
  ('c3c4c5c6-c7c8-49c9-0c1c-2c3c4c5c6c7c',
   'c3d4e5f6-a7b8-49c9-0d1e-2f3a4b5c6d7e',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   3, 'coin', 80, now()),
   
  ('c4c5c6c7-c8c9-40c0-1c2c-3c4c5c6c7c8c',
   'c3d4e5f6-a7b8-49c9-0d1e-2f3a4b5c6d7e',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   4, 'coin', 80, now()),
   
  ('c5c6c7c8-c9c0-41c1-2c3c-4c5c6c7c8c9c',
   'c3d4e5f6-a7b8-49c9-0d1e-2f3a4b5c6d7e',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   5, 'coin', 80, now()),
   
  ('c6c7c8c9-c0c1-42c2-3c4c-5c6c7c8c9c0c',
   'c3d4e5f6-a7b8-49c9-0d1e-2f3a4b5c6d7e',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   6, 'coin', 80, now());

-- Insert episodes for "Last Breath"
INSERT INTO public.episodes (id, series_id, mux_asset_id, playback_url, episode_number, unlock_type, coin_cost, created_at)
VALUES
  -- First episode free as a teaser
  ('d1d2d3d4-d5d6-47d7-8d9d-0d1d2d3d4d5d',
   'd4e5f6a7-b8c9-40d0-1e2f-3a4b5c6d7e8f',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   1, 'free', null, now()),
   
  -- Premium horror content - all paid after the first
  ('d2d3d4d5-d6d7-48d8-9d0d-1d2d3d4d5d6d',
   'd4e5f6a7-b8c9-40d0-1e2f-3a4b5c6d7e8f',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   2, 'coin', 100, now()),
   
  ('d3d4d5d6-d7d8-49d9-0d1d-2d3d4d5d6d7d',
   'd4e5f6a7-b8c9-40d0-1e2f-3a4b5c6d7e8f',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   3, 'coin', 100, now()),
   
  ('d4d5d6d7-d8d9-40d0-1d2d-3d4d5d6d7d8d',
   'd4e5f6a7-b8c9-40d0-1e2f-3a4b5c6d7e8f',
   'kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00',
   'https://stream.mux.com/IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA.m3u8',
   4, 'coin', 100, now()); 