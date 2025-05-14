import unittest
import docker
import time
import requests
import redis
import hvac

class TestRedisVaultIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up test environment"""
        cls.client = docker.from_env()
        cls.redis_password = "YourStrongPassword"
        cls.vault_token = None
        
        # Start Redis
        cls.redis_container = cls.client.containers.run(
            "redis:7.2.4",
            detach=True,
            environment={"REDIS_PASSWORD": cls.redis_password},
            ports={'6379/tcp': 6379}
        )
        
        # Start Vault
        cls.vault_container = cls.client.containers.run(
            "vault:1.15.2",
            detach=True,
            cap_add=['IPC_LOCK'],
            ports={'8200/tcp': 8200},
            environment={'VAULT_DEV_ROOT_TOKEN_ID': 'root'}
        )
        
        # Wait for services to start
        time.sleep(5)
        
        # Initialize Vault client
        cls.vault_client = hvac.Client(url='http://localhost:8200', token='root')
        
        # Initialize Redis client
        cls.redis_client = redis.Redis(
            host='localhost',
            port=6379,
            password=cls.redis_password,
            decode_responses=True
        )

    def test_redis_connection(self):
        """Test Redis connection and basic operations"""
        # Test connection
        self.assertTrue(self.redis_client.ping())
        
        # Test set/get
        self.redis_client.set('test_key', 'test_value')
        self.assertEqual(self.redis_client.get('test_key'), 'test_value')

    def test_vault_connection(self):
        """Test Vault connection and basic operations"""
        # Test connection
        self.assertTrue(self.vault_client.is_authenticated())
        
        # Test secrets engine
        self.vault_client.sys.enable_secrets_engine('kv', path='secret')
        self.vault_client.secrets.kv.v2.create_or_update_secret(
            path='test',
            secret=dict(test_key='test_value')
        )
        secret = self.vault_client.secrets.kv.v2.read_secret_version(path='test')
        self.assertEqual(secret['data']['data']['test_key'], 'test_value')

    def test_redis_vault_integration(self):
        """Test integration between Redis and Vault"""
        # Store Redis password in Vault
        self.vault_client.secrets.kv.v2.create_or_update_secret(
            path='redis',
            secret=dict(password=self.redis_password)
        )
        
        # Retrieve password from Vault
        secret = self.vault_client.secrets.kv.v2.read_secret_version(path='redis')
        retrieved_password = secret['data']['data']['password']
        
        # Test Redis connection with retrieved password
        test_client = redis.Redis(
            host='localhost',
            port=6379,
            password=retrieved_password,
            decode_responses=True
        )
        self.assertTrue(test_client.ping())

    @classmethod
    def tearDownClass(cls):
        """Clean up test environment"""
        cls.redis_container.stop()
        cls.redis_container.remove()
        cls.vault_container.stop()
        cls.vault_container.remove()

if __name__ == '__main__':
    unittest.main() 