# distutils: language=c++

from pyarrow.lib cimport *
#from pyarrow.includes.common cimport *
from pyarrow._fs cimport FileSystem
from cython.operator cimport dereference as deref

cdef class CryptoFactoryExt(CryptoFactory):
    """ A factory that produces the low-level FileEncryptionProperties and
    FileDecryptionProperties objects, from the high-level parameters."""
    # Avoid mistakingly creating attributes
    __slots__ = ()

    def __init__(self, kms_client_factory):
        self.factory.reset(new CPyCryptoFactoryExt())

        if callable(kms_client_factory):
            self.init(kms_client_factory)
            print("Got this far")

        else:
            raise TypeError("Parameter kms_client_factory must be a callable")

    cdef init(self, callable_client_factory):
        cdef:
            CPyKmsClientFactoryVtable vtable
            shared_ptr[CPyKmsClientFactory] kms_client_factory

        vtable.create_kms_client = _cb_create_kms_client
        kms_client_factory.reset(
            new CPyKmsClientFactory(callable_client_factory, vtable))
        # A KmsClientFactory object must be registered
        # via this method before calling any of
        # file_encryption_properties()/file_decryption_properties() methods.
        self.factory.get().RegisterKmsClientFactory(
            static_pointer_cast[CKmsClientFactory, CPyKmsClientFactory](
                kms_client_factory))


    def file_encryption_properties(self,
        KmsConnectionConfig kms_connection_config,
        EncryptionConfiguration encryption_config,
        c_string file_path = "",
        FileSystem file_system = None):

        if file_path == "" or file_system is None:
            return super().file_encryption_properties(kms_connection_config, encryption_config)

        cdef:
            CResult[shared_ptr[CFileEncryptionProperties]] \
                file_encryption_properties_result
        with nogil:
            file_encryption_properties_result = \
                self.factory.get().SafeGetFileEncryptionProperties(
                    deref(kms_connection_config.unwrap().get()),
                    deref(encryption_config.unwrap().get()),
                    file_path,
                    file_system.unwrap())

        file_encryption_properties = GetResultValue(
            file_encryption_properties_result)

        return FileEncryptionProperties.wrap(file_encryption_properties)

