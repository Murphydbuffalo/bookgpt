import { createRoot } from 'react-dom/client';
import ChatApp from '../components/ChatApp';
import Header from '../components/Header';

const container = document.getElementById('app');

if (container == null) {
  throw new Error('Container element not found.')  
}

const root = createRoot(container);

root.render(
<>
  <Header />
  <ChatApp />
</>);