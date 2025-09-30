# Crypto-AI Analytics

A comprehensive platform for cryptocurrency analytics powered by artificial intelligence, providing real-time market insights, predictive models, and portfolio management tools.

## Features

- **Real-time Data Ingestion**: Multi-source data collection from crypto exchanges, blockchain networks, and social media
- **AI-Powered Analytics**: Advanced machine learning models for price prediction, volatility analysis, and sentiment analysis
- **Portfolio Management**: Comprehensive portfolio tracking and performance analytics
- **Real-time Alerts**: Customizable notifications based on market conditions and AI predictions
- **Interactive Dashboard**: Modern React-based UI with real-time charts and visualizations
- **Model Explainability**: SHAP-powered insights into AI model decision-making

## Architecture

- **Backend**: FastAPI with Python, PostgreSQL with TimescaleDB
- **Frontend**: React with TypeScript and Material-UI
- **ML/AI**: PyTorch, scikit-learn, TensorFlow with TorchServe deployment
- **Infrastructure**: AWS EKS, RDS, S3, with Terraform provisioning
- **Data Pipeline**: Kafka, Celery, Redis for real-time processing
- **Monitoring**: OpenTelemetry, Prometheus, Grafana

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ and npm
- Python 3.11+
- Terraform (for infrastructure)
- kubectl (for Kubernetes deployment)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/canstralian/crypto-ai-analytics.git
cd crypto-ai-analytics

# Start development environment
make dev-setup
make dev-start

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Documentation: http://localhost:8000/docs
```

### Production Deployment

```bash
# Deploy infrastructure
cd infra/terraform
terraform init
terraform plan
terraform apply

# Deploy application
make deploy-prod
```

## Project Structure

```
crypto-ai-analytics/
├── backend/                 # FastAPI backend application
├── frontend/               # React frontend application
├── ml/                     # Machine learning models and training
├── infra/                  # Infrastructure as code (Terraform)
├── docker/                 # Docker configurations
├── k8s/                    # Kubernetes manifests
├── db/                     # Database schemas and migrations
├── tests/                  # Integration and E2E tests
├── docs/                   # Documentation
└── scripts/                # Utility scripts
```

## Development

### Running Tests

```bash
# Backend tests
make test-backend

# Frontend tests
make test-frontend

# Integration tests
make test-integration

# All tests
make test
```

### Code Quality

```bash
# Linting
make lint

# Security scanning
make security-scan

# Type checking
make type-check
```

## API Documentation

The API documentation is automatically generated and available at:
- Development: http://localhost:8000/docs
- Production: https://api.crypto-ai-analytics.com/docs

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

For security issues, please email security@crypto-ai-analytics.com instead of opening a public issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: [docs.crypto-ai-analytics.com](https://docs.crypto-ai-analytics.com)
- Issues: [GitHub Issues](https://github.com/canstralian/crypto-ai-analytics/issues)
- Discussions: [GitHub Discussions](https://github.com/canstralian/crypto-ai-analytics/discussions)