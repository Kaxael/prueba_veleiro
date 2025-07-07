import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
// Importa los plugins de PostCSS
import tailwind from '@tailwindcss/postcss'
import autoprefixer from 'autoprefixer'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    }
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  },
  css: {
    postcss: {
      plugins: [
        tailwind(),
        autoprefixer()
      ]
    }
  }
})