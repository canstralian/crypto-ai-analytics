"""
Unit tests for backend project structure and configuration.
"""
import pytest
from pathlib import Path


class TestProjectStructure:
    """Test the backend project structure."""
    
    def test_backend_directory_exists(self):
        """Test that backend directory exists."""
        backend_dir = Path(__file__).parent.parent
        assert backend_dir.exists()
        assert backend_dir.is_dir()
    
    def test_essential_files_exist(self):
        """Test that essential files exist."""
        backend_dir = Path(__file__).parent.parent
        
        essential_files = [
            "pyproject.toml",
            "tests/conftest.py"
        ]
        
        for file_name in essential_files:
            file_path = backend_dir / file_name
            assert file_path.exists(), f"File {file_name} should exist"
            assert file_path.is_file(), f"{file_name} should be a file"
    
    def test_app_directory_structure(self):
        """Test that app directory structure is correct."""
        backend_dir = Path(__file__).parent.parent
        app_dir = backend_dir / "app"
        
        # Check if app directory exists
        assert app_dir.exists(), "app directory should exist"
        assert app_dir.is_dir(), "app should be a directory"


class TestPyprojectToml:
    """Test pyproject.toml configuration."""
    
    def test_pyproject_toml_structure(self):
        """Test that pyproject.toml has correct structure."""
        backend_dir = Path(__file__).parent.parent
        pyproject_path = backend_dir / "pyproject.toml"
        
        import tomli
        with open(pyproject_path, "rb") as f:
            pyproject_data = tomli.load(f)
        
        # Check essential sections
        assert "tool" in pyproject_data
        assert "poetry" in pyproject_data["tool"]
        assert "dependencies" in pyproject_data["tool"]["poetry"]
        assert "group" in pyproject_data["tool"]["poetry"]
        assert "dev" in pyproject_data["tool"]["poetry"]["group"]
    
    def test_essential_dependencies(self):
        """Test that essential dependencies are included."""
        backend_dir = Path(__file__).parent.parent
        pyproject_path = backend_dir / "pyproject.toml"
        
        import tomli
        with open(pyproject_path, "rb") as f:
            pyproject_data = tomli.load(f)
        
        dependencies = pyproject_data["tool"]["poetry"]["dependencies"]
        dev_dependencies = pyproject_data["tool"]["poetry"]["group"]["dev"]["dependencies"]
        
        # Check essential runtime dependencies
        essential_deps = [
            "fastapi",
            "uvicorn",
            "sqlalchemy",
            "alembic",
            "pydantic",
            "redis",
            "celery"
        ]
        
        for dep in essential_deps:
            assert dep in dependencies, f"Dependency {dep} should be in dependencies"
        
        # Check essential dev dependencies
        essential_dev_deps = [
            "pytest",
            "pytest-asyncio",
            "pytest-cov",
            "black",
            "isort",
            "flake8",
            "mypy"
        ]
        
        for dep in essential_dev_deps:
            assert dep in dev_dependencies, f"Dev dependency {dep} should be in dev dependencies"


class TestTestConfiguration:
    """Test test configuration."""
    
    def test_conftest_imports(self):
        """Test that conftest.py imports work correctly."""
        # This test ensures conftest.py can be imported without errors
        from tests.conftest import TestSettings, test_settings
        
        settings = TestSettings()
        assert settings.ENVIRONMENT == "test"
        assert settings.TESTING is True
    
    def test_pytest_markers_defined(self):
        """Test that pytest markers are properly defined."""
        # Check if pytest configuration includes custom markers
        backend_dir = Path(__file__).parent.parent
        pyproject_path = backend_dir / "pyproject.toml"
        
        # The markers should be defined in conftest.py
        from tests.conftest import pytest_collection_modifyitems
        assert pytest_collection_modifyitems is not None


class TestEnvironmentConfiguration:
    """Test environment configuration."""
    
    def test_test_environment_setup(self):
        """Test that test environment is properly configured."""
        import os
        
        # These should be set by pytest_configure in conftest.py
        assert os.getenv("ENVIRONMENT") == "test"
        assert os.getenv("TESTING") == "true"
        assert os.getenv("JWT_SECRET") == "test_secret_key"
    
    def test_database_url_configuration(self):
        """Test database URL configuration."""
        from tests.conftest import TEST_DATABASE_URL, TEST_DATABASE_URL_ASYNC
        
        assert "crypto_ai_test" in TEST_DATABASE_URL
        assert TEST_DATABASE_URL.startswith("postgresql://")
        assert TEST_DATABASE_URL_ASYNC.startswith("postgresql+asyncpg://")


@pytest.mark.unit
class TestFixtures:
    """Test that fixtures work correctly."""
    
    def test_sample_user_data_fixture(self, sample_user_data):
        """Test sample user data fixture."""
        assert "email" in sample_user_data
        assert "username" in sample_user_data
        assert "password" in sample_user_data
        assert sample_user_data["email"] == "test@example.com"
    
    def test_sample_crypto_data_fixture(self, sample_crypto_data):
        """Test sample crypto data fixture."""
        assert "symbol" in sample_crypto_data
        assert "name" in sample_crypto_data
        assert sample_crypto_data["symbol"] == "BTC"
        assert sample_crypto_data["name"] == "Bitcoin"
    
    def test_sample_market_data_fixture(self, sample_market_data):
        """Test sample market data fixture."""
        assert "time" in sample_market_data
        assert "symbol" in sample_market_data
        assert "exchange" in sample_market_data
        assert "open" in sample_market_data
        assert "close" in sample_market_data
    
    def test_authenticated_headers_fixture(self, authenticated_headers):
        """Test authenticated headers fixture."""
        assert "Authorization" in authenticated_headers
        assert authenticated_headers["Authorization"].startswith("Bearer ")
    
    def test_test_settings_fixture(self, test_settings):
        """Test settings fixture."""
        assert test_settings.ENVIRONMENT == "test"
        assert test_settings.TESTING is True
        assert test_settings.DEBUG is True


@pytest.mark.unit
class TestMockFixtures:
    """Test mock fixtures."""
    
    def test_mock_redis_fixture(self, mock_redis):
        """Test mock Redis fixture."""
        assert hasattr(mock_redis, "get")
        assert hasattr(mock_redis, "set")
        assert hasattr(mock_redis, "delete")
        assert hasattr(mock_redis, "exists")
    
    def test_mock_kafka_producer_fixture(self, mock_kafka_producer):
        """Test mock Kafka producer fixture."""
        assert hasattr(mock_kafka_producer, "send")
        assert hasattr(mock_kafka_producer, "flush")
    
    def test_mock_ml_model_fixture(self, mock_ml_model):
        """Test mock ML model fixture."""
        assert hasattr(mock_ml_model, "predict")
        assert hasattr(mock_ml_model, "predict_proba")
        assert hasattr(mock_ml_model, "score")
        
        # Test mock returns
        predictions = mock_ml_model.predict([1, 2, 3])
        assert predictions == [0.5]
        
        probabilities = mock_ml_model.predict_proba([1, 2, 3])
        assert probabilities == [[0.3, 0.7]]
        
        score = mock_ml_model.score([1, 2, 3], [1, 0, 1])
        assert score == 0.85


if __name__ == "__main__":
    pytest.main([__file__])