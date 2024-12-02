import React from 'react';

export const RejectButton = ({ farmer_id, fetchFarmers}) => {
  const handleAction = async () => {
    try {
      const response = await fetch('http://127.0.0.1:8000/api/dashboard/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ farmer_id, action: 'reject' }),
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Action failed');

      console.log('Farmer rejected successfully!');
      fetchFarmers();
    } catch (error) {
      console.error('Error updating farmer status:', error);
    }
  };

  return (
    <button onClick={handleAction} className="button">
      Reject
    </button>
  );
};
