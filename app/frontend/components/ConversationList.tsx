import '../stylesheets/ConversationList.css';

export interface Conversation {
  title: string;
  id: number;
}

interface ConversationListProps {
  selectedConversationId: number | null,
  conversations: Conversation[],
  handleClick: (conversationId: number) => Promise<void>
};

export default function ConversationList(props: ConversationListProps) {
  const { conversations, selectedConversationId, handleClick } = props;
  return (
    <ul className="conversation-list">
      <h3>BookGPT</h3>
      {conversations.map((conversation) => (
        <li
         key={conversation.id}
         className={conversation.id === selectedConversationId ? 'selected' : ''}
         onClick={() => { handleClick(conversation.id) }}
        >
          {conversation.title}
        </li>
      ))}
    </ul>
  );
}
