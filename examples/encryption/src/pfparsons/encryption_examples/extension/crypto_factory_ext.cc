#include "crypto_factory_ext.h"
#include "parquet/exception.h"

namespace pfparsons {
namespace examples {
namespace encryption {


arrow::Result<std::shared_ptr<::parquet::FileEncryptionProperties>>
PyCryptoFactoryExt::SafeGetFileEncryptionProperties(
    const ::parquet::encryption::KmsConnectionConfig& kms_connection_config,
    const ::parquet::encryption::EncryptionConfiguration& encryption_config) {
  PARQUET_CATCH_AND_RETURN(
      this->GetFileEncryptionProperties(kms_connection_config, encryption_config));
}

arrow::Result<std::shared_ptr<::parquet::FileEncryptionProperties>>
PyCryptoFactoryExt::SafeGetFileEncryptionProperties(
    const ::parquet::encryption::KmsConnectionConfig &kms_connection_config,
    const ::parquet::encryption::EncryptionConfiguration &encryption_config,
    const std::string &file_path,
    const std::shared_ptr<::arrow::fs::FileSystem> &file_system) {
    PARQUET_CATCH_AND_RETURN(
        this->GetFileEncryptionProperties(kms_connection_config,
                                            encryption_config,
                                            file_path,
                                            file_system));
}


arrow::Result<std::shared_ptr<::parquet::FileDecryptionProperties>>
PyCryptoFactoryExt::SafeGetFileDecryptionProperties(
    const ::parquet::encryption::KmsConnectionConfig& kms_connection_config,
    const ::parquet::encryption::DecryptionConfiguration& decryption_config) {
  PARQUET_CATCH_AND_RETURN(
      this->GetFileDecryptionProperties(kms_connection_config, decryption_config));
}

} // namespace encryption
} // namespace examples
} // namespace pfparsons
