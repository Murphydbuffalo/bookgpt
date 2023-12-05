import React, { useState } from 'react';

interface ChatInputProps {
  onMessageSubmit: (text: string, isUser: boolean) => void;
}

export default function ChatInput({ onMessageSubmit }: ChatInputProps ) {
  const [inputText, setInputText] = useState('');

  const handleSubmit = (e: React.FormEvent): void => {
    e.preventDefault();
    if (inputText.trim() !== '') {
      onMessageSubmit(inputText, true);
      setInputText('');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="chat-input-form">
      <input
        type="text"
        value={inputText}
        onChange={(e) => setInputText(e.target.value)}
        placeholder="Ask away..."
        className="chat-input"
      />
      <button type="submit" className="send-button">
        Send
      </button>
    </form>
  );
};
