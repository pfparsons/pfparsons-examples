from pyarrow.includes.libparquet_encryption cimport *



cdef void _cb_create_kms_client(
        handler,
        const CKmsConnectionConfig& kms_connection_config,
        shared_ptr[CKmsClient]* out) except *