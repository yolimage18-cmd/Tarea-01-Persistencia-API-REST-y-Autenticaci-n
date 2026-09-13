require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const calificacionesRoutes = require('./routes/calificaciones');

const app = express();

app.use(cors());
app.use(express.json());

// Middleware simple de registro de peticiones (útil para depurar desde la app móvil)
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.originalUrl}`);
  next();
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'API de Calificaciones funcionando correctamente.' });
});

app.use('/api/auth', authRoutes);
app.use('/api/calificaciones', calificacionesRoutes);

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada.' });
});

// Manejo centralizado de errores
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor.' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log('==========================================================');
  console.log(` API de Calificaciones escuchando en http://0.0.0.0:${PORT}`);
  console.log(` Prueba de salud: http://localhost:${PORT}/api/health`);
  console.log('==========================================================');
});
