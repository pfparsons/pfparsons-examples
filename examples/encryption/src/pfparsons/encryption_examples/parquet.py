import pyarrow.parquet as pq
import pyarrow.parquet.encryption as pe
import pyarrow as pa
from pyarrow import fs
import tempfile
from pathlib import Path
from pfparsons.encryption_examples.kms.fake_kms import FakeKMSClient

from pfparsons.encryption_examples.extension.crypto_factory_ext import CryptoFactoryExt  # type: ignore

def main():
    example_table = pa.Table.from_pydict(
        {  # type: ignore
            "a": pa.array([1, 2, 3]),
            "b": pa.array(["a", "b", "c"]),
            "c": pa.array(["x", "y", "z"]),
        }
    )

    encryption_config = pe.EncryptionConfiguration(  # type: ignore
        internal_key_material = False,
        footer_key="footer_key",
        column_keys={
            "col_a_key": ["a"],
            "col_b_key": ["b"],
        },
    )

    kms_connection_config = pe.KmsConnectionConfig(
        kms_instance_url="http://localhost:8080",
        key_access_token="abcdef123456",
    )  # type: ignore

    def kms_factory(config):
        return FakeKMSClient(config)

    crypto_factory = CryptoFactoryExt(kms_factory)  # type: ignore



    parquet_basedir = Path("/tmp/parquet")
    parquet_keyfile = parquet_basedir / "keyfile"
    parquet_data_file = parquet_basedir / "example_encrypted.parquet"

    file_encryption_properties = crypto_factory.file_encryption_properties(
        kms_connection_config, 
        encryption_config,
        str(parquet_keyfile),
        fs.LocalFileSystem()
    )

    parquet_path = Path("/tmp/parquet") / "example_encrypted.parquet"
    print(f"Writing to {parquet_path}")

    with pq.ParquetWriter(
        parquet_path,
        example_table.schema,
        encryption_properties=file_encryption_properties,
    ) as writer:  # type: ignore
        writer.write_table(example_table)  # type: ignore

    file_decryption_properties = crypto_factory.file_decryption_properties(
        kms_connection_config
    )
    file = pq.ParquetFile(
        parquet_path, 
        decryption_properties=file_decryption_properties
    )


    from pprint import pprint

    pprint(file.metadata.to_dict())

    result_table = file.read()

    print(result_table.to_pandas())


def test_ext():
    array = pa.array([1, 2, 3, 4, 5])
    print(get_array_length(array))  # type: ignore