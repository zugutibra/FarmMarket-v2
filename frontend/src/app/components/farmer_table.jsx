import React, { useState, useEffect } from 'react';
import { ApproveButton } from './approve_button';
import { RejectButton } from './reject_button';

export const FarmerTable = ({ farmers }) => {
  const [farmerList, setFarmerList] = useState(farmers); // Use state if list changes are needed
  
  const fetchFarmers = async () => {
    const response = await fetch('http://127.0.0.1:8000/api/dashboard/');
    const data = await response.json();
    setFarmerList(data.farmers);
  };

  useEffect(() => {
    fetchFarmers();  // Fetch data on initial load
  }, []);
  return (
    <div>
      <table className='table'>
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Farm Name</th>
            <th>Farm Location</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {farmerList.map((farmer) => (
            <tr key={farmer.id}>
              <td>{farmer.name}</td>
              <td>{farmer.email}</td>
              <td>{farmer.farm_name}</td>
              <td>{farmer.farm_location}</td>
              <td>{farmer.account_status}</td>
              <td>
                {farmer.account_status === 'pending' ? (
                  <>
                    <ApproveButton farmer_id={farmer.id} fetchFarmers={fetchFarmers} />
                    <RejectButton farmer_id={farmer.id} fetchFarmers={fetchFarmers} />
                  </>
                ) : (
                  farmer.account_status
                )}
            </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
