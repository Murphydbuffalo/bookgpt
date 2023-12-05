interface ChatMessageProps {
  message: { text: string; isUser: boolean };
}

export default function ChatMessage({ message }: ChatMessageProps) {
  const { text, isUser } = message;

  return (
    <div className={`chat-message ${isUser ? 'user-message' : 'bot-message'}`}>
      {text}
    </div>
  );
};
