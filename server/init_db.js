const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '.env') });
const fs = require('fs');
const { pool } = require('./db');
const bcrypt = require('bcryptjs');

const SQL_PATH = path.resolve(__dirname, '..', 'database', 'pluszone_supabase.sql');

// Divide el SQL en enunciados respetando bloques DO $$ ... $$;
function splitSql(sql) {
  const statements = [];
  let current = '';
  let inDollar = false;
  let i = 0;
  while (i < sql.length) {
    if (!inDollar && sql[i] === '$' && sql[i + 1] === '$') {
      inDollar = true;
      current += sql[i] + sql[i + 1];
      i += 2;
      continue;
    }
    if (inDollar && sql[i] === '$' && sql[i + 1] === '$') {
      inDollar = false;
      current += sql[i] + sql[i + 1];
      i += 2;
      continue;
    }
    if (!inDollar && sql[i] === ';') {
      const stmt = current.trim();
      if (stmt) statements.push(stmt);
      current = '';
      i++;
      continue;
    }
    current += sql[i];
    i++;
  }
  if (current.trim()) statements.push(current.trim());
  return statements;
}

async function run() {
  const client = await pool.connect();
  try {
    // 1) Ejecutar esquema si existe el archivo
    if (fs.existsSync(SQL_PATH)) {
      const sql = fs.readFileSync(SQL_PATH, 'utf8');
      const trimmed = sql.split('-- Fin del esquema PlusZone')[0].trim();
      // Elimina comentarios de línea para no perder sentencias válidas
      // precedidas por "--" (ej. "-- Tabla de usuarios" + "CREATE TABLE ...").
      const sqlWithoutComments = trimmed.replace(/^\s*--.*$/gm, '');
      const statements = splitSql(sqlWithoutComments);
      for (const stmt of statements) {
        if (!stmt) continue;
        try {
          await client.query(stmt);
        } catch (err) {
          if (err.code === '42P07' || err.message.includes('already exists')) continue;
          throw err;
        }
      }
      console.log('Esquema aplicado.');
    } else {
      await client.query('SELECT 1 FROM users LIMIT 1');
      console.log('Tabla users existe, omitiendo esquema.');
    }

    // 2) Seeds: usuarios de prueba con password hasheado
    const testUsers = [
      { email: 'admin@pluszone.com', name: 'Administrador', password: 'admin123', user_type: 'admin', is_active: true },
      { email: 'admin2@pluszone.com', name: 'Admin Secundario', password: 'admin123', user_type: 'admin', is_active: true },
      { email: 'j.gonzalez@tecmilenio.mx', name: 'Juan Gonzalez', password: 'demo123', user_type: 'employee', is_active: true },
      { email: 's.ramirez@tecmilenio.mx', name: 'Sofía Ramírez', password: 'demo123', user_type: 'employee', is_active: true },
      { email: 'm.lopez@tecmilenio.mx', name: 'María López', password: 'demo123', user_type: 'employee', is_active: true },
      { email: 'empresa1@tecmilenio.mx', name: 'TechCorp', password: 'demo123', user_type: 'company', is_active: true },
      { email: 'innovatech@tecmilenio.mx', name: 'Innovatech Solutions', password: 'demo123', user_type: 'company', is_active: true },
      { email: 'greentech@tecmilenio.mx', name: 'GreenWave Labs', password: 'demo123', user_type: 'company', is_active: true }
    ];

    const profileSeeds = {
      'j.gonzalez@tecmilenio.mx': {
        name: 'Juan Gonzalez',
        description: 'Senior Backend Developer',
        detailed_description: 'Ingeniero backend especializado en arquitecturas distribuidas, microservicios y soluciones de alta disponibilidad.',
        tech_stack: ['Node.js', 'PostgreSQL', 'AWS', 'Docker', 'TypeScript'],
        salary: '$90,000 - $110,000',
        image_url: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
        role: 'candidate',
        category: 'Backend'
      },
      's.ramirez@tecmilenio.mx': {
        name: 'Sofía Ramírez',
        description: 'UX/Product Designer',
        detailed_description: 'Diseñadora UX con experiencia en producto digital, investigación de usuarios y diseño de interfaces accesibles.',
        tech_stack: ['Figma', 'UX Research', 'Prototyping', 'Design Systems', 'User Testing'],
        salary: '$70,000 - $90,000',
        image_url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
        role: 'candidate',
        category: 'Diseño'
      },
      'm.lopez@tecmilenio.mx': {
        name: 'María López',
        description: 'Data Scientist',
        detailed_description: 'Científica de datos con experiencia en modelos predictivos, análisis avanzado y visualización estratégica.',
        tech_stack: ['Python', 'Machine Learning', 'SQL', 'Power BI', 'TensorFlow'],
        salary: '$85,000 - $105,000',
        image_url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=400&fit=crop',
        role: 'candidate',
        category: 'Data Science'
      },
      'empresa1@tecmilenio.mx': {
        name: 'TechCorp',
        description: 'Empresa tecnológica enfocada en software empresarial.',
        detailed_description: 'TechCorp desarrolla soluciones B2B para operaciones financieras y logística, con equipos de ingeniería ágiles y cultura de innovación.',
        tech_stack: [],
        salary: '$120,000 - $180,000',
        image_url: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=400&h=400&fit=crop',
        role: 'job',
        category: 'Tecnología'
      },
      'innovatech@tecmilenio.mx': {
        name: 'Innovatech Solutions',
        description: 'Consultora de transformación digital para empresas.',
        detailed_description: 'Innovatech crea productos SaaS y servicios de consultoría, con foco en automatización, innovación y crecimiento sostenible.',
        tech_stack: [],
        salary: '$100,000 - $160,000',
        image_url: 'https://images.unsplash.com/photo-1494526585095-c41746248156?w=400&h=400&fit=crop',
        role: 'job',
        category: 'Consultoría'
      },
      'greentech@tecmilenio.mx': {
        name: 'GreenWave Labs',
        description: 'Empresa especializada en productos sostenibles e innovación verde.',
        detailed_description: 'GreenWave Labs apoya startups y grandes compañías en desarrollar tecnología limpia y estrategias de impacto ambiental.',
        tech_stack: [],
        salary: '$95,000 - $150,000',
        image_url: 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=400&h=400&fit=crop',
        role: 'job',
        category: 'Sostenibilidad'
      }
    };

    for (const u of testUsers) {
      const { rows: exists } = await client.query('SELECT id FROM users WHERE email = $1', [u.email]);
      let userId;
      if (exists.length === 0) {
        const password_hash = await bcrypt.hash(u.password, 10);
        const { rows: ins } = await client.query(
          `INSERT INTO users (email, password_hash, name, user_type, is_active) VALUES ($1, $2, $3, $4, $5) RETURNING id`,
          [u.email, password_hash, u.name, u.user_type, u.is_active]
        );
        userId = ins[0].id;
        console.log('Usuario creado:', u.email);
      } else {
        userId = exists[0].id;
        console.log('Usuario ya existe:', u.email);
      }

      const { rows: prof } = await client.query('SELECT id FROM profiles WHERE user_id = $1', [userId]);
      const seed = profileSeeds[u.email];
      if (seed) {
        if (prof.length === 0) {
          await client.query(
            `INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
            [userId, seed.name, seed.description, seed.detailed_description, JSON.stringify(seed.tech_stack), seed.salary, seed.image_url, seed.role, seed.category]
          );
        } else {
          await client.query(
            `UPDATE profiles SET name = $1, description = $2, detailed_description = $3, tech_stack = $4, salary = $5, image_url = $6, role = $7, category = $8 WHERE user_id = $9`,
            [seed.name, seed.description, seed.detailed_description, JSON.stringify(seed.tech_stack), seed.salary, seed.image_url, seed.role, seed.category, userId]
          );
        }
      } else if (prof.length === 0) {
        await client.query(
          `INSERT INTO profiles (user_id, name, description, role, image_url) VALUES ($1, $2, $3, $4, $5)`,
          [userId, u.name, u.user_type === 'company' ? 'Empresa de ejemplo' : 'Perfil creado por migración', u.user_type === 'company' ? 'job' : 'candidate', null]
        );
      }
    }

    // Perfil "María García" para admin (seed de ejemplo) y match
    const { rows: adminUser } = await client.query("SELECT id FROM users WHERE email = 'admin@pluszone.com'");
    if (adminUser.length) {
      const { rows: mariaExists } = await client.query("SELECT id FROM profiles WHERE user_id = $1 AND name = 'María García'", [adminUser[0].id]);
      if (mariaExists.length === 0) {
        await client.query(
          `INSERT INTO profiles (user_id, name, description, detailed_description, tech_stack, salary, image_url, role, category) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
          [adminUser[0].id, 'María García', 'Senior Full Stack Developer', 'Desarrolladora con más de 8 años de experiencia.', JSON.stringify(['React', 'Node.js', 'TypeScript', 'PostgreSQL', 'AWS', 'Docker']), '$80,000 - $120,000', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop', 'candidate', 'Informática']
        );
        console.log('Perfil María García creado.');
      }
      const { rows: mariaProfile } = await client.query("SELECT id FROM profiles WHERE name = 'María García' LIMIT 1");
      if (mariaProfile.length) {
        const { rows: existsMatch } = await client.query('SELECT id FROM matches WHERE user_id = $1 AND profile_id = $2', [adminUser[0].id, mariaProfile[0].id]);
        if (existsMatch.length === 0) {
          await client.query('INSERT INTO matches (user_id, profile_id) VALUES ($1, $2)', [adminUser[0].id, mariaProfile[0].id]);
          console.log('Match de ejemplo creado.');
        }
      }
    }

    console.log('Migración completada.');
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

run();
