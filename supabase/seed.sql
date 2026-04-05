-- PlusZone - Datos iniciales (Avance-proyecto-PlusZone)
-- Se ejecuta con: supabase db reset (local) o aplicando seed manualmente en remoto

-- Usuarios de prueba (password_hash con pgcrypto: crypt('password', gen_salt('bf')))
INSERT INTO users (email, password_hash, name, user_type, is_active) VALUES
  ('admin@pluszone.com', crypt('admin123', gen_salt('bf')), 'Administrador', 'admin', true),
  ('admin2@pluszone.com', crypt('admin123', gen_salt('bf')), 'Admin Secundario', 'admin', true),
  ('j.gonzalez@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'Juan Gonzalez', 'employee', true),
  ('s.ramirez@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'Sofía Ramírez', 'employee', true),
  ('empresa1@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'TechCorp', 'company', true)
ON CONFLICT (email) DO NOTHING;

-- Perfiles de ejemplo (uno por usuario seed)
INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT id, name, 'Perfil creado por seed', '', '[]', '', NULL, CASE user_type WHEN 'company' THEN 'job' ELSE 'candidate' END, 'Informática'
FROM users WHERE email IN ('admin@pluszone.com', 'admin2@pluszone.com', 'j.gonzalez@tecmilenio.mx', 's.ramirez@tecmilenio.mx', 'empresa1@tecmilenio.mx')
AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = users.id);

-- Perfil María García (admin)
INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT u.id, 'María García', 'Senior Full Stack Developer', 'Desarrolladora con más de 8 años de experiencia.', '["React","Node.js","TypeScript","PostgreSQL","AWS","Docker"]', '$80,000 - $120,000', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop', 'candidate', 'Informática'
FROM users u
WHERE u.email = 'admin@pluszone.com'
  AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = u.id AND p.name = 'María García');

-- Match de ejemplo (admin ↔ perfil María García)
INSERT INTO matches (user_id, profile_id)
SELECT u.id, p.id FROM users u, profiles p
WHERE u.email = 'admin@pluszone.com' AND p.name = 'María García'
AND NOT EXISTS (SELECT 1 FROM matches m WHERE m.user_id = u.id AND m.profile_id = p.id);
