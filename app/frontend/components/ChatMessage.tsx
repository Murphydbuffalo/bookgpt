import { Message } from './ChatApp';

export default function ChatMessage(props: { message: Message }) {
  const { content, role } = props.message;

  return (
    <div className={`chat-message ${role}-message`}>
      {content}
    </div>
  );
};
