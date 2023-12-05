import { useState } from 'react';
import ChatInput from './ChatInput';
import ChatMessage from './ChatMessage';
import '../stylesheets/App.css';

interface Message {
  text: string;
  isUser: boolean;
}

async function postJson(url: string, body: Record<any, any>) {
  const options = {
    method: 'POST',
    body: JSON.stringify(body),
    headers: { 'Accept': 'application/json', 'Content-Type': 'application/json '}
  };

  return await fetch(url, options);
}

export default function ChatApp() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [error, setError] = useState('');

  const fetchAnswer = async (userMessage: string): Promise<void> => {
    setError('');

    try {
      const response = await postJson('/conversations', { question: userMessage });
      const responseBody = await response.json();

      if (response.ok) {
        const botAnswer = responseBody.answer;
        setMessages([...messages, { text: userMessage, isUser: true }, { text: botAnswer, isUser: false }]);
      } else {
        setError(responseBody.error);
      }
    } catch(err) {
      const message = (err as { message: string }).message ?? 'Something went wrong, please try again in a moment.';
      setError(message);
    }
  };

  return (
    <div className="chat-app">
      {error && <div className="error-message">
        <p>{error}</p>
      </div>}
      <div className="chat-container">
        {messages.map((message, index) => (
          <ChatMessage key={index} message={message} />
        ))}
      </div>
      <ChatInput onMessageSubmit={fetchAnswer} />
    </div>
  );
};
