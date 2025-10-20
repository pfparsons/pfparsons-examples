#from pyarrow.lib import tobytes, frombytes
# from pyarrow._parquet_encryption cimport KmsConnectionConfig

# # Callback definitions for CPyKmsClientVtable
# cdef void _cb_wrap_key(
#         handler, const c_string& key_bytes,
#         const c_string& master_key_identifier, c_string* out) except *:
#     mkid_str = frombytes(master_key_identifier)
#     wrapped_key = handler.wrap_key(key_bytes, mkid_str)
#     out[0] = tobytes(wrapped_key)


# cdef void _cb_unwrap_key(
#         handler, const c_string& wrapped_key,
#         const c_string& master_key_identifier, c_string* out) except *:
#     mkid_str = frombytes(master_key_identifier)
#     wk_str = frombytes(wrapped_key)
#     key = handler.unwrap_key(wk_str, mkid_str)
#     out[0] = tobytes(key)


# cdef class KmsClient(_Weakrefable):
#     """The abstract base class for KmsClient implementations."""

#     def __init__(self):
#         self.init()

#     cdef init(self):
#         cdef:
#             CPyKmsClientVtable vtable = CPyKmsClientVtable()

#         vtable.wrap_key = _cb_wrap_key
#         vtable.unwrap_key = _cb_unwrap_key

#         self.client.reset(new CPyKmsClient(self, vtable))

#     def wrap_key(self, key_bytes, master_key_identifier):
#         """Wrap a key - encrypt it with the master key."""
#         raise NotImplementedError()

#     def unwrap_key(self, wrapped_key, master_key_identifier):
#         """Unwrap a key - decrypt it with the master key."""
#         raise NotImplementedError()

#     cdef inline shared_ptr[CKmsClient] unwrap(self) nogil:
#         return self.client


# Callback definition for CPyKmsClientFactoryVtable
cdef void _cb_create_kms_client(
        handler,
        const CKmsConnectionConfig& kms_connection_config,
        shared_ptr[CKmsClient]* out) except *:
    connection_config = KmsConnectionConfig.wrap(kms_connection_config)

    result = handler(connection_config)
    if not isinstance(result, KmsClient):
        raise TypeError(
            f"callable must return KmsClient instances, but got {type(result)}")

    out[0] = (<KmsClient> result).unwrap()


