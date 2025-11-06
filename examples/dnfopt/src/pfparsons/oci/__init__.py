# pyright: reportPossiblyUnboundVariable=false
import importlib.util
import sys
import sysconfig
from pathlib import Path
from types import ModuleType
from typing import Literal, TypeAlias, TypeIs, Annotated, Self
from annotated_types import Ge, Le
from dataclasses import dataclass, field


libdnf5_name = "libdnf5"
libdnf5_path = Path(
    f"{sysconfig.get_paths()['stdlib']}/site-packages/libdnf5/__init__.py"
)
if not libdnf5_path.exists():
    raise RuntimeError("libdnf5 is not installed")
spec = importlib.util.spec_from_file_location(libdnf5_name, libdnf5_path)
if spec is None:
    raise RuntimeError(f"Unable to create spec for {libdnf5_name}, {libdnf5_path}")
libdnf5 = importlib.util.module_from_spec(spec)
sys.modules[libdnf5_name] = libdnf5
if spec.loader is None:
    raise RuntimeError(f"Unable to create spec for {libdnf5_name}, {libdnf5_path}")
spec.loader.exec_module(libdnf5)


# try:
#     import libdnf5
# except ImportError:
#     _import_libdnf5()


Scope: TypeAlias = Annotated[int, Ge(0), Le(2)]
AVIALABLE: Scope = libdnf5.base.repo.Repo.Type_AVAILABLE
SYSTEM: Scope = libdnf5.base.repo.Repo.Type_SYSTEM

DEFAULT_REPO_PATH = "/etc/yum.repos.d/"


def _make_base(
    scope: Scope = AVIALABLE, repo_path: Path | str = DEFAULT_REPO_PATH
) -> libdnf5.base.Base:
    base = libdnf5.base.Base()
    base.load_config()
    base.setup()
    repo_sack = base.get_repo_sack()
    repo_sack.create_repos_from_dir(repo_path)
    repo_sack.load_repos(scope)
    return base


@dataclass
class PackageNode:
    name: str
    evr: str
    arch: str
    nevra: str
    download_size: int
    install_size: int
    children: list["PackageNode"] = field(default_factory=list)

    def __str__(self) -> str:
        return self.nevra

    def __repr__(self) -> str:
        return str(self)
    
    def __hash__(self) -> int:
        return hash(self.nevra)
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, PackageNode):
            return False
        return self.nevra == other.nevra
    
    @property
    def total_install_size(self) -> int:
        return self.install_size + sum(child.total_install_size for child in self.children)


    @classmethod
    def from_package(cls, pkg: libdnf5.rpm.Package) -> Self:
        return cls(
            name=pkg.get_name(),
            evr=pkg.get_evr(),
            arch=pkg.get_arch(),
            nevra=pkg.get_full_nevra(),
            download_size=pkg.get_download_size(),
            install_size=pkg.get_install_size()
        )


class DNF:
    def __init__(self):
        self.base = _make_base(scope=AVIALABLE)
        self.nodes: dict[str, PackageNode] = {}

    def _dependencies(self, package_name: str) -> PackageNode:
        goal = libdnf5.base.Goal(self.base)
        goal.add_install(package_name)
        tx = goal.resolve()
        pkg_tx_list = tx.get_transaction_packages()

        # TODO:libdnf5.transaction.transaction_item_action_to_string(pkg_tx.get_action())

        deps = [PackageNode.from_package(tx.get_package()) for tx in reversed(pkg_tx_list)]
        
        if len(deps) == 0:
            raise LookupError(f"Unable to find package named {package_name} ")
        
        node = None
        for d in reversed(deps):
            if d.name == package_name or d.nevra == package_name:
                node = d
                deps.remove(d)
        if node is not None:
            node.children = deps
            return node
        elif len(deps) > 0:
            return PackageNode(
                name=package_name,
                evr="",
                arch="",
                nevra="",
                download_size=0,
                install_size=0,
                children=deps
            )
        else:
            raise LookupError(f"Error while resolving deps for package {package_name}")
    
    def dependencies(self, package_name: str) -> PackageNode:
        if package_name not in self.nodes:
            node = self._dependencies(package_name)
            self.nodes[node.nevra] = node
            for dep_node in reversed(node.children):
                if dep_node not in self.nodes:
                    resolved_dep_node = self.dependencies(dep_node.nevra)
                    self.nodes[resolved_dep_node.nevra] = resolved_dep_node
            return node
        else:
            return self.nodes[package_name]


from pathlib import Path

