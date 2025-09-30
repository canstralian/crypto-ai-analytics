/**
 * Test utilities and helpers for frontend testing
 */
import React, { ReactElement } from 'react'
import { render, RenderOptions, RenderResult } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

// Mock providers that will be implemented later
interface TestProvidersProps {
  children: React.ReactNode
}

const TestProviders: React.FC<TestProvidersProps> = ({ children }) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  })

  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        {children}
      </BrowserRouter>
    </QueryClientProvider>
  )
}

const customRender = (
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
): RenderResult => render(ui, { wrapper: TestProviders, ...options })

// Mock user data
export const mockUser = {
  id: 'user-123',
  email: 'test@example.com',
  username: 'testuser',
  first_name: 'Test',
  last_name: 'User',
  role: 'user' as const,
  is_active: true,
  is_verified: true,
  created_at: '2024-01-01T00:00:00Z'
}

// Mock cryptocurrency data
export const mockCryptocurrency = {
  id: 'crypto-btc',
  symbol: 'BTC',
  name: 'Bitcoin',
  slug: 'bitcoin',
  market_cap_rank: 1,
  is_active: true,
  metadata: {
    website: 'https://bitcoin.org',
    description: 'The first cryptocurrency'
  }
}

// Mock market data
export const mockMarketData = {
  time: '2024-01-01T00:00:00Z',
  symbol: 'BTC',
  exchange: 'binance',
  open: 50000.00,
  high: 51000.00,
  low: 49000.00,
  close: 50500.00,
  volume: 1000.50,
  volume_usd: 50500000.00
}

// Mock portfolio data
export const mockPortfolio = {
  id: 'portfolio-1',
  name: 'Main Portfolio',
  description: 'Primary investment portfolio',
  type: 'spot' as const,
  is_default: true,
  is_public: false,
  total_value_usd: 50000.00,
  pnl_unrealized: 5000.00,
  pnl_realized: 2000.00,
  created_at: '2024-01-01T00:00:00Z'
}

// Mock portfolio holding data
export const mockPortfolioHolding = {
  id: 'holding-1',
  portfolio_id: 'portfolio-1',
  symbol: 'BTC',
  quantity: 1.5,
  avg_cost_usd: 30000.00,
  current_price_usd: 50000.00,
  value_usd: 75000.00,
  pnl_unrealized: 30000.00
}

// Mock API response helpers
export const mockApiResponse = <T>(data: T, status = 200) => ({
  data,
  status,
  statusText: 'OK',
  headers: {},
  config: {}
})

export const mockApiError = (message = 'API Error', status = 500) => ({
  response: {
    data: { message },
    status,
    statusText: 'Internal Server Error'
  }
})

// Utility to wait for async operations
export const waitForNextTick = () => 
  new Promise(resolve => setTimeout(resolve, 0))

// Mock intersection observer for chart components
export const mockIntersectionObserver = () => {
  const mockIntersect = jest.fn()
  const mockObserve = jest.fn()
  const mockUnobserve = jest.fn()
  const mockDisconnect = jest.fn()

  global.IntersectionObserver = jest.fn().mockImplementation(() => ({
    observe: mockObserve,
    unobserve: mockUnobserve,
    disconnect: mockDisconnect,
    root: null,
    rootMargin: '',
    thresholds: []
  }))

  return { mockIntersect, mockObserve, mockUnobserve, mockDisconnect }
}

// Mock resize observer for responsive components
export const mockResizeObserver = () => {
  const mockObserve = jest.fn()
  const mockUnobserve = jest.fn()
  const mockDisconnect = jest.fn()

  global.ResizeObserver = jest.fn().mockImplementation(() => ({
    observe: mockObserve,
    unobserve: mockUnobserve,
    disconnect: mockDisconnect
  }))

  return { mockObserve, mockUnobserve, mockDisconnect }
}

// Mock WebSocket for real-time features
export const mockWebSocket = () => {
  const mockSend = jest.fn()
  const mockClose = jest.fn()
  const mockAddEventListener = jest.fn()
  const mockRemoveEventListener = jest.fn()

  const mockWS = {
    send: mockSend,
    close: mockClose,
    addEventListener: mockAddEventListener,
    removeEventListener: mockRemoveEventListener,
    readyState: WebSocket.OPEN,
    CONNECTING: WebSocket.CONNECTING,
    OPEN: WebSocket.OPEN,
    CLOSING: WebSocket.CLOSING,
    CLOSED: WebSocket.CLOSED
  }

  global.WebSocket = jest.fn().mockImplementation(() => mockWS)

  return { mockWS, mockSend, mockClose, mockAddEventListener, mockRemoveEventListener }
}

// Re-export everything from testing-library
export * from '@testing-library/react'
export { customRender as render }