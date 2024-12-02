"use client"; // Marks this as a client-side component

import { useRouter } from 'next/navigation';

export const LogoutButton = () => {
  const router = useRouter();

  const handleLogout = async () => {
    try {
      const response = await fetch('http://127.0.0.1:8000/api/logout/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include', // Make sure to include credentials with the request
      });

      if (!response.ok) {
        throw new Error('Failed to log out.');
      }

      // Successfully logged out, redirect to login page
      router.push('/admin_login');
    } catch (error) {
      console.error('Error during logout:', error);
    }
  };

  return (
    <button
      onClick={handleLogout}
      style={{
        marginTop: '20px',
        background: '#444',
        color: '#fff',
        padding: '10px 20px',
        border: 'none',
        cursor: 'pointer',
        borderRadius: '6px',
      }}
    >
      Logout
    </button>
  );
};
