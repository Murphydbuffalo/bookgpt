import { createRoot } from 'react-dom/client';

const container = document.getElementById('app');

if (container == null) {
  throw new Error('Container element not found.')  
}

const root = createRoot(container);
root.render(<h1>We on</h1>);