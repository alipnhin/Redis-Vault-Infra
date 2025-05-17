import unittest
import yaml
import os

class TestVaultConfig(unittest.TestCase):
    def setUp(self):
        self.config_path = 'examples/kubernetes-setup/vault/vault-config.yaml'
        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)

    def test_vault_version(self):
        """Test Vault version configuration"""
        image = self.config['spec']['template']['spec']['containers'][0]['image']
        self.assertIn('vault:1.15.2', image)

    def test_vault_ports(self):
        """Test Vault port configuration"""
        ports = self.config['spec']['template']['spec']['containers'][0]['ports']
        port_numbers = [p['containerPort'] for p in ports]
        self.assertIn(8200, port_numbers)
        self.assertIn(8201, port_numbers)

    def test_vault_volumes(self):
        """Test Vault volume configuration"""
        volumes = self.config['spec']['template']['spec']['volumes']
        self.assertTrue(any(v['name'] == 'vault-data' for v in volumes))
        self.assertTrue(any(v['name'] == 'vault-config' for v in volumes))

    def test_vault_security_context(self):
        """Test Vault security context"""
        security_context = self.config['spec']['template']['spec']['securityContext']
        self.assertTrue(security_context.get('runAsNonRoot', False))
        self.assertEqual(security_context.get('runAsUser'), 1000)

    def test_vault_environment(self):
        """Test Vault environment variables"""
        env = self.config['spec']['template']['spec']['containers'][0]['env']
        env_dict = {e['name']: e['value'] for e in env}
        # In CI environment, we use http
        self.assertIn(env_dict.get('VAULT_ADDR'), ['https://127.0.0.1:8200', 'http://127.0.0.1:8200'])

if __name__ == '__main__':
    unittest.main() 