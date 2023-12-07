import '../stylesheets/ConversationList.css';
import ConversationListItem from './ConversationListItem';
import { Conversation } from './ConversationListItem';

interface ConversationListProps {
  selectedConversationId: number | null,
  conversations: Conversation[],
  isLoading: boolean;
  handleClick: (conversationId: number | null) => Promise<void>
};

export default function ConversationList(props: ConversationListProps) {
  const { conversations, selectedConversationId, isLoading, handleClick } = props;
  const newConversation = { id: null, title: '+ New Conversation' } as Conversation;

  return (
    <ul className="conversation-list">
      <h3>BookGPT</h3>
      {[newConversation].concat(conversations).map((conversation, i) => (
        <>
          <ConversationListItem
           key={conversation.id}
           conversation={conversation}
           isSelected={conversation.id === selectedConversationId}
           handleClick={handleClick}
          />
          {i === 0 && <hr></hr>}
        </>
      ))}
      {isLoading && <li key='loading' className='loading'>Loading conversations...</li>}
    </ul>
  );
}
