import { useState } from 'react';
import '../stylesheets/ConversationList.css';

export interface Conversation {
  title: string;
  id: number | null;
}

interface ConversationListItemProps {
  isSelected: boolean,
  conversation: Conversation,
  handleClick: (conversationId: number | null) => Promise<void>
};

export default function ConversationListItem(props: ConversationListItemProps) {
  const { conversation, isSelected, handleClick } = props;
  const [isLoading, setIsLoading] = useState(false);

  return (
    <li
    key={conversation.id}
    className={`${isLoading ? 'loading' : ''} ${isSelected ? 'selected' : ''}`}
    onClick={async () => {
      setIsLoading(true);
      await handleClick(conversation.id);
      setIsLoading(false);
    }}
    >
      {conversation.title}
    </li>
  );
}
