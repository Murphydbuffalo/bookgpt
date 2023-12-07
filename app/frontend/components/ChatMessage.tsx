import { Message } from './Chat';

export default function ChatMessage(props: { message: Message }) {
  const { content, role } = props.message;

  return (
    <div className={`chat-message ${role}-message`}>
      <strong>
        {role === 'user' ? 'You' : 'BookGPT'}:
      </strong>
      &nbsp;
      {content}
    </div>
  );
};
