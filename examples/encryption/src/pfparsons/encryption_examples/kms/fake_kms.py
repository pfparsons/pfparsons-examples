from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric.padding import OAEP, MGF1
from cryptography.hazmat.primitives.keywrap import aes_key_wrap, aes_key_unwrap
from dataclasses import dataclass
from importlib import resources
from pathlib import Path
import os
import pyarrow.parquet.encryption as pe
import base64
from typing import ClassVar

from pfparsons.encryption_examples.extension.crypto_factory_ext import KmsClient  # type: ignore


@dataclass
class RSAKeyPair:
    private_key: rsa.RSAPrivateKey
    public_key: rsa.RSAPublicKey

    @classmethod
    def generate(cls) -> 'RSAKeyPair':
        private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
        public_key = private_key.public_key()
        return cls(private_key=private_key, public_key=public_key)
    
    @classmethod
    def load(cls, key_id: str) -> 'RSAKeyPair':
        with resources.path('pfparsons.encryption_examples','kms/keystore') as base_dir:
            private_key_path = base_dir / f"{key_id}_private.pem"
            public_key_path = base_dir / f"{key_id}_public.pem"
            
            with open(private_key_path, "rb") as pk_file:
                private_key = serialization.load_pem_private_key(
                    pk_file.read(),
                    password=None,
                )
            
            with open(public_key_path, "rb") as pub_file:
                public_key = serialization.load_pem_public_key(pub_file.read())
        
        return cls(private_key=private_key, public_key=public_key)
    
    def save(self, key_id: str):
        with resources.path('pfparsons.encryption_examples','kms/keystore') as base_dir:
            private_key_path = base_dir / f"{key_id}_private.pem"
            public_key_path = base_dir / f"{key_id}_public.pem"

            if private_key_path.exists() or public_key_path.exists():
                raise FileExistsError(f"Key files for ID '{key_id}' already exist.")
            
            with open(private_key_path, "wb") as pk_file:
                pk_file.write(
                    self.private_key.private_bytes(
                        encoding=serialization.Encoding.PEM,
                        format=serialization.PrivateFormat.TraditionalOpenSSL,
                        encryption_algorithm=serialization.NoEncryption()
                    )
                )
            
            with open(public_key_path, "wb") as pub_file:
                pub_file.write(
                    self.public_key.public_bytes(
                        encoding=serialization.Encoding.PEM,
                        format=serialization.PublicFormat.SubjectPublicKeyInfo
                    )
                )
            
            return (private_key_path, public_key_path)


@dataclass
class KeyEncryptingKey:
    id: str
    key: bytes

    ROOT_KEY_ID: ClassVar[str] = "root_kek"

    @classmethod
    def generate(cls, id: str, bit_length: int = 256) -> 'KeyEncryptingKey':
        key = os.urandom(int(bit_length / 8))  # TODO: Add validation for bit_length
        return cls(id=id, key=key)

    @classmethod
    def load(cls, id: str) -> 'KeyEncryptingKey':
        with resources.path('pfparsons.encryption_examples','kms/keystore') as base_dir:
            key_path = base_dir / f"{id}_kek.key"
            if not key_path.exists():
                raise FileNotFoundError(f"KEK file for ID '{id}' does not exist.")
            
            with open(key_path, "rb") as key_file:
                wrapped = key_file.read()
                root_pair = RSAKeyPair.load(KeyEncryptingKey.ROOT_KEY_ID)
                key = root_pair.private_key.decrypt(
                    wrapped,
                    OAEP(
                        mgf=MGF1(algorithm=hashes.SHA256()),
                        algorithm=hashes.SHA256(),
                        label=None
                    )
                )
        
        return cls(id=id, key=key)


    def save(self) -> Path:
        with resources.path('pfparsons.encryption_examples','kms/keystore') as base_dir:
            full_path = base_dir / f"{self.id}_kek.key"
            if full_path.exists():
                raise FileExistsError(f"KEK file for ID '{self.id}' already exists.")
            
            with open(full_path, "wb") as key_file:
                
                root_pair = RSAKeyPair.load(KeyEncryptingKey.ROOT_KEY_ID)
                key_mat = root_pair.public_key.encrypt(
                    self.key,
                    OAEP(
                        mgf=MGF1(algorithm=hashes.SHA256()),
                        algorithm=hashes.SHA256(),
                        label=None
                    )
                )
                key_file.write(key_mat)
            
            return full_path


    def wrap(self, dek: bytes) -> bytes:
        wrapped = aes_key_wrap(self.key, dek)
        return wrapped


    def unwrap(self, wrapped_dek: bytes) -> bytes:
        dek = aes_key_unwrap(self.key, wrapped_dek)
        return dek


def generate_kms_keys():
    try:
        RSAKeyPair.generate().save(KeyEncryptingKey.ROOT_KEY_ID)
    except FileExistsError:
        pass

    try:
        KeyEncryptingKey.generate("example").save()
    except FileExistsError:
        pass


class FakeKMSClient(KmsClient):

    def __init__(self, kms_connection_configuration):
        pe.KmsClient.__init__(self)
        self.kek = KeyEncryptingKey.load("example")

    def wrap_key(self, key_bytes: bytes, master_key_identifier: str) -> bytes:
        wrapped = self.kek.wrap(key_bytes)
        encoded = base64.b64encode(wrapped)
        return encoded
    
    def unwrap_key(self, key_bytes: bytes, master_key_identifier: str) -> bytes:
        key = base64.b64decode(key_bytes)
        return self.kek.unwrap(key)
    
    @classmethod
    def factory(cls, kms_connection_configuration = None):
        return cls(kms_connection_configuration)
    
