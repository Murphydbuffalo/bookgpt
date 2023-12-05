import { useState } from 'react';
import ChatInput from './ChatInput';
import ChatMessage from './ChatMessage';
import '../stylesheets/App.css';

interface Message {
  text: string;
  isUser: boolean;
}

export default function ChatApp() {
  const [messages, setMessages] = useState<Message[]>([]);

  const addMessage = (text: string, isUser = false): void => {
    setMessages([...messages, { text, isUser }]);
  };

  return (
    <div className="chat-app">
      <div className="chat-container">
        {messages.map((message, index) => (
          <ChatMessage key={index} message={message} />
        ))}
      </div>
      <ChatInput onMessageSubmit={addMessage} />
    </div>
  );
};
