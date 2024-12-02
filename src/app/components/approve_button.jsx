import React from 'react';

export const ApproveButton = ({ farmer_id, fetchFarmers }) => {
  const handleAction = async () => {
    try {
      const response = await fetch('http://127.0.0.1:8000/api/dashboard/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ farmer_id, action: 'approve' }),
        credentials: 'include', // Ensure cookies are sent with the request
      });
      

      if (!response.ok) {
        const errorText = await response.text(); // Capture the error text
        throw new Error(`Action failed: ${response.status} - ${errorText}`);
      }

      console.log('Farmer approved successfully!');
      fetchFarmers();
    } catch (error) {
      console.error('Error updating farmer status:', error);
    }
  };

  return (
    <button onClick={handleAction} className="button">
      Approve
    </button>
  );
};
