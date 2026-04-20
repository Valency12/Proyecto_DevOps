-- PlusZone - Datos iniciales (Avance-proyecto-PlusZone)
-- Se ejecuta con: supabase db reset (local) o aplicando seed manualmente en remoto

-- Usuarios de prueba (password_hash con pgcrypto: crypt('password', gen_salt('bf')))
INSERT INTO users (email, password_hash, name, user_type, is_active) VALUES
  ('admin@pluszone.com', crypt('admin123', gen_salt('bf')), 'Administrador', 'admin', true),
  ('admin2@pluszone.com', crypt('admin123', gen_salt('bf')), 'Admin Secundario', 'admin', true),
  ('j.gonzalez@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'Juan Gonzalez', 'employee', true),
  ('s.ramirez@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'Sofía Ramírez', 'employee', true),
  ('m.lopez@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'María López', 'employee', true),
  ('empresa1@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'TechCorp', 'company', true),
  ('innovatech@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'Innovatech Solutions', 'company', true),
  ('greentech@tecmilenio.mx', crypt('demo123', gen_salt('bf')), 'GreenWave Labs', 'company', true)
ON CONFLICT (email) DO NOTHING;

-- Perfiles de ejemplo robustos (empleados y empresas)
INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT id, 'Juan Gonzalez', 'Senior Backend Developer', 'Ingeniero backend especializado en arquitecturas distribuidas, microservicios y soluciones de alta disponibilidad.', '["Node.js","PostgreSQL","AWS","Docker","TypeScript"]', '$90,000 - $110,000', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop', 'candidate', 'Backend'
FROM users WHERE email = 'j.gonzalez@tecmilenio.mx' AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = users.id);

INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT id, 'Sofía Ramírez', 'UX/Product Designer', 'Diseñadora UX con experiencia en producto digital, investigación de usuarios y diseño de interfaces accesibles.', '["Figma","UX Research","Prototyping","Design Systems","User Testing"]', '$70,000 - $90,000', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop', 'candidate', 'Diseño'
FROM users WHERE email = 's.ramirez@tecmilenio.mx' AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = users.id);

INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT id, 'María López', 'Data Scientist', 'Científica de datos con experiencia en modelos predictivos, análisis avanzado y visualización estratégica.', '["Python","Machine Learning","SQL","Power BI","TensorFlow"]', '$85,000 - $105,000', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=400&fit=crop', 'candidate', 'Data Science'
FROM users WHERE email = 'm.lopez@tecmilenio.mx' AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = users.id);

INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT id, 'TechCorp', 'Empresa tecnológica enfocada en software empresarial.', 'TechCorp desarrolla soluciones B2B para operaciones financieras y logística, con equipos de ingeniería ágiles y cultura de innovación.', '[]', '$120,000 - $180,000', 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=400&h=400&fit=crop', 'job', 'Tecnología'
FROM users WHERE email = 'empresa1@tecmilenio.mx' AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = users.id);

INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT id, 'Innovatech Solutions', 'Consultora de transformación digital para empresas.', 'Innovatech crea productos SaaS y servicios de consultoría, con foco en automatización, innovación y crecimiento sostenible.', '[]', '$100,000 - $160,000', 'https://images.unsplash.com/photo-1494526585095-c41746248156?w=400&h=400&fit=crop', 'job', 'Consultoría'
FROM users WHERE email = 'innovatech@tecmilenio.mx' AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = users.id);

INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT id, 'GreenWave Labs', 'Empresa especializada en productos sostenibles e innovación verde.', 'GreenWave Labs apoya startups y grandes compañías en desarrollar tecnología limpia y estrategias de impacto ambiental.', '[]', '$95,000 - $150,000', 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=400&h=400&fit=crop', 'job', 'Sostenibilidad'
FROM users WHERE email = 'greentech@tecmilenio.mx' AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = users.id);

