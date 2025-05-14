import unittest
import time
import requests
import redis
import hvac
import os

class TestRedisVaultIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up test environment"""
        cls.redis_password = os.getenv('REDIS_PASSWORD', 'YourStrongPassword')
        cls.vault_token = os.getenv('VAULT_DEV_ROOT_TOKEN_ID', 'root')
        
        # Wait for services to start
        time.sleep(5)
        
        # Initialize Vault client
        vault_addr = os.getenv('VAULT_ADDR', 'http://127.0.0.1:8200')
        cls.vault_client = hvac.Client(url=vault_addr, token=cls.vault_token)
        
        # Initialize Redis client
        cls.redis_client = redis.Redis(
            host='127.0.0.1',
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
        
        # Test secrets engine with a unique path
        unique_path = 'integration_test_secret'
        self.vault_client.sys.enable_secrets_engine('kv', path=unique_path)
        self.vault_client.secrets.kv.v2.create_or_update_secret(
            path=f'{unique_path}/test',
            secret=dict(test_key='test_value')
        )
        secret = self.vault_client.secrets.kv.v2.read_secret_version(path=f'{unique_path}/test')
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
            host='127.0.0.1',
            port=6379,
            password=retrieved_password,
            decode_responses=True
        )
        self.assertTrue(test_client.ping())

if __name__ == '__main__':
    unittest.main()