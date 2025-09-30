-- Initialize TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create custom data types
CREATE TYPE user_role AS ENUM ('user', 'admin', 'moderator');
CREATE TYPE portfolio_type AS ENUM ('spot', 'futures', 'margin');
CREATE TYPE alert_type AS ENUM ('price', 'volume', 'technical', 'sentiment', 'portfolio');
CREATE TYPE alert_status AS ENUM ('active', 'triggered', 'paused', 'disabled');
CREATE TYPE order_type AS ENUM ('buy', 'sell');
CREATE TYPE order_status AS ENUM ('pending', 'filled', 'cancelled', 'failed');
CREATE TYPE exchange_type AS ENUM ('binance', 'coinbase', 'kraken', 'huobi', 'kucoin');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role user_role DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    email_verified_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- User sessions table
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    device_info JSONB,
    ip_address INET,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ
);

-- OAuth accounts table
CREATE TABLE oauth_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider, provider_id)
);

-- Cryptocurrencies table
CREATE TABLE cryptocurrencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    market_cap_rank INTEGER,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Exchanges table
CREATE TABLE exchanges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    type exchange_type NOT NULL,
    api_endpoint VARCHAR(500),
    websocket_endpoint VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    rate_limits JSONB,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Market data time series (TimescaleDB hypertable)
CREATE TABLE market_data (
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    exchange VARCHAR(100) NOT NULL,
    open DECIMAL(20, 8),
    high DECIMAL(20, 8),
    low DECIMAL(20, 8),
    close DECIMAL(20, 8),
    volume DECIMAL(20, 8),
    volume_usd DECIMAL(20, 2),
    market_cap DECIMAL(20, 2),
    trade_count INTEGER,
    metadata JSONB,
    PRIMARY KEY (time, symbol, exchange)
);

-- Convert market_data to hypertable
SELECT create_hypertable('market_data', 'time', chunk_time_interval => INTERVAL '1 day');

-- Blockchain data time series
CREATE TABLE blockchain_data (
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    block_height BIGINT,
    transaction_count INTEGER,
    active_addresses INTEGER,
    network_hash_rate DECIMAL(30, 8),
    difficulty DECIMAL(30, 8),
    total_supply DECIMAL(30, 8),
    circulating_supply DECIMAL(30, 8),
    fees_total DECIMAL(20, 8),
    fees_avg DECIMAL(20, 8),
    metadata JSONB,
    PRIMARY KEY (time, symbol)
);

-- Convert blockchain_data to hypertable
SELECT create_hypertable('blockchain_data', 'time', chunk_time_interval => INTERVAL '1 day');

-- Social sentiment data time series
CREATE TABLE social_sentiment (
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    sentiment_score DECIMAL(5, 4),
    mention_count INTEGER,
    positive_mentions INTEGER,
    negative_mentions INTEGER,
    neutral_mentions INTEGER,
    volume_weighted_sentiment DECIMAL(5, 4),
    metadata JSONB,
    PRIMARY KEY (time, symbol, platform)
);

-- Convert social_sentiment to hypertable
SELECT create_hypertable('social_sentiment', 'time', chunk_time_interval => INTERVAL '1 hour');

-- News sentiment data
CREATE TABLE news_sentiment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    time TIMESTAMPTZ NOT NULL,
    title VARCHAR(500) NOT NULL,
    content TEXT,
    url VARCHAR(1000),
    source VARCHAR(100),
    author VARCHAR(200),
    symbols VARCHAR(200)[], -- Array of related symbols
    sentiment_score DECIMAL(5, 4),
    confidence_score DECIMAL(5, 4),
    keywords TEXT[],
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert news_sentiment to hypertable
SELECT create_hypertable('news_sentiment', 'time', chunk_time_interval => INTERVAL '1 day');

-- ML model predictions
CREATE TABLE ml_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    model_version VARCHAR(50) NOT NULL,
    prediction_type VARCHAR(50) NOT NULL, -- price, volatility, trend, etc.
    timeframe VARCHAR(20) NOT NULL, -- 1h, 4h, 1d, etc.
    predicted_value DECIMAL(20, 8),
    confidence_score DECIMAL(5, 4),
    features JSONB,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert ml_predictions to hypertable
