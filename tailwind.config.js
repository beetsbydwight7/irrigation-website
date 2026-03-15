/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./*.{html,js}"],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#1B4D3E', // Forest Green
          light: '#2C6B58',
          dark: '#123329',
        },
        secondary: {
          DEFAULT: '#00A3E0', // Water Blue
          light: '#33B5E6',
          dark: '#007AAB',
        },
        accent: {
          DEFAULT: '#F2A900', // Gold/Amber
          hover: '#D49200',
        },
        neutral: {
          light: '#F9FAFB',
          DEFAULT: '#1F2937',
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'], // Professional, clean font
      },
      backgroundImage: {
        'hero-pattern': "url('../assets/images/hero-bg.webp')", // Placeholder
      }
    },
  },
  plugins: [],
}
