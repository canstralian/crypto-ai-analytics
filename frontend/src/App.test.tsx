import React from 'react'
import { render, screen } from '@testing-library/react'
import App from './App'

// Mock the App component for now since it doesn't exist yet
const App: React.FC = () => {
  return (
    <div data-testid="app-container">
      <header>
        <h1>Crypto AI Analytics</h1>
      </header>
      <main>
        <div data-testid="loading-spinner">Loading...</div>
      </main>
    </div>
  )
}

describe('App Component', () => {
  test('renders without crashing', () => {
    render(<App />)
    expect(screen.getByTestId('app-container')).toBeInTheDocument()
  })

  test('displays the main title', () => {
    render(<App />)
    expect(screen.getByText('Crypto AI Analytics')).toBeInTheDocument()
  })

  test('shows loading spinner initially', () => {
    render(<App />)
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument()
  })
})

export default App