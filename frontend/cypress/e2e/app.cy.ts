describe('Application Health Check', () => {
  it('should load the application successfully', () => {
    cy.visit('/')
    cy.contains('Crypto AI Analytics')
    cy.getByTestId('app-container').should('be.visible')
  })

  it('should display loading state initially', () => {
    cy.visit('/')
    cy.getByTestId('loading-spinner').should('be.visible')
    cy.waitForPageLoad()
  })

  it('should handle API health check', () => {
    cy.visit('/')
    cy.wait('@getHealth').then((interception) => {
      expect(interception.response?.statusCode).to.equal(200)
    })
  })

  it('should have proper meta tags', () => {
    cy.visit('/')
    cy.get('title').should('contain', 'Crypto AI Analytics')
    cy.get('meta[name="description"]').should('exist')
    cy.get('meta[name="viewport"]').should('exist')
  })

  it('should be accessible', () => {
    cy.visit('/')
    cy.checkAccessibility()
  })
})

describe('Navigation', () => {
  beforeEach(() => {
    cy.visitWithAuth('/')
  })

  it('should navigate to dashboard', () => {
    cy.getByTestId('nav-dashboard').click()
    cy.url().should('include', '/dashboard')
    cy.contains('Dashboard')
  })

  it('should navigate to portfolios', () => {
    cy.getByTestId('nav-portfolios').click()
    cy.url().should('include', '/portfolios')
    cy.contains('Portfolios')
  })

  it('should navigate to alerts', () => {
    cy.getByTestId('nav-alerts').click()
    cy.url().should('include', '/alerts')
    cy.contains('Alerts')
  })

  it('should navigate to analytics', () => {
    cy.getByTestId('nav-analytics').click()
    cy.url().should('include', '/analytics')
    cy.contains('Analytics')
  })
})

describe('Responsive Design', () => {
  const viewports = [
    { device: 'mobile', width: 375, height: 667 },
    { device: 'tablet', width: 768, height: 1024 },
    { device: 'desktop', width: 1920, height: 1080 }
  ]

  viewports.forEach(({ device, width, height }) => {
    it(`should render correctly on ${device}`, () => {
      cy.viewport(width, height)
      cy.visitWithAuth('/')
      
      // Check that main elements are visible
      cy.getByTestId('app-container').should('be.visible')
      cy.getByTestId('navigation').should('be.visible')
      
      // Check navigation behavior on mobile
      if (device === 'mobile') {
        cy.getByTestId('mobile-menu-toggle').should('be.visible')
        cy.getByTestId('mobile-menu-toggle').click()
        cy.getByTestId('mobile-navigation').should('be.visible')
      }
    })
  })
})

describe('Error Handling', () => {
  it('should handle 404 errors gracefully', () => {
    cy.visit('/non-existent-page', { failOnStatusCode: false })
    cy.contains('Page Not Found')
    cy.getByTestId('404-page').should('be.visible')
    cy.getByTestId('back-to-home').click()
    cy.url().should('equal', Cypress.config().baseUrl + '/')
  })

  it('should handle API errors gracefully', () => {
    cy.intercept('GET', '**/api/v1/**', { forceNetworkError: true }).as('networkError')
    cy.visitWithAuth('/')
    cy.getByTestId('error-message').should('be.visible')
    cy.contains('Unable to connect to server')
  })

  it('should handle authentication errors', () => {
    cy.intercept('GET', '**/api/v1/auth/me', { statusCode: 401 }).as('authError')
    cy.visit('/')
    cy.url().should('include', '/login')
  })
})