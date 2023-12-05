import '../stylesheets/ConversationList.css';

export interface Conversation {
  title: string;
  id: number | null;
}

interface ConversationListProps {
  selectedConversationId: number | null,
  conversations: Conversation[],
  handleClick: (conversationId: number | null) => Promise<void>
};

export default function ConversationList(props: ConversationListProps) {
  const { conversations, selectedConversationId, handleClick } = props;
  const newConversation = { id: null, title: '+ New Conversation' } as Conversation;
  return (
    <ul className="conversation-list">
      <h3>BookGPT</h3>
      {[newConversation].concat(conversations).map((conversation) => (
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
