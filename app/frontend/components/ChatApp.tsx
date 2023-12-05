import { useState, useEffect } from 'react';
import ChatInput from './ChatInput';
import ChatMessage from './ChatMessage';
import '../stylesheets/App.css';
import '../stylesheets/ConversationList.css';

type ConversationRole = 'user' | 'system';

export interface Message {
  content: string;
  role: ConversationRole;
}

interface Conversation {
  title: string;
  id: number;
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
  const [conversationId, setConversationId] = useState<number | null>(null);
  const [conversations, setConversations] = useState<Conversation[]>([]);

  async function selectConversation(conversationId: number) {
    try {
      const response = await fetch(`/conversations/${conversationId}`);
      const responseBody = await response.json();

      if (response.ok) {
        setMessages(responseBody.messages);
        setConversationId(conversationId);
      } else {
        setError(responseBody.error);
      }
    } catch(err) {
      const e = (err as { message: string });
      const message = e.message ? e.message : 'Unable to fetch conversations, please try again in a moment.';
      setError(message);
    }
  }

  useEffect(() => {
    async function fetchConversations() {
      try {
        const response = await fetch('/conversations');
        const responseBody = await response.json();

        if (response.ok) {
          const conversations = responseBody.map((convo: [id: number, title: string]) => {
            const [id, title] = convo;
            return { id, title };
          });

          setConversations(conversations);
        } else {
          setError(responseBody.error);
        }
      } catch(err) {
        const e = (err as { message: string });
        const message = e.message ? e.message : 'Unable to fetch conversations, please try again in a moment.';
        setError(message);
      }
    }

    fetchConversations();
  }, []);

  const fetchAnswer = async (userMessage: string): Promise<void> => {
    setError('');

    try {
      const response = await postJson('/conversations', { question: userMessage, conversation_id: conversationId });
      const responseBody = await response.json();

      if (response.ok) {
        const botAnswer = responseBody.answer;
        setMessages([...messages, { content: userMessage, role: 'user' }, { content: botAnswer, role: 'system' }]);
      } else {
        setError(responseBody.error);
      }
    } catch(err) {
      const e = (err as { message: string });
      const message = e.message ? e.message : 'Something went wrong sending your message, please try again in a moment.';
      setError(message);
    }
  };

  return (
    <div className="chat-app">
      {error && <div className="error-message">
        <p>{error}</p>
      </div>}

      <ul className="conversation-list">
        <h3>BookGPT</h3>
        {conversations.map((conversation) => (
          <li key={conversation.id} className={conversation.id === conversationId ? 'selected' : ''} onClick={() => { selectConversation(conversation.id) }}>
            {conversation.title}
          </li>
        ))}
      </ul>

      <div className="chat-container">
        {messages.map((message, index) => (
          <ChatMessage key={index} message={message} />
        ))}
      </div>
      <ChatInput onMessageSubmit={fetchAnswer} />
    </div>
  );
};
