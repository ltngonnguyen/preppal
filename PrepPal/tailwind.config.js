/** @type {import('tailwindcss').Config} */

module.exports = {
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"], // Adjust if you create a src folder
  theme: {
    extend: {
      colors: {
        'primary': '#81B29A',   // Main Accent Green
        'secondary': '#F2CC8F', // Secondary Accent Gold/Yellow
        'background': '#FDFCF7', // Warm Off-White
        'card': '#FFFFFF',      // Pure White for cards
        'text-dark': '#3D405B', // Dark Blue/Gray for text
        'text-light': '#8D99AE', // Lighter Gray for subtitles
        'danger': '#E07A5F',     // Muted Red for alerts
        'warning-bg': '#FDF2E2', // Warm yellow background for warnings
        'warning-text': '#B48A3A', // Darker text for warnings
      }
    },
  },
  plugins: [],
};

