import unittest
import time
import hvac
import statistics
from concurrent.futures import ThreadPoolExecutor

class TestVaultPerformance(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up test environment"""
        cls.vault_client = hvac.Client(url='http://localhost:8200', token='root')
        cls.vault_client.sys.enable_secrets_engine('kv', path='secret')

    def test_secret_write_performance(self):
        """Test Vault secret write performance"""
        iterations = 100
        times = []
        
        for i in range(iterations):
            start_time = time.time()
            self.vault_client.secrets.kv.v2.create_or_update_secret(
                path=f'test_{i}',
                secret=dict(key=f'value_{i}')
            )
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = statistics.mean(times)
        max_time = max(times)
        min_time = min(times)
        
        print(f"\nSecret Write Performance Results:")
        print(f"Average time: {avg_time:.6f} seconds")
        print(f"Max time: {max_time:.6f} seconds")
        print(f"Min time: {min_time:.6f} seconds")
        
        self.assertLess(avg_time, 0.1)  # Average should be less than 100ms

    def test_secret_read_performance(self):
        """Test Vault secret read performance"""
        iterations = 100
        times = []
        
        # First write some secrets
        for i in range(iterations):
            self.vault_client.secrets.kv.v2.create_or_update_secret(
                path=f'test_{i}',
                secret=dict(key=f'value_{i}')
            )
        
        # Then test read performance
        for i in range(iterations):
            start_time = time.time()
            self.vault_client.secrets.kv.v2.read_secret_version(path=f'test_{i}')
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = statistics.mean(times)
        max_time = max(times)
        min_time = min(times)
        
        print(f"\nSecret Read Performance Results:")
        print(f"Average time: {avg_time:.6f} seconds")
        print(f"Max time: {max_time:.6f} seconds")
        print(f"Min time: {min_time:.6f} seconds")
        
        self.assertLess(avg_time, 0.1)  # Average should be less than 100ms

    def test_concurrent_operations(self):
        """Test Vault performance under concurrent load"""
        iterations = 50
        concurrent_users = 5
        
        def worker(user_id):
            times = []
            for i in range(iterations):
                start_time = time.time()
                # Write secret
                self.vault_client.secrets.kv.v2.create_or_update_secret(
                    path=f'user_{user_id}_test_{i}',
                    secret=dict(key=f'value_{i}')
                )
                # Read secret
                self.vault_client.secrets.kv.v2.read_secret_version(
                    path=f'user_{user_id}_test_{i}'
                )
                end_time = time.time()
                times.append(end_time - start_time)
            return times
        
        all_times = []
        with ThreadPoolExecutor(max_workers=concurrent_users) as executor:
            results = list(executor.map(worker, range(concurrent_users)))
            for result in results:
                all_times.extend(result)
        
        avg_time = statistics.mean(all_times)
        max_time = max(all_times)
        min_time = min(all_times)
        
        print(f"\nConcurrent Operations Performance Results:")
        print(f"Average time: {avg_time:.6f} seconds")
        print(f"Max time: {max_time:.6f} seconds")
        print(f"Min time: {min_time:.6f} seconds")
        
        self.assertLess(avg_time, 0.2)  # Average should be less than 200ms under load

    def test_token_creation_performance(self):
        """Test Vault token creation performance"""
        iterations = 50
        times = []
        
        for i in range(iterations):
            start_time = time.time()
            self.vault_client.auth.token.create(
                policies=['default'],
                ttl='1h'
            )
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = statistics.mean(times)
        max_time = max(times)
        min_time = min(times)
        
        print(f"\nToken Creation Performance Results:")
        print(f"Average time: {avg_time:.6f} seconds")
        print(f"Max time: {max_time:.6f} seconds")
        print(f"Min time: {min_time:.6f} seconds")
        
        self.assertLess(avg_time, 0.1)  # Average should be less than 100ms

    def test_health_check_performance(self):
        """Test Vault health check performance"""
        iterations = 100
        times = []
        
        for i in range(iterations):
            start_time = time.time()
            self.vault_client.sys.read_health_status()
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = statistics.mean(times)
        max_time = max(times)
        min_time = min(times)
        
        print(f"\nHealth Check Performance Results:")
        print(f"Average time: {avg_time:.6f} seconds")
        print(f"Max time: {max_time:.6f} seconds")
        print(f"Min time: {min_time:.6f} seconds")
        
        self.assertLess(avg_time, 0.05)  # Average should be less than 50ms

    @classmethod
    def tearDownClass(cls):
        """Clean up test environment"""
        # Clean up test secrets
        for i in range(100):
            try:
                cls.vault_client.secrets.kv.v2.delete_metadata_and_all_versions(
                    path=f'test_{i}'
                )
            except:
                pass

if __name__ == '__main__':
    unittest.main() 