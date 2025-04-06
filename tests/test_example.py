"""Tests for the example module."""
import pytest

from python_project.example import ExampleClass, hello


def test_hello_with_name() -> None:
    """Test the hello function with a name provided."""
    result = hello("Alice")
    assert result == "Hello, Alice!"


def test_hello_without_name() -> None:
    """Test the hello function without a name."""
    result = hello()
    assert result == "Hello, world!"


class TestExampleClass:
    """Tests for the ExampleClass."""

    def test_init_with_items(self) -> None:
        """Test initialization with items."""
        items = ["item1", "item2"]
        example = ExampleClass(items)
        assert example.get_items() == items

    def test_init_without_items(self) -> None:
        """Test initialization without items."""
        example = ExampleClass()
        assert example.get_items() == []

    def test_add_item(self) -> None:
        """Test adding an item."""
        example = ExampleClass()
        example.add_item("new_item")
        assert example.get_items() == ["new_item"]
