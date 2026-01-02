"""
Test Django management commands.
"""
from unittest.mock import patch  # noqa
from psycopg2 import OperationalError as Psycopg2OperationalError  # noqa
