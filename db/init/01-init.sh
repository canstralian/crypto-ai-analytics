#!/bin/bash

# Database initialization script for Docker
set -e

# Enable TimescaleDB extension
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS timescaledb;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";
EOSQL

echo "TimescaleDB extensions created successfully"

# Run schema creation
echo "Running schema creation..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/schema.sql

echo "Database schema created successfully"

# Insert initial system configuration
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    INSERT INTO system_config (key, value, description) VALUES
    ('app_version', '"1.0.0"', 'Application version'),
    ('maintenance_mode', 'false', 'Enable/disable maintenance mode'),
    ('max_portfolio_count', '10', 'Maximum portfolios per user'),
    ('max_alert_count', '50', 'Maximum alerts per user'),
    ('api_rate_limit', '{"requests": 1000, "window": 3600}', 'API rate limiting configuration'),
    ('data_retention_days', '730', 'Data retention period in days'),
    ('notification_settings', '{"email": true, "push": true, "sms": false}', 'Default notification settings')
    ON CONFLICT (key) DO NOTHING;
EOSQL

echo "System configuration inserted successfully"

# Create sample cryptocurrencies
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    INSERT INTO cryptocurrencies (symbol, name, slug, market_cap_rank, metadata) VALUES
    ('BTC', 'Bitcoin', 'bitcoin', 1, '{"website": "https://bitcoin.org", "description": "The first cryptocurrency"}'),
    ('ETH', 'Ethereum', 'ethereum', 2, '{"website": "https://ethereum.org", "description": "Smart contract platform"}'),
    ('BNB', 'BNB', 'bnb', 3, '{"website": "https://binance.com", "description": "Binance exchange token"}'),
    ('XRP', 'XRP', 'xrp', 4, '{"website": "https://ripple.com", "description": "Digital payment protocol"}'),
    ('ADA', 'Cardano', 'cardano', 5, '{"website": "https://cardano.org", "description": "Proof-of-stake blockchain platform"}'),
    ('DOGE', 'Dogecoin', 'dogecoin', 6, '{"website": "https://dogecoin.com", "description": "Meme-based cryptocurrency"}'),
    ('SOL', 'Solana', 'solana', 7, '{"website": "https://solana.com", "description": "High-performance blockchain"}'),
    ('TRX', 'TRON', 'tron', 8, '{"website": "https://tron.network", "description": "Decentralized internet protocol"}'),
    ('MATIC', 'Polygon', 'polygon', 9, '{"website": "https://polygon.technology", "description": "Ethereum scaling solution"}'),
    ('LTC', 'Litecoin', 'litecoin', 10, '{"website": "https://litecoin.org", "description": "Peer-to-peer cryptocurrency"}')
    ON CONFLICT (symbol) DO NOTHING;
EOSQL

echo "Sample cryptocurrencies inserted successfully"

# Create sample exchanges
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    INSERT INTO exchanges (name, slug, type, api_endpoint, websocket_endpoint, rate_limits, metadata) VALUES
    ('Binance', 'binance', 'binance', 'https://api.binance.com', 'wss://stream.binance.com:9443', '{"requests_per_minute": 1200}', '{"supported_features": ["spot", "futures", "margin"]}'),
    ('Coinbase Pro', 'coinbase-pro', 'coinbase', 'https://api.pro.coinbase.com', 'wss://ws-feed.pro.coinbase.com', '{"requests_per_second": 10}', '{"supported_features": ["spot"]}'),
    ('Kraken', 'kraken', 'kraken', 'https://api.kraken.com', 'wss://ws.kraken.com', '{"requests_per_minute": 60}', '{"supported_features": ["spot", "futures"]}'),
    ('Huobi Global', 'huobi', 'huobi', 'https://api.huobi.pro', 'wss://api.huobi.pro/ws', '{"requests_per_second": 100}', '{"supported_features": ["spot", "futures"]}'),
    ('KuCoin', 'kucoin', 'kucoin', 'https://api.kucoin.com', 'wss://ws-api.kucoin.com', '{"requests_per_second": 30}', '{"supported_features": ["spot", "futures"]}')
    ON CONFLICT (name) DO NOTHING;
EOSQL

echo "Sample exchanges inserted successfully"

echo "Database initialization completed!"