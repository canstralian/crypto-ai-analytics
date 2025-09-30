"""
Integration tests for the application.
"""
import pytest
import asyncio
from pathlib import Path


@pytest.mark.integration
class TestDatabaseConnectivity:
    """Test database connectivity and basic operations."""
    
    @pytest.mark.database
    async def test_database_connection(self):
        """Test that we can connect to the test database."""
        # This test will be implemented when we have database models
        # For now, just verify that the database URL is set
        import os
        test_db_url = os.getenv("TEST_DATABASE_URL")
        assert test_db_url is not None
        assert "crypto_ai_test" in test_db_url
    
    @pytest.mark.database
    def test_database_schema_files(self):
        """Test that database schema files are valid."""
        project_root = Path(__file__).parent.parent.parent
        schema_file = project_root / "db" / "schema.sql"
        
        schema_content = schema_file.read_text()
        
        # Check for essential tables
        essential_tables = [
            "users",
            "portfolios", 
            "market_data",
            "cryptocurrencies",
            "transactions"
        ]
        
        for table in essential_tables:
            assert f"CREATE TABLE {table}" in schema_content, f"Table {table} should be defined in schema.sql"
        
        # Check for TimescaleDB hypertables
        assert "create_hypertable" in schema_content
        assert "timescaledb" in schema_content


@pytest.mark.integration
class TestRedisConnectivity:
    """Test Redis connectivity."""
    
    async def test_redis_connection_config(self):
        """Test Redis connection configuration."""
        import os
        redis_url = os.getenv("REDIS_URL", "redis://localhost:6379")
        assert redis_url is not None
        assert redis_url.startswith("redis://")


@pytest.mark.integration 
class TestDockerIntegration:
    """Test Docker integration."""
    
    def test_docker_compose_validation(self):
        """Test that Docker Compose files are valid YAML."""
        project_root = Path(__file__).parent.parent.parent
        
        compose_files = [
            "docker-compose.dev.yml",
            "docker-compose.test.yml"
        ]
        
        import yaml
        
        for compose_file in compose_files:
            file_path = project_root / compose_file
            
            try:
                with open(file_path) as f:
                    yaml.safe_load(f)
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML in {compose_file}: {e}")
    
    def test_dockerfile_exists(self):
        """Test that Dockerfiles exist and have valid content."""
        project_root = Path(__file__).parent.parent.parent
        
        dockerfiles = [
            "docker/backend/Dockerfile",
            "docker/frontend/Dockerfile"
        ]
        
        for dockerfile in dockerfiles:
            file_path = project_root / dockerfile
            assert file_path.exists(), f"Dockerfile {dockerfile} should exist"
            
            content = file_path.read_text()
            assert content.startswith("FROM"), f"Dockerfile {dockerfile} should start with FROM"


@pytest.mark.integration
class TestKubernetesIntegration:
    """Test Kubernetes integration."""
    
    def test_kubernetes_yaml_validation(self):
        """Test that Kubernetes YAML files are valid."""
        project_root = Path(__file__).parent.parent.parent
        
        k8s_files = [
            "k8s/base/application.yml",
            "k8s/base/secrets.yml",
            "k8s/base/kustomization.yml"
        ]
        
        import yaml
        
        for k8s_file in k8s_files:
            file_path = project_root / k8s_file
            
            try:
                with open(file_path) as f:
                    yaml.safe_load(f)
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML in {k8s_file}: {e}")
    
    def test_kustomization_structure(self):
        """Test Kustomization structure."""
        project_root = Path(__file__).parent.parent.parent
        
        import yaml
        
        # Test base kustomization
        base_kustomization = project_root / "k8s/base/kustomization.yml"
        with open(base_kustomization) as f:
            base_config = yaml.safe_load(f)
        
        assert "resources" in base_config
        assert "namespace" in base_config
        
        # Test overlay kustomizations
        overlays = ["development", "production"]
        
        for overlay in overlays:
            overlay_kustomization = project_root / f"k8s/overlays/{overlay}/kustomization.yml"
            with open(overlay_kustomization) as f:
                overlay_config = yaml.safe_load(f)
            
            assert "resources" in overlay_config
            assert "../../base" in overlay_config["resources"]


@pytest.mark.integration
@pytest.mark.slow
class TestTerraformIntegration:
    """Test Terraform integration."""
    
    def test_terraform_files_syntax(self):
        """Test that Terraform files have valid syntax."""
        project_root = Path(__file__).parent.parent.parent
        
        terraform_files = [
            "infra/terraform/main.tf",
            "infra/terraform/variables.tf", 
            "infra/terraform/outputs.tf",
            "infra/terraform/vpc.tf",
            "infra/terraform/eks.tf",
            "infra/terraform/s3.tf",
            "infra/terraform/secrets.tf"
        ]
        
        for tf_file in terraform_files:
            file_path = project_root / tf_file
            content = file_path.read_text()
            
            # Basic syntax checks
            assert content.strip(), f"Terraform file {tf_file} should not be empty"
            
            # Check for balanced braces
            open_braces = content.count("{")
            close_braces = content.count("}")
            assert open_braces == close_braces, f"Unbalanced braces in {tf_file}"
    
    def test_terraform_variables_structure(self):
        """Test Terraform variables structure."""
        project_root = Path(__file__).parent.parent.parent
        variables_file = project_root / "infra/terraform/variables.tf"
        
        content = variables_file.read_text()
        
        # Check for essential variables
        essential_variables = [
            "aws_region",
            "environment",
            "project_name",
            "vpc_cidr"
        ]
        
        for var in essential_variables:
            assert f'variable "{var}"' in content, f"Variable {var} should be defined in variables.tf"


@pytest.mark.integration
class TestCIConfiguration:
    """Test CI/CD configuration."""
    
    def test_github_workflows_exist(self):
        """Test that GitHub workflow files exist."""
        project_root = Path(__file__).parent.parent.parent
        
        workflow_files = [
            ".github/workflows/ci-cd.yml",
            ".github/workflows/dependency-updates.yml"
        ]
        
        for workflow_file in workflow_files:
            file_path = project_root / workflow_file
            assert file_path.exists(), f"Workflow file {workflow_file} should exist"
    
    def test_github_workflows_yaml_valid(self):
        """Test that GitHub workflow YAML files are valid."""
        project_root = Path(__file__).parent.parent.parent
        
        workflow_files = [
            ".github/workflows/ci-cd.yml",
            ".github/workflows/dependency-updates.yml"
        ]
        
        import yaml
        
        for workflow_file in workflow_files:
            file_path = project_root / workflow_file
            
            try:
                with open(file_path) as f:
                    yaml.safe_load(f)
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML in {workflow_file}: {e}")
    
    def test_ci_workflow_structure(self):
        """Test CI workflow structure."""
        project_root = Path(__file__).parent.parent.parent
        ci_workflow = project_root / ".github/workflows/ci-cd.yml"
        
        import yaml
        with open(ci_workflow) as f:
            workflow_config = yaml.safe_load(f)
        
        assert "name" in workflow_config
        assert "on" in workflow_config
        assert "jobs" in workflow_config
        
        # Check for essential jobs
        jobs = workflow_config["jobs"]
        essential_jobs = ["security-scan", "backend-test", "frontend-test"]
        
        for job in essential_jobs:
            assert job in jobs, f"Job {job} should be in CI workflow"


if __name__ == "__main__":
    pytest.main([__file__])