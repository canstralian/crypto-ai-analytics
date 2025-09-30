"""
Unit tests for project structure and basic functionality.
"""
import pytest
from pathlib import Path


class TestProjectStructure:
    """Test the basic project structure."""
    
    def test_project_root_exists(self):
        """Test that project root directory exists."""
        project_root = Path(__file__).parent.parent
        assert project_root.exists()
        assert project_root.is_dir()
    
    def test_essential_directories_exist(self):
        """Test that essential directories exist."""
        project_root = Path(__file__).parent.parent
        
        essential_dirs = [
            "backend",
            "frontend", 
            "docker",
            "k8s",
            "db",
            "infra",
            "tests",
            "docs"
        ]
        
        for dir_name in essential_dirs:
            dir_path = project_root / dir_name
            assert dir_path.exists(), f"Directory {dir_name} should exist"
            assert dir_path.is_dir(), f"{dir_name} should be a directory"
    
    def test_configuration_files_exist(self):
        """Test that essential configuration files exist."""
        project_root = Path(__file__).parent.parent
        
        config_files = [
            "README.md",
            ".gitignore",
            "Makefile",
            "pytest.ini",
            ".env.example",
            "docker-compose.dev.yml",
            "docker-compose.test.yml"
        ]
        
        for file_name in config_files:
            file_path = project_root / file_name
            assert file_path.exists(), f"File {file_name} should exist"
            assert file_path.is_file(), f"{file_name} should be a file"
    
    def test_docker_files_exist(self):
        """Test that Docker configuration files exist."""
        project_root = Path(__file__).parent.parent
        
        docker_files = [
            "docker/backend/Dockerfile",
            "docker/frontend/Dockerfile",
            "docker/frontend/nginx.conf"
        ]
        
        for file_path in docker_files:
            full_path = project_root / file_path
            assert full_path.exists(), f"Docker file {file_path} should exist"
    
    def test_kubernetes_files_exist(self):
        """Test that Kubernetes configuration files exist."""
        project_root = Path(__file__).parent.parent
        
        k8s_files = [
            "k8s/base/application.yml",
            "k8s/base/secrets.yml",
            "k8s/base/kustomization.yml",
            "k8s/overlays/development/kustomization.yml",
            "k8s/overlays/production/kustomization.yml"
        ]
        
        for file_path in k8s_files:
            full_path = project_root / file_path
            assert full_path.exists(), f"Kubernetes file {file_path} should exist"
    
    def test_database_files_exist(self):
        """Test that database configuration files exist."""
        project_root = Path(__file__).parent.parent
        
        db_files = [
            "db/schema.sql",
            "db/init/01-init.sh",
            "db/migrations/000_migration_framework.sql",
            "db/migrations/001_initial_schema.sql"
        ]
        
        for file_path in db_files:
            full_path = project_root / file_path
            assert full_path.exists(), f"Database file {file_path} should exist"
    
    def test_terraform_files_exist(self):
        """Test that Terraform configuration files exist."""
        project_root = Path(__file__).parent.parent
        
        terraform_files = [
            "infra/terraform/main.tf",
            "infra/terraform/variables.tf",
            "infra/terraform/outputs.tf",
            "infra/terraform/vpc.tf",
            "infra/terraform/eks.tf",
            "infra/terraform/s3.tf",
            "infra/terraform/secrets.tf"
        ]
        
        for file_path in terraform_files:
            full_path = project_root / file_path
            assert full_path.exists(), f"Terraform file {file_path} should exist"


class TestGitIgnore:
    """Test .gitignore configuration."""
    
    def test_gitignore_contains_essentials(self):
        """Test that .gitignore contains essential patterns."""
        project_root = Path(__file__).parent.parent
        gitignore_path = project_root / ".gitignore"
        
        gitignore_content = gitignore_path.read_text()
        
        essential_patterns = [
            "__pycache__",
            "*.pyc",
            "node_modules",
            ".env",
            "*.log",
            ".terraform",
            "*.tfstate",
            "coverage",
            ".pytest_cache"
        ]
        
        for pattern in essential_patterns:
            assert pattern in gitignore_content, f"Pattern {pattern} should be in .gitignore"


class TestEnvironmentConfiguration:
    """Test environment configuration."""
    
    def test_env_example_exists_and_has_content(self):
        """Test that .env.example exists and has required variables."""
        project_root = Path(__file__).parent.parent
        env_example_path = project_root / ".env.example"
        
        env_content = env_example_path.read_text()
        
        required_vars = [
            "ENVIRONMENT",
            "DATABASE_URL",
            "REDIS_URL",
            "JWT_SECRET",
            "API_V1_STR"
        ]
        
        for var in required_vars:
            assert var in env_content, f"Environment variable {var} should be in .env.example"


class TestDockerConfiguration:
    """Test Docker configuration."""
    
    def test_docker_compose_dev_structure(self):
        """Test docker-compose.dev.yml structure."""
        project_root = Path(__file__).parent.parent
        compose_path = project_root / "docker-compose.dev.yml"
        
        import yaml
        with open(compose_path) as f:
            compose_config = yaml.safe_load(f)
        
        assert "services" in compose_config
        
        expected_services = [
            "postgres",
            "redis", 
            "kafka",
            "zookeeper",
            "backend",
            "frontend",
            "celery-worker",
            "celery-beat"
        ]
        
        for service in expected_services:
            assert service in compose_config["services"], f"Service {service} should be in docker-compose.dev.yml"
    
    def test_docker_compose_test_structure(self):
        """Test docker-compose.test.yml structure."""
        project_root = Path(__file__).parent.parent
        compose_path = project_root / "docker-compose.test.yml"
        
        import yaml
        with open(compose_path) as f:
            compose_config = yaml.safe_load(f)
        
        assert "services" in compose_config
        
        # Test environment should have basic services
        essential_test_services = ["postgres", "redis"]
        
        for service in essential_test_services:
            assert service in compose_config["services"], f"Service {service} should be in docker-compose.test.yml"


class TestMakefile:
    """Test Makefile configuration."""
    
    def test_makefile_has_essential_targets(self):
        """Test that Makefile has essential targets."""
        project_root = Path(__file__).parent.parent
        makefile_path = project_root / "Makefile"
        
        makefile_content = makefile_path.read_text()
        
        essential_targets = [
            "help",
            "dev-setup",
            "dev-start",
            "test",
            "lint",
            "build",
            "clean"
        ]
        
        for target in essential_targets:
            assert f"{target}:" in makefile_content, f"Target {target} should be in Makefile"


@pytest.mark.unit
class TestPytestConfiguration:
    """Test pytest configuration."""
    
    def test_pytest_ini_exists(self):
        """Test that pytest.ini exists and is configured."""
        project_root = Path(__file__).parent.parent
        pytest_ini_path = project_root / "pytest.ini"
        
        pytest_content = pytest_ini_path.read_text()
        
        # Check for essential pytest configuration
        assert "testpaths" in pytest_content
        assert "markers" in pytest_content
        assert "addopts" in pytest_content
    
    def test_conftest_exists(self):
        """Test that conftest.py exists."""
        conftest_path = Path(__file__).parent / "conftest.py"
        assert conftest_path.exists()
        assert conftest_path.is_file()


if __name__ == "__main__":
    pytest.main([__file__])