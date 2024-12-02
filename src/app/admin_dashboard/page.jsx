"use client";

import { useState, useEffect } from 'react';
import { UserTable } from '../components/user_table';
import { FarmerTable } from '../components/farmer_table';
import { LogoutButton } from '../components/logout_button';
import { useRouter } from 'next/navigation'; // Import useRouter from next/navigation

const AdminDashboard = () => {
  const [activeSection, setActiveSection] = useState('users');
  const [data, setData] = useState({ farmers: [], buyers: [] }); // State for fetched data
  const [loading, setLoading] = useState(true); // Loading state
  const [error, setError] = useState(null); // Error state
  const router = useRouter(); // Initialize useRouter

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch('http://127.0.0.1:8000/api/dashboard/', {
          method: 'GET',
          credentials: 'include', // Ensure cookies are sent with the request
        });
        if (!response.ok) {
          throw new Error('Failed to fetch data');
        }
        const result = await response.json();
        setData(result); // Set fetched data
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []); // Empty dependency array to run this effect only once on mount

  const handleNavigation = (section) => {
    setActiveSection(section); // Set active section state
    router.push(`#${section}`); // Navigate to the corresponding section (optional: anchor navigation)
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div style={{ display: 'flex', height: '100vh' }}>
      {/* Navbar */}
      <nav style={{ width: '200px', backgroundColor: '#333', color: '#fff', padding: '20px' }}>
        <h2>Admin Panel</h2>
        <button
          onClick={() => handleNavigation('users')}
          style={{
            display: 'block',
            margin: '10px 0',
            background: activeSection === 'users' ? '#555' : '#444',
            color: '#fff',
            padding: '10px',
            width: '100%',
            border: 'none',
            cursor: 'pointer',
            borderRadius: '6px',
          }}
        >
          Users Section
        </button>
        <button
          onClick={() => handleNavigation('farmers')}
          style={{
            display: 'block',
            margin: '10px 0',
            background: activeSection === 'farmers' ? '#555' : '#444',
            color: '#fff',
            padding: '10px',
            width: '100%',
            border: 'none',
            cursor: 'pointer',
            borderRadius: '6px',
          }}
        >
          Farmers Section
        </button>
        <LogoutButton />
      </nav>

      {/* Content Div */}
      <div style={{ flex: 1, padding: '20px' }}>
        {activeSection === 'users' && <UserTable users={data.buyers} />}
        {activeSection === 'farmers' && <FarmerTable farmers={data.farmers} />}
      </div>
    </div>
  );
};

export default AdminDashboard;
