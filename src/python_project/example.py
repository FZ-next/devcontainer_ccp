"""Example module to demonstrate project structure."""


def hello(name: str | None = None) -> str:
    """Return a greeting message.

    Args:
        name: The name to greet. If None, uses a generic greeting.

    Returns:
        A greeting message.
    """
    if name:
        return f"Hello, {name}!"
    return "Hello, world!"


class ExampleClass:
    """Example class to demonstrate project structure."""

    def __init__(self, items: list[str] | None = None) -> None:
        """Initialize the example class.

        Args:
            items: Optional list of items to store.
        """
        self.items = items or []

    def add_item(self, item: str) -> None:
        """Add an item to the list.

        Args:
            item: The item to add.
        """
        self.items.append(item)

    def get_items(self) -> list[str]:
        """Get all items.

        Returns:
            A list of all items.
        """
        return self.items
