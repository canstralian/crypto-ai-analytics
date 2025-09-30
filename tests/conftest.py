"""
Test configuration and fixtures.
"""
import os
import pytest
import asyncio
from typing import AsyncGenerator, Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient
from httpx import AsyncClient

# Import app modules (will be created later)
# from app.main import app
# from app.database import get_db
# from app.models.base import Base

# Test database URL
TEST_DATABASE_URL = os.getenv("TEST_DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/crypto_ai_test")

# Test engine and session
test_engine = create_engine(TEST_DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
def db_engine():
    """Create test database engine."""
    return test_engine


@pytest.fixture
def db_session(db_engine):
    """Create a fresh database session for each test."""
    connection = db_engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture
def client(db_session):
    """Create a test client with dependency overrides."""
    # This will be implemented when we have the FastAPI app
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


@pytest.fixture
async def async_client(db_session):
    """Create an async test client."""
    # This will be implemented when we have the FastAPI app
    # def override_get_db():
    #     yield db_session
    # 
    # app.dependency_overrides[get_db] = override_get_db
    # 
    # async with AsyncClient(app=app, base_url="http://test") as async_client:
    #     yield async_client
    # 
    # app.dependency_overrides.clear()
    pass


@pytest.fixture
def sample_user_data():
    """Sample user data for testing."""
    return {
        "email": "test@example.com",
        "username": "testuser",
        "password": "testpassword123",
        "first_name": "Test",
        "last_name": "User"
    }


@pytest.fixture
def sample_crypto_data():
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
def sample_market_data():
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
def authenticated_headers():
    """Create headers for authenticated requests."""
    # This will be implemented when we have JWT functionality
    return {
        "Authorization": "Bearer test_token"
    }


@pytest.fixture(autouse=True)
def setup_test_database(db_session):
    """Set up test database with required tables."""
    # This will create tables for each test
    # Base.metadata.create_all(bind=db_session.bind)
    # yield
    # Base.metadata.drop_all(bind=db_session.bind)
    pass


@pytest.fixture
def mock_external_api():
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
    
    return responses


@pytest.fixture
def redis_mock():
    """Mock Redis client for testing."""
    import fakeredis
    return fakeredis.FakeRedis()


class TestSettings:
    """Test configuration settings."""
    DATABASE_URL = TEST_DATABASE_URL
    REDIS_URL = "redis://localhost:6379/1"
    JWT_SECRET = "test_secret_key"
    ENVIRONMENT = "test"
    DEBUG = True
    TESTING = True


@pytest.fixture
def test_settings():
    """Test configuration settings."""
    return TestSettings()


# Custom pytest markers
pytestmark = [
    pytest.mark.asyncio,
]


def pytest_configure(config):
    """Configure pytest with custom settings."""
    # Set environment variables for testing
    os.environ["ENVIRONMENT"] = "test"
    os.environ["DATABASE_URL"] = TEST_DATABASE_URL
    os.environ["TESTING"] = "true"


def pytest_collection_modifyitems(config, items):
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
        if any(keyword in item.name.lower() for keyword in ["slow", "integration", "external"]):
            item.add_marker(pytest.mark.slow)