-- Perfil María García (admin)
INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category)
SELECT u.id, 'María García', 'Senior Full Stack Developer', 'Desarrolladora con más de 8 años de experiencia en soluciones web, integración de APIs y liderazgo técnico.', '["React","Node.js","TypeScript","PostgreSQL","AWS","Docker"]', '$80,000 - $120,000', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop', 'candidate', 'Full Stack'
FROM users u
WHERE u.email = 'admin@pluszone.com'
  AND NOT EXISTS (SELECT 1 FROM profiles p WHERE p.user_id = u.id AND p.name = 'María García');

-- Match de ejemplo (admin ↔ perfil María García)
INSERT INTO matches (user_id, profile_id)
SELECT u.id, p.id FROM users u, profiles p
WHERE u.email = 'admin@pluszone.com' AND p.name = 'María García'
AND NOT EXISTS (SELECT 1 FROM matches m WHERE m.user_id = u.id AND m.profile_id = p.id);

-- Actualizar perfiles de ejemplo existentes para reflejar datos más robustos
UPDATE profiles p SET
  name = 'Juan Gonzalez',
  description = 'Senior Backend Developer',
  detailed_description = 'Ingeniero backend especializado en arquitecturas distribuidas, microservicios y soluciones de alta disponibilidad.',
  tech_stack = '["Node.js","PostgreSQL","AWS","Docker","TypeScript"]',
  salary = '$90,000 - $110,000',
  image_url = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
  role = 'candidate',
  category = 'Backend'
FROM users u
WHERE u.email = 'j.gonzalez@tecmilenio.mx' AND p.user_id = u.id;

UPDATE profiles p SET
  name = 'Sofía Ramírez',
  description = 'UX/Product Designer',
  detailed_description = 'Diseñadora UX con experiencia en producto digital, investigación de usuarios y diseño de interfaces accesibles.',
  tech_stack = '["Figma","UX Research","Prototyping","Design Systems","User Testing"]',
  salary = '$70,000 - $90,000',
  image_url = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
  role = 'candidate',
  category = 'Diseño'
FROM users u
WHERE u.email = 's.ramirez@tecmilenio.mx' AND p.user_id = u.id;

UPDATE profiles p SET
  name = 'María López',
  description = 'Data Scientist',
  detailed_description = 'Científica de datos con experiencia en modelos predictivos, análisis avanzado y visualización estratégica.',
  tech_stack = '["Python","Machine Learning","SQL","Power BI","TensorFlow"]',
  salary = '$85,000 - $105,000',
  image_url = 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=400&fit=crop',
  role = 'candidate',
  category = 'Data Science'
FROM users u
WHERE u.email = 'm.lopez@tecmilenio.mx' AND p.user_id = u.id;

UPDATE profiles p SET
  name = 'TechCorp',
  description = 'Empresa tecnológica enfocada en software empresarial.',
  detailed_description = 'TechCorp desarrolla soluciones B2B para operaciones financieras y logística, con equipos de ingeniería ágiles y cultura de innovación.',
  salary = '$120,000 - $180,000',
  image_url = 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=400&h=400&fit=crop',
  role = 'job',
  category = 'Tecnología'
FROM users u
WHERE u.email = 'empresa1@tecmilenio.mx' AND p.user_id = u.id;

UPDATE profiles p SET
  name = 'Innovatech Solutions',
  description = 'Consultora de transformación digital para empresas.',
  detailed_description = 'Innovatech crea productos SaaS y servicios de consultoría, con foco en automatización, innovación y crecimiento sostenible.',
  salary = '$100,000 - $160,000',
  image_url = 'https://images.unsplash.com/photo-1494526585095-c41746248156?w=400&h=400&fit=crop',
  role = 'job',
  category = 'Consultoría'
FROM users u
WHERE u.email = 'innovatech@tecmilenio.mx' AND p.user_id = u.id;

UPDATE profiles p SET
  name = 'GreenWave Labs',
  description = 'Empresa especializada en productos sostenibles e innovación verde.',
  detailed_description = 'GreenWave Labs apoya startups y grandes compañías en desarrollar tecnología limpia y estrategias de impacto ambiental.',
  salary = '$95,000 - $150,000',
  image_url = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=400&h=400&fit=crop',
  role = 'job',
  category = 'Sostenibilidad'
FROM users u
WHERE u.email = 'greentech@tecmilenio.mx' AND p.user_id = u.id;
