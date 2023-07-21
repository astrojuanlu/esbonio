from __future__ import annotations

from esbonio.server import EsbonioLanguageServer

from .client_subprocess import make_subprocess_sphinx_client
from .manager import SphinxManager


def esbonio_setup(server: EsbonioLanguageServer):
    manager = SphinxManager(make_subprocess_sphinx_client, server)
    server.add_feature(manager)
