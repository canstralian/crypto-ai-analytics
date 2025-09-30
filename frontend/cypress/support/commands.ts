// ***********************************************
// This example commands.ts shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************

// General utility commands
Cypress.Commands.add('getByTestId', (testId: string) => {
  return cy.get(`[data-testid="${testId}"]`)
})

Cypress.Commands.add('waitForPageLoad', () => {
  cy.get('[data-testid="loading-spinner"]', { timeout: 10000 }).should('not.exist')
})

Cypress.Commands.add('checkAccessibility', () => {
  // Add accessibility checks here
  // This would integrate with axe-core or similar
  cy.log('Checking accessibility...')
})

// API helper commands
Cypress.Commands.add('apiRequest', (method: string, url: string, body?: any) => {
  return cy.request({
    method,
    url: `${Cypress.env('apiUrl')}${url}`,
    body,
    failOnStatusCode: false,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${window.localStorage.getItem('authToken')}`
    }
  })
})

// Form helper commands
Cypress.Commands.add('fillForm', (formData: Record<string, string>) => {
  Object.keys(formData).forEach(key => {
    cy.getByTestId(`${key}-input`).clear().type(formData[key])
  })
})

Cypress.Commands.add('submitForm', (formTestId = 'form') => {
  cy.getByTestId(formTestId).submit()
})

// Navigation commands
Cypress.Commands.add('visitWithAuth', (url: string) => {
  cy.login()
  cy.visit(url)
  cy.waitForPageLoad()
})

// Mock data commands
Cypress.Commands.add('mockApiResponse', (endpoint: string, fixture: string) => {
  cy.intercept('GET', `**/api/v1${endpoint}`, { fixture }).as(`mock${endpoint.replace(/\//g, '')}`)
})

// Table interaction commands
Cypress.Commands.add('sortTableBy', (column: string) => {
  cy.getByTestId(`sort-${column}`).click()
})

Cypress.Commands.add('filterTable', (filterValue: string) => {
  cy.getByTestId('table-filter').type(filterValue)
})

// Chart interaction commands
Cypress.Commands.add('hoverOverChart', (chartElement: string) => {
  cy.getByTestId(chartElement).trigger('mouseover')
})

// Portfolio specific commands
Cypress.Commands.add('createPortfolio', (name: string, description?: string) => {
  cy.getByTestId('create-portfolio-button').click()
  cy.getByTestId('portfolio-name-input').type(name)
  if (description) {
    cy.getByTestId('portfolio-description-input').type(description)
  }
  cy.getByTestId('save-portfolio-button').click()
})

// Alert specific commands
Cypress.Commands.add('createPriceAlert', (symbol: string, condition: string, value: number) => {
  cy.getByTestId('create-alert-button').click()
  cy.getByTestId('alert-symbol-select').select(symbol)
  cy.getByTestId('alert-condition-select').select(condition)
  cy.getByTestId('alert-value-input').type(value.toString())
  cy.getByTestId('save-alert-button').click()
})

// Declare command types
declare global {
  namespace Cypress {
    interface Chainable {
      getByTestId(testId: string): Chainable<JQuery<HTMLElement>>
      waitForPageLoad(): Chainable<void>
      checkAccessibility(): Chainable<void>
      apiRequest(method: string, url: string, body?: any): Chainable<Cypress.Response<any>>
      fillForm(formData: Record<string, string>): Chainable<void>
      submitForm(formTestId?: string): Chainable<void>
      visitWithAuth(url: string): Chainable<void>
      mockApiResponse(endpoint: string, fixture: string): Chainable<void>
      sortTableBy(column: string): Chainable<void>
      filterTable(filterValue: string): Chainable<void>
      hoverOverChart(chartElement: string): Chainable<void>
      createPortfolio(name: string, description?: string): Chainable<void>
      createPriceAlert(symbol: string, condition: string, value: number): Chainable<void>
    }
  }
}