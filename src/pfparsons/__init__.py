"""Placeholder"""

from pyspark.sql import Row
from typing import NamedTuple
from dataclasses import dataclass

@dataclass
class ProductDataclass:
    id: int
    name: str
    size: str


class ProductRow(NamedTuple):
    id: int
    name: str
    size: str


example_pyspark_row = Row(
    id = 42,
    name = 'T-Shirt',
    size = 'Small',
    color = 'Blue'
)

example_product_row = ProductRow(
    id = 42,
    name = 'T-Shirt',
    size = 'Large'
)

def handle_product_row(row: ProductDataclass, count: int) -> None:
    print(f'Handling {type(row)}: id={row.id} name={row.name} size={row.size}')


handle_product_row(example_pyspark_row)