SELECT create_hypertable('ml_predictions', 'time', chunk_time_interval => INTERVAL '1 day');

-- User portfolios
CREATE TABLE portfolios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type portfolio_type DEFAULT 'spot',
    is_default BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    total_value_usd DECIMAL(20, 2) DEFAULT 0,
    pnl_unrealized DECIMAL(20, 2) DEFAULT 0,
    pnl_realized DECIMAL(20, 2) DEFAULT 0,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, name)
);

-- Portfolio holdings
CREATE TABLE portfolio_holdings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id UUID NOT NULL REFERENCES portfolios(id) ON DELETE CASCADE,
    symbol VARCHAR(20) NOT NULL,
    quantity DECIMAL(30, 8) NOT NULL DEFAULT 0,
    avg_cost_usd DECIMAL(20, 8),
    current_price_usd DECIMAL(20, 8),
    value_usd DECIMAL(20, 2),
    pnl_unrealized DECIMAL(20, 2),
    pnl_realized DECIMAL(20, 2),
    first_acquired_at TIMESTAMPTZ,
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB,
    UNIQUE(portfolio_id, symbol)
);

-- Portfolio history (time series)
CREATE TABLE portfolio_history (
    time TIMESTAMPTZ NOT NULL,
    portfolio_id UUID NOT NULL REFERENCES portfolios(id) ON DELETE CASCADE,
    total_value_usd DECIMAL(20, 2),
    pnl_unrealized DECIMAL(20, 2),
    pnl_realized DECIMAL(20, 2),
    holdings JSONB,
    metadata JSONB,
    PRIMARY KEY (time, portfolio_id)
);

-- Convert portfolio_history to hypertable
SELECT create_hypertable('portfolio_history', 'time', chunk_time_interval => INTERVAL '1 day');

-- Transactions
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    portfolio_id UUID REFERENCES portfolios(id) ON DELETE SET NULL,
    symbol VARCHAR(20) NOT NULL,
    type order_type NOT NULL,
    quantity DECIMAL(30, 8) NOT NULL,
    price_usd DECIMAL(20, 8) NOT NULL,
    fee_usd DECIMAL(20, 8) DEFAULT 0,
    total_usd DECIMAL(20, 2) NOT NULL,
    exchange VARCHAR(100),
    external_id VARCHAR(255),
    status order_status DEFAULT 'pending',
    executed_at TIMESTAMPTZ,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User alerts
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type alert_type NOT NULL,
    conditions JSONB NOT NULL,
    actions JSONB NOT NULL,
    status alert_status DEFAULT 'active',
    priority INTEGER DEFAULT 1,
    is_recurring BOOLEAN DEFAULT false,
    last_triggered_at TIMESTAMPTZ,
    trigger_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alert history
CREATE TABLE alert_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES alerts(id) ON DELETE CASCADE,
    triggered_at TIMESTAMPTZ NOT NULL,
    trigger_data JSONB,
    actions_executed JSONB,
    metadata JSONB
);

-- User API keys
CREATE TABLE user_api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    key_hash VARCHAR(255) NOT NULL UNIQUE,
    permissions TEXT[] DEFAULT '{"read"}',
    last_used_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit log
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100),
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert audit_log to hypertable
SELECT create_hypertable('audit_log', 'created_at', chunk_time_interval => INTERVAL '1 week');

