#pragma once

#include <memory>

#include "parquet/encryption/crypto_factory.h"
#include "parquet/encryption/file_key_wrapper.h"
#include "parquet/encryption/key_toolkit.h"
#include "parquet/encryption/kms_client_factory.h"
#include "parquet/platform.h"

namespace pfparsons {
namespace examples {
namespace encryption {

class ARROW_PYTHON_PARQUET_ENCRYPTION_EXPORT PyCryptoFactoryExt
    : public ::parquet::encryption::CryptoFactory {
public:
arrow::Result<std::shared_ptr<::parquet::FileEncryptionProperties>>
SafeGetFileEncryptionProperties(
    const ::parquet::encryption::KmsConnectionConfig& kms_connection_config,
    const ::parquet::encryption::EncryptionConfiguration& encryption_config);

/// The returned FileDecryptionProperties object will use the cache inside this
/// CryptoFactory object, so please keep this
/// CryptoFactory object alive along with the returned
/// FileDecryptionProperties object.
arrow::Result<std::shared_ptr<::parquet::FileDecryptionProperties>>
SafeGetFileDecryptionProperties(
    const ::parquet::encryption::KmsConnectionConfig& kms_connection_config,
    const ::parquet::encryption::DecryptionConfiguration& decryption_config);

/// Get the encryption properties for a Parquet file.
/// If external key material is used then a file system and path to the
/// parquet file must be provided.
arrow::Result<std::shared_ptr<::parquet::FileEncryptionProperties>>
SafeGetFileEncryptionProperties(
    const ::parquet::encryption::KmsConnectionConfig &kms_connection_config,
    const ::parquet::encryption::EncryptionConfiguration &encryption_config,
    const std::string &file_path = "",
    const std::shared_ptr<::arrow::fs::FileSystem>& file_system = NULLPTR);

};


} // namespace encryption
} // namespace examples
} // namespace pfparsons
