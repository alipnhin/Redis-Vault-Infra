import unittest
import yaml
import os

class TestRedisConfig(unittest.TestCase):
    def setUp(self):
        self.config_path = 'examples/kubernetes-setup/redis/redis-master.yaml'
        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)

    def test_redis_version(self):
        """Test Redis version configuration"""
        image = self.config['spec']['template']['spec']['containers'][0]['image']
        self.assertIn('redis:7.2.4', image)

    def test_redis_ports(self):
        """Test Redis port configuration"""
        ports = self.config['spec']['template']['spec']['containers'][0]['ports']
        self.assertEqual(ports[0]['containerPort'], 6379)

    def test_redis_volumes(self):
        """Test Redis volume configuration"""
        volumes = self.config['spec']['template']['spec']['volumes']
        self.assertTrue(any(v['name'] == 'redis-data' for v in volumes))

    def test_redis_security_context(self):
        """Test Redis security context"""
        security_context = self.config['spec']['template']['spec']['securityContext']
        self.assertFalse(security_context.get('runAsRoot', True))

if __name__ == '__main__':
    unittest.main() 