-- System configuration
CREATE TABLE system_config (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ML model metadata
CREATE TABLE ml_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL,
    description TEXT,
    model_type VARCHAR(50) NOT NULL,
    target_symbols VARCHAR(20)[],
    features JSONB,
    hyperparameters JSONB,
    metrics JSONB,
    status VARCHAR(20) DEFAULT 'training',
    model_path VARCHAR(500),
    is_active BOOLEAN DEFAULT false,
    trained_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(name, version)
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token_hash ON user_sessions(token_hash);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

CREATE INDEX idx_oauth_accounts_user_id ON oauth_accounts(user_id);
CREATE INDEX idx_oauth_accounts_provider ON oauth_accounts(provider, provider_id);

CREATE INDEX idx_cryptocurrencies_symbol ON cryptocurrencies(symbol);
CREATE INDEX idx_cryptocurrencies_market_cap_rank ON cryptocurrencies(market_cap_rank);

CREATE INDEX idx_exchanges_name ON exchanges(name);
CREATE INDEX idx_exchanges_type ON exchanges(type);

CREATE INDEX idx_market_data_symbol ON market_data(symbol, time DESC);
CREATE INDEX idx_market_data_exchange ON market_data(exchange, time DESC);

CREATE INDEX idx_blockchain_data_symbol ON blockchain_data(symbol, time DESC);

CREATE INDEX idx_social_sentiment_symbol ON social_sentiment(symbol, time DESC);
CREATE INDEX idx_social_sentiment_platform ON social_sentiment(platform, time DESC);

CREATE INDEX idx_news_sentiment_symbols ON news_sentiment USING GIN(symbols);
CREATE INDEX idx_news_sentiment_time ON news_sentiment(time DESC);

CREATE INDEX idx_ml_predictions_symbol ON ml_predictions(symbol, time DESC);
CREATE INDEX idx_ml_predictions_model ON ml_predictions(model_name, model_version);

CREATE INDEX idx_portfolios_user_id ON portfolios(user_id);
CREATE INDEX idx_portfolios_is_default ON portfolios(user_id, is_default);

CREATE INDEX idx_portfolio_holdings_portfolio_id ON portfolio_holdings(portfolio_id);
CREATE INDEX idx_portfolio_holdings_symbol ON portfolio_holdings(symbol);

CREATE INDEX idx_portfolio_history_portfolio_id ON portfolio_history(portfolio_id, time DESC);

CREATE INDEX idx_transactions_user_id ON transactions(user_id, created_at DESC);
CREATE INDEX idx_transactions_portfolio_id ON transactions(portfolio_id, created_at DESC);
CREATE INDEX idx_transactions_symbol ON transactions(symbol, created_at DESC);

CREATE INDEX idx_alerts_user_id ON alerts(user_id);
CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alerts_type ON alerts(type);

CREATE INDEX idx_alert_history_alert_id ON alert_history(alert_id, triggered_at DESC);

CREATE INDEX idx_user_api_keys_user_id ON user_api_keys(user_id);
CREATE INDEX idx_user_api_keys_key_hash ON user_api_keys(key_hash);

CREATE INDEX idx_audit_log_user_id ON audit_log(user_id, created_at DESC);
CREATE INDEX idx_audit_log_action ON audit_log(action, created_at DESC);
CREATE INDEX idx_audit_log_resource ON audit_log(resource_type, resource_id);

CREATE INDEX idx_ml_models_name_version ON ml_models(name, version);
CREATE INDEX idx_ml_models_status ON ml_models(status);
CREATE INDEX idx_ml_models_is_active ON ml_models(is_active);

-- Create functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_oauth_accounts_updated_at BEFORE UPDATE ON oauth_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cryptocurrencies_updated_at BEFORE UPDATE ON cryptocurrencies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_exchanges_updated_at BEFORE UPDATE ON exchanges
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_portfolios_updated_at BEFORE UPDATE ON portfolios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_alerts_updated_at BEFORE UPDATE ON alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_api_keys_updated_at BEFORE UPDATE ON user_api_keys
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ml_models_updated_at BEFORE UPDATE ON ml_models
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create data retention policies (keep data for 2 years by default)
SELECT add_retention_policy('market_data', INTERVAL '2 years');
SELECT add_retention_policy('blockchain_data', INTERVAL '2 years');
SELECT add_retention_policy('social_sentiment', INTERVAL '1 year');
SELECT add_retention_policy('news_sentiment', INTERVAL '1 year');
SELECT add_retention_policy('ml_predictions', INTERVAL '1 year');
SELECT add_retention_policy('portfolio_history', INTERVAL '5 years');
SELECT add_retention_policy('audit_log', INTERVAL '7 years');