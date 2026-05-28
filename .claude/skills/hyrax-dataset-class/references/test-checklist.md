# Test Checklist

Notebook-first datasets are usually validated by running `h.prepare()` and inspecting a sample in the notebook. Add formal tests when the user moves the class into a package or asks for them.

Cover the smallest representative sample:

- Constructor loads or connects using temporary sample data.
- `len(dataset)` matches the number of objects.
- `get_<primary_id_field>(idx)` returns stable unique IDs.
- Each requested getter returns the expected value, shape, and type.
- Dataset-specific settings are read from the inline `dataset_config` dict with `config.get(...)`.
- Pass-through kwargs reach the underlying library when supported.
- Missing `data_location` raises only when the dataset cannot sensibly operate without it.

Prefer tests that create realistic tiny data in `tmp_path` over tests that depend on repository data fixtures. Keep the assertions tied to the public Hyrax behavior: constructor, `__len__`, and `get_<field>` methods.

## Fixture Pattern

Use this pattern to create sample data and a dataset instance for testing:

```python
import pytest

from my_package.datasets.your_dataset_module import YourDataset


@pytest.fixture
def sample_data(tmp_path):
    """Create minimal realistic data on disk and return the path."""
    data_path = tmp_path / "sample_data"
    # Write a small representative dataset here (3-5 rows is enough)
    # e.g. write a CSV, create a database, write parquet files
    return data_path


def test_dataset_length_and_getters(sample_data):
    dataset = YourDataset(
        # config is the inline dataset_config dict the dataset reads with config.get(...)
        config={"some_option": "value", "open_kwargs": {}},
        data_location=sample_data,
    )

    assert len(dataset) == 3
    assert dataset.get_object_id(0) == "expected_id"
    assert dataset.get_flux(1) == pytest.approx(20.5)
```

Key points: pass `config` as the inline `dataset_config` dict the dataset reads with `config.get(...)`. Import the class from the user's own package module. Use `pytest.approx` for floats. Test every getter the dataset exposes.

Run the targeted dataset tests first. Run broader tests only when the change touches shared dataset loading, config parsing, data request handling, or collation behavior.
