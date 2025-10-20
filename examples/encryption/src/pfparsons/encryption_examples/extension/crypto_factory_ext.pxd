from pyarrow.includes.common cimport *
from pyarrow.includes.libparquet_encryption cimport *
from pyarrow._parquet_encryption cimport KmsClient, CryptoFactory, KmsConnectionConfig, EncryptionConfiguration
from pyarrow.includes.libarrow_fs cimport *
from pyarrow._parquet cimport (CFileEncryptionProperties,
                               CFileDecryptionProperties,
                               CFileEncryptionProperties,
                               FileEncryptionProperties)

from .pyarrow_vendored cimport *

cdef extern from "parquet/encryption/crypto_factory.h" \
        namespace "parquet::encryption" nogil:

    cdef cppclass CCryptoFactoryExt" parquet::encryption::CryptoFactory":
        void RegisterKmsClientFactory(
            shared_ptr[CKmsClientFactory] kms_client_factory) except +
        shared_ptr[CFileEncryptionProperties] GetFileEncryptionProperties(
            const CKmsConnectionConfig& kms_connection_config,
            const CEncryptionConfiguration& encryption_config) except +*
        shared_ptr[CFileEncryptionProperties] GetFileEncryptionProperties(
            const CKmsConnectionConfig& kms_connection_config,
            const CEncryptionConfiguration& encryption_config,
            const c_string& file_path,
            const shared_ptr[CFileSystem]& file_system) except +*
        shared_ptr[CFileDecryptionProperties] GetFileDecryptionProperties(
            const CKmsConnectionConfig& kms_connection_config,
            const CDecryptionConfiguration& decryption_config) except +*
        void RemoveCacheEntriesForToken(const c_string& access_token) except +
        void RemoveCacheEntriesForAllTokens() except +


cdef extern from "crypto_factory_ext.cc" namespace "pfparsons::examples::encryption" nogil:
    pass


cdef extern from "crypto_factory_ext.h" namespace "pfparsons::examples::encryption" nogil:

    cdef cppclass CPyCryptoFactoryExt\
        " pfparsons::examples::encryption::PyCryptoFactoryExt"(CCryptoFactoryExt):
        CResult[shared_ptr[CFileEncryptionProperties]] \
            SafeGetFileEncryptionProperties(
            const CKmsConnectionConfig& kms_connection_config,
            const CEncryptionConfiguration& encryption_config)
        CResult[shared_ptr[CFileEncryptionProperties]] \
            SafeGetFileEncryptionProperties(
            const CKmsConnectionConfig& kms_connection_config,
            const CEncryptionConfiguration& encryption_config,
            const c_string& file_path,
            const shared_ptr[CFileSystem]& file_system)
        CResult[shared_ptr[CFileDecryptionProperties]] \
            SafeGetFileDecryptionProperties(
            const CKmsConnectionConfig& kms_connection_config,
            const CDecryptionConfiguration& decryption_config)


cdef class CryptoFactoryExt(CryptoFactory):
    cdef shared_ptr[CPyCryptoFactoryExt] factory
