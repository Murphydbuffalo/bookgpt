import { defineConfig } from 'vite'
import Rails from 'vite-plugin-rails'
import react from '@vitejs/plugin-react'


export default defineConfig({
  plugins: [
    Rails({
      envVars: { RAILS_ENV: 'development' },
    }),
    react(),
  ],
})
