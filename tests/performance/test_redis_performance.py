import unittest
import time
import redis
import statistics
from concurrent.futures import ThreadPoolExecutor

class TestRedisPerformance(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up test environment"""
        cls.redis_client = redis.Redis(
            host='localhost',
            port=6379,
            password='YourStrongPassword',
            decode_responses=True
        )
        cls.redis_client.flushall()

    def test_set_performance(self):
        """Test Redis SET operation performance"""
        iterations = 1000
        times = []
        
        for i in range(iterations):
            start_time = time.time()
            self.redis_client.set(f'key_{i}', f'value_{i}')
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = statistics.mean(times)
        max_time = max(times)
        min_time = min(times)
        
        print(f"\nSET Performance Results:")
        print(f"Average time: {avg_time:.6f} seconds")
        print(f"Max time: {max_time:.6f} seconds")
        print(f"Min time: {min_time:.6f} seconds")
        
        self.assertLess(avg_time, 0.001)  # Average should be less than 1ms

    def test_get_performance(self):
        """Test Redis GET operation performance"""
        iterations = 1000
        times = []
        
        # First set some values
        for i in range(iterations):
            self.redis_client.set(f'key_{i}', f'value_{i}')
        
        # Then test GET performance
        for i in range(iterations):
            start_time = time.time()
            self.redis_client.get(f'key_{i}')
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = statistics.mean(times)
        max_time = max(times)
        min_time = min(times)
        
        print(f"\nGET Performance Results:")
        print(f"Average time: {avg_time:.6f} seconds")
        print(f"Max time: {max_time:.6f} seconds")
        print(f"Min time: {min_time:.6f} seconds")
        
        self.assertLess(avg_time, 0.001)  # Average should be less than 1ms

    def test_concurrent_operations(self):
        """Test Redis performance under concurrent load"""
        iterations = 1000
        concurrent_users = 10
        
        def worker(user_id):
            times = []
            for i in range(iterations):
                start_time = time.time()
                self.redis_client.set(f'user_{user_id}_key_{i}', f'value_{i}')
                self.redis_client.get(f'user_{user_id}_key_{i}')
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
        
        self.assertLess(avg_time, 0.002)  # Average should be less than 2ms under load

    def test_memory_usage(self):
        """Test Redis memory usage under load"""
        initial_memory = self.redis_client.info()['used_memory']
        
        # Insert large amount of data
        for i in range(10000):
            self.redis_client.set(f'large_key_{i}', 'x' * 1000)
        
        final_memory = self.redis_client.info()['used_memory']
        memory_increase = final_memory - initial_memory
        
        print(f"\nMemory Usage Results:")
        print(f"Initial memory: {initial_memory / 1024 / 1024:.2f} MB")
        print(f"Final memory: {final_memory / 1024 / 1024:.2f} MB")
        print(f"Memory increase: {memory_increase / 1024 / 1024:.2f} MB")
        
        self.assertLess(memory_increase / 1024 / 1024, 100)  # Should use less than 100MB

    @classmethod
    def tearDownClass(cls):
        """Clean up test environment"""
        cls.redis_client.flushall()
        cls.redis_client.close()

if __name__ == '__main__':
    unittest.main() 