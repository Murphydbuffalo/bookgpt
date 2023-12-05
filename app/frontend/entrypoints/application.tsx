import { createRoot } from 'react-dom/client';
import Chat from '../components/Chat';
import Header from '../components/Header';
import '../stylesheets/App.css';

const container = document.getElementById('app');

if (container == null) {
  throw new Error('Container element not found.')  
}

const root = createRoot(container);

root.render(
<>
  <Header />
  <Chat />
</>);