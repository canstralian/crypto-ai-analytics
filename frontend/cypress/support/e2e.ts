// ***********************************************************
// This example support/e2e.ts is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import './commands'

// Alternatively you can use CommonJS syntax:
// require('./commands')

// Hide fetch/XHR requests from command log
Cypress.on('window:before:load', (win) => {
  cy.stub(win.console, 'error').callThrough()
  cy.stub(win.console, 'warn').callThrough()
})

// Global error handling
Cypress.on('uncaught:exception', (err, runnable) => {
  // Returning false here prevents Cypress from failing the test
  if (err.message.includes('ResizeObserver loop limit exceeded')) {
    return false
  }
  return true
})

// Set up API mocking
beforeEach(() => {
  // Mock API endpoints
  cy.intercept('GET', '/api/v1/health', { fixture: 'health.json' }).as('getHealth')
  cy.intercept('GET', '/api/v1/auth/me', { fixture: 'user.json' }).as('getCurrentUser')
  cy.intercept('GET', '/api/v1/cryptocurrencies', { fixture: 'cryptocurrencies.json' }).as('getCryptocurrencies')
  cy.intercept('GET', '/api/v1/portfolios', { fixture: 'portfolios.json' }).as('getPortfolios')
})

// Custom commands for authentication
Cypress.Commands.add('login', (email = 'test@example.com', password = 'password123') => {
  cy.session([email, password], () => {
    cy.visit('/login')
    cy.get('[data-testid="email-input"]').type(email)
    cy.get('[data-testid="password-input"]').type(password)
    cy.get('[data-testid="login-button"]').click()
    cy.url().should('not.include', '/login')
  })
})

Cypress.Commands.add('logout', () => {
  cy.get('[data-testid="user-menu"]').click()
  cy.get('[data-testid="logout-button"]').click()
  cy.url().should('include', '/login')
})

// Add custom commands type definitions
declare global {
  namespace Cypress {
    interface Chainable {
      login(email?: string, password?: string): Chainable<void>
      logout(): Chainable<void>
    }
  }
}