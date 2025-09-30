"""
Test configuration and fixtures for backend tests.
"""
import asyncio
import os
import pytest
import pytest_asyncio
from typing import AsyncGenerator, Generator
from unittest.mock import AsyncMock, MagicMock

import httpx
from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient

# Test database URL
TEST_DATABASE_URL = os.getenv("TEST_DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/crypto_ai_test")
TEST_DATABASE_URL_ASYNC = TEST_DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://")

# Test engine and session
test_engine = create_engine(TEST_DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

# Async test engine and session
test_async_engine = create_async_engine(TEST_DATABASE_URL_ASYNC)
AsyncTestingSessionLocal = async_sessionmaker(
    test_async_engine, class_=AsyncSession, expire_on_commit=False
)


@pytest.fixture(scope="session")
def event_loop() -> Generator[asyncio.AbstractEventLoop, None, None]:
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture
async def async_db_session() -> AsyncGenerator[AsyncSession, None]:
    """Create a fresh async database session for each test."""
    async with test_async_engine.begin() as connection:
        async with AsyncTestingSessionLocal(bind=connection) as session:
            yield session


@pytest.fixture
def db_session() -> Generator[TestingSessionLocal, None, None]:
    """Create a fresh database session for each test."""
    connection = test_engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture
def client() -> Generator[TestClient, None, None]:
    """Create a test client with dependency overrides."""
    # This will be implemented when we have the FastAPI app
    # from app.main import app
    # from app.database import get_db
    # 
    # def override_get_db():
    #     yield db_session
    # 
    # app.dependency_overrides[get_db] = override_get_db
    # 
    # with TestClient(app) as test_client:
    #     yield test_client
    # 
    # app.dependency_overrides.clear()
    pass


@pytest_asyncio.fixture
async def async_client() -> AsyncGenerator[httpx.AsyncClient, None]:
    """Create an async test client."""
    # This will be implemented when we have the FastAPI app
    # from app.main import app
    # 
    # async with httpx.AsyncClient(app=app, base_url="http://test") as async_client:
    #     yield async_client
    pass


@pytest.fixture
def mock_redis() -> Generator[MagicMock, None, None]:
    """Mock Redis client."""
    mock_redis = MagicMock()
    mock_redis.get = AsyncMock(return_value=None)
    mock_redis.set = AsyncMock(return_value=True)
    mock_redis.delete = AsyncMock(return_value=1)
    mock_redis.exists = AsyncMock(return_value=False)
    mock_redis.expire = AsyncMock(return_value=True)
    yield mock_redis


@pytest.fixture
def mock_kafka_producer() -> Generator[MagicMock, None, None]:
    """Mock Kafka producer."""
    mock_producer = MagicMock()
    mock_producer.send = AsyncMock()
    mock_producer.flush = AsyncMock()
    yield mock_producer


@pytest.fixture
def mock_kafka_consumer() -> Generator[MagicMock, None, None]:
    """Mock Kafka consumer."""
    mock_consumer = MagicMock()
    mock_consumer.start = AsyncMock()
    mock_consumer.stop = AsyncMock()
    mock_consumer.subscribe = AsyncMock()
    yield mock_consumer


@pytest.fixture
def sample_user_data() -> dict:
    """Sample user data for testing."""
    return {
        "email": "test@example.com",
        "username": "testuser",
        "password": "testpassword123",
        "first_name": "Test",
        "last_name": "User"
    }


@pytest.fixture
def sample_crypto_data() -> dict:
    """Sample cryptocurrency data for testing."""
    return {
        "symbol": "BTC",
        "name": "Bitcoin",
        "slug": "bitcoin",
        "market_cap_rank": 1,
        "metadata": {
            "website": "https://bitcoin.org",
            "description": "The first cryptocurrency"
        }
    }


@pytest.fixture
def sample_market_data() -> dict:
    """Sample market data for testing."""
    from datetime import datetime
    return {
        "time": datetime.utcnow(),
        "symbol": "BTC",
        "exchange": "binance",
        "open": 50000.00,
        "high": 51000.00,
        "low": 49000.00,
        "close": 50500.00,
        "volume": 1000.50,
        "volume_usd": 50500000.00
    }


@pytest.fixture
def sample_portfolio_data() -> dict:
    """Sample portfolio data for testing."""
    return {
        "name": "Test Portfolio",
        "description": "A test portfolio",
        "type": "spot",
        "is_public": False
    }


@pytest.fixture
def authenticated_headers() -> dict:
    """Create headers for authenticated requests."""
    return {
        "Authorization": "Bearer test_token",
        "Content-Type": "application/json"
    }


@pytest.fixture
def mock_external_apis() -> Generator[MagicMock, None, None]:
    """Mock external API responses."""
    import responses
    
    # Mock Binance API
    responses.add(
        responses.GET,
        "https://api.binance.com/api/v3/ticker/price",
        json={"symbol": "BTCUSDT", "price": "50000.00"},
        status=200
    )
    
    # Mock CoinGecko API
    responses.add(
        responses.GET,
        "https://api.coingecko.com/api/v3/simple/price",
        json={"bitcoin": {"usd": 50000}},
        status=200
    )
    
    # Mock Twitter API
    responses.add(
        responses.GET,
        "https://api.twitter.com/2/tweets/search/recent",
        json={"data": [], "meta": {"result_count": 0}},
        status=200
    )
    
    yield responses


@pytest.fixture
def mock_ml_model() -> Generator[MagicMock, None, None]:
    """Mock ML model for testing."""
    mock_model = MagicMock()
    mock_model.predict = MagicMock(return_value=[0.5])
    mock_model.predict_proba = MagicMock(return_value=[[0.3, 0.7]])
    mock_model.score = MagicMock(return_value=0.85)
    yield mock_model


@pytest.fixture
def mock_s3_client() -> Generator[MagicMock, None, None]:
    """Mock S3 client for testing."""
    mock_s3 = MagicMock()
    mock_s3.upload_file = MagicMock(return_value=True)
    mock_s3.download_file = MagicMock(return_value=True)
    mock_s3.list_objects_v2 = MagicMock(return_value={"Contents": []})
    yield mock_s3


class TestSettings:
    """Test configuration settings."""
    DATABASE_URL = TEST_DATABASE_URL
    DATABASE_URL_ASYNC = TEST_DATABASE_URL_ASYNC
    REDIS_URL = "redis://localhost:6379/1"
    KAFKA_BOOTSTRAP_SERVERS = "localhost:9092"
    JWT_SECRET = "test_secret_key"
    ENVIRONMENT = "test"
    DEBUG = True
    TESTING = True


@pytest.fixture
def test_settings() -> TestSettings:
    """Test configuration settings."""
    return TestSettings()


def pytest_configure(config) -> None:
    """Configure pytest with custom settings."""
    # Set environment variables for testing
    os.environ["ENVIRONMENT"] = "test"
    os.environ["DATABASE_URL"] = TEST_DATABASE_URL
    os.environ["TESTING"] = "true"
    os.environ["JWT_SECRET"] = "test_secret_key"


def pytest_collection_modifyitems(config, items) -> None:
    """Modify test collection to add markers automatically."""
    for item in items:
        # Add marker based on test file location
        if "integration" in str(item.fspath):
            item.add_marker(pytest.mark.integration)
        elif "unit" in str(item.fspath):
            item.add_marker(pytest.mark.unit)
        elif "e2e" in str(item.fspath):
            item.add_marker(pytest.mark.e2e)
        
        # Add slow marker for tests that might be slow
        if any(keyword in item.name.lower() for keyword in ["slow", "integration", "external", "ml"]):
            item.add_marker(pytest.mark.slow)
        
        # Add database marker for tests that use database
        if any(keyword in item.name.lower() for keyword in ["db", "database", "sql"]):
            item.add_marker(pytest.mark.database)


# Custom pytest markers
pytestmark = [
    pytest.mark.asyncio,
]