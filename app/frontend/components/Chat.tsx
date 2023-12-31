import { useState, useEffect } from 'react';
import ChatInput from './ChatInput';
import ChatMessage from './ChatMessage';
import '../stylesheets/Chat.css';
import '../stylesheets/Loading.css';
import ConversationList from './ConversationList';
import { Conversation } from './ConversationListItem';

type ConversationRole = 'user' | 'system';

export interface Message {
  content: string;
  role: ConversationRole;
}

async function postJson(url: string, body: Record<any, any>) {
  const options = {
    method: 'POST',
    body: JSON.stringify(body),
    headers: { 'Accept': 'application/json', 'Content-Type': 'application/json '}
  };

  return await fetch(url, options);
}

export default function Chat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [error, setError] = useState('');
  const [conversationId, setConversationId] = useState<number | null>(null);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [conversationListIsLoading, setConversationListIsLoading] = useState(false);
  const [answerIsLoading, setAnswerIsLoading] = useState(false);
  const [cachedConversationData, setCachedConversationData] = useState<Record<number, Message[]>>({});

  async function selectConversation(conversationId: number | null) {
    setError('');

    if (conversationId == null) {
      setMessages([]);
      setConversationId(null);

      return;
    }
  
    if (cachedConversationData[conversationId] != null) {
      setMessages(cachedConversationData[conversationId]);
      setConversationId(conversationId);

      return;
    }

    try {
      const response = await fetch(`/conversations/${conversationId}`);
      const responseBody = await response.json();
      const messages = responseBody.messages as Message[];

      if (response.ok) {
        setMessages(messages);
        setConversationId(conversationId);
        setCachedConversationData({ ...cachedConversationData, [conversationId]: messages })
      } else {
        setError(responseBody.error);
      }
    } catch(err) {
      const e = (err as { message: string });
      const message = e.message ? e.message : 'Unable to fetch conversation data, please try again in a moment.';
      setError(message);
    }
  }

  const fetchAnswer = async (userMessage: string): Promise<void> => {
    setError('');
    setAnswerIsLoading(true);

    try {
      const response = await postJson('/conversations', { question: userMessage, conversation_id: conversationId });
      const responseBody = await response.json();

      if (response.ok) {
        const botAnswer = responseBody.answer;
        setMessages([...messages, { content: userMessage, role: 'user' }, { content: botAnswer, role: 'system' }]);

        if (conversationId == null) { // It's a new conversation
          const newConversation = { id: responseBody.conversation_id, title: responseBody.conversation_title };
          setConversationId(newConversation.id);
          setConversations([newConversation, ...conversations])
        }
      } else {
        setError(responseBody.error);
      }
    } catch(err) {
      const e = (err as { message: string });
      const message = e.message ? e.message : 'Something went wrong sending your message, please try again in a moment.';
      setError(message);
    } finally {
      setAnswerIsLoading(false);
    }
  };

  useEffect(() => {
    async function fetchConversations() {
      setError('');
      setConversationListIsLoading(true)

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
      } finally {
        setConversationListIsLoading(false)
      }
    }

    fetchConversations();
  }, []);

  return (
    <div className="chat-app">
      {error && <div className="error-message">
        <p>{`We ran into a problem: ${error}`}</p>
      </div>}

      <ConversationList
       conversations={conversations}
       selectedConversationId={conversationId}
       handleClick={selectConversation}
       isLoading={conversationListIsLoading}
      />

      <div className="chat-container">
        {messages.map((message, index) => (
          <ChatMessage key={index} message={message} />
        ))}
      </div>
      <ChatInput isLoading={answerIsLoading} onMessageSubmit={fetchAnswer} />
    </div>
  );
};
