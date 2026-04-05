-- PlusZone - Esquema inicial (Avance-proyecto-PlusZone)
-- Migración para Supabase CLI: supabase db push / supabase migration up

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Tipos ENUM
DO $$ BEGIN
  CREATE TYPE user_type_enum AS ENUM ('employee', 'company', 'admin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE swipe_direction_enum AS ENUM ('left', 'right');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE profile_role_enum AS ENUM ('candidate', 'job');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE email_outbox_status_enum AS ENUM ('pending', 'sending', 'sent', 'failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  name VARCHAR(255) NOT NULL,
  user_type user_type_enum DEFAULT 'employee',
  image_url VARCHAR(500),
  description TEXT,
  tech_stack JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users (user_type);

-- Tabla de perfiles
CREATE TABLE IF NOT EXISTS profiles (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(500),
  detailed_description TEXT,
  tech_stack JSONB DEFAULT '[]',
  salary VARCHAR(100),
  role profile_role_enum DEFAULT 'candidate',
  image_url VARCHAR(500),
  category VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles (role);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles (user_id);

-- Tabla de swipes
CREATE TABLE IF NOT EXISTS swipes (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  direction swipe_direction_enum NOT NULL,
  swiped_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, profile_id)
);

CREATE INDEX IF NOT EXISTS idx_swipes_user_id ON swipes (user_id);
CREATE INDEX IF NOT EXISTS idx_swipes_profile_id ON swipes (profile_id);

-- Tabla de matches
CREATE TABLE IF NOT EXISTS matches (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  matched_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, profile_id)
);

CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches (user_id);
CREATE INDEX IF NOT EXISTS idx_matches_profile_id ON matches (profile_id);

-- Tabla de mensajes (para futuro)
CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_messages_match_id ON messages (match_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_receiver ON messages (sender_id, receiver_id);

-- Tabla de verificación de correo (código 7 dígitos)
CREATE TABLE IF NOT EXISTS email_verifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code VARCHAR(10) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_email_verifications_user_id ON email_verifications (user_id);
CREATE INDEX IF NOT EXISTS idx_email_verifications_code ON email_verifications (code);

-- Tabla outbox para reintentos de correo
CREATE TABLE IF NOT EXISTS email_outbox (
  id SERIAL PRIMARY KEY,
  to_email VARCHAR(255) NOT NULL,
  subject VARCHAR(255),
  text TEXT,
  payload JSONB DEFAULT '{}',
  status email_outbox_status_enum DEFAULT 'pending',
  attempts INTEGER DEFAULT 0,
  last_error TEXT,
  next_attempt_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_email_outbox_status_next ON email_outbox (status, next_attempt_at);

-- RLS: habilitar Row Level Security (la app usa conexión directa con service role; RLS aplica si usas Supabase Client)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_outbox ENABLE ROW LEVEL SECURITY;

-- Políticas RLS: backend Express usa conexión directa (rol postgres)
CREATE POLICY "Postgres full access users" ON users FOR ALL TO postgres USING (true) WITH CHECK (true);
CREATE POLICY "Postgres full access profiles" ON profiles FOR ALL TO postgres USING (true) WITH CHECK (true);
CREATE POLICY "Postgres full access swipes" ON swipes FOR ALL TO postgres USING (true) WITH CHECK (true);
CREATE POLICY "Postgres full access matches" ON matches FOR ALL TO postgres USING (true) WITH CHECK (true);
CREATE POLICY "Postgres full access messages" ON messages FOR ALL TO postgres USING (true) WITH CHECK (true);
CREATE POLICY "Postgres full access email_verifications" ON email_verifications FOR ALL TO postgres USING (true) WITH CHECK (true);
CREATE POLICY "Postgres full access email_outbox" ON email_outbox FOR ALL TO postgres USING (true) WITH CHECK (true);
