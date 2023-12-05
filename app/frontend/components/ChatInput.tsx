import React, { useState } from 'react';

interface ChatInputProps {
  isLoading: boolean;
  onMessageSubmit: (text: string, isUser: boolean) => void;
}

export default function ChatInput({ onMessageSubmit, isLoading }: ChatInputProps ) {
  const [inputText, setInputText] = useState('');

  const handleSubmit = (e: React.FormEvent): void => {
    e.preventDefault();
    if (inputText.trim() !== '') {
      onMessageSubmit(inputText, true);
      setInputText('');
    }
  };

  return (
    <form onSubmit={handleSubmit} className={`chat-input-form ${isLoading ? 'loading' : ''}`}>
      <input
        type="text"
        value={inputText}
        onChange={(e) => setInputText(e.target.value)}
        placeholder={isLoading ? "Loading..." : "Type your question here"}
        className="chat-input"
        disabled={isLoading}
      />
      <button type="submit" className={`send-button ${isLoading ? 'disabled' : ''}`} disabled={isLoading}>
        Send
      </button>
    </form>
  );
};
