import { defineConfig } from 'vite'
import Rails from 'vite-plugin-rails'
import react from '@vitejs/plugin-react-swc'

export default defineConfig({
  plugins: [
    react(),
    Rails({
      // Sets defaults for these env vars.
      envVars: { RAILS_ENV: 'development' },
    }),
  ],
})
