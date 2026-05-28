# Config Rules

Per-dataset settings are supplied inline in the `data_request` entry under the `dataset_config` key. Your dataset class receives that dict as the `config` argument to `__init__`.

Read settings with `config.get(name, default)` so the class works whether or not the caller overrides them:

```python
def __init__(self, config, data_location=None):
    n_objects = config.get("n_objects", 64)
    self.open_kwargs = config.get("open_kwargs", {})
    # ... dataset-specific setup ...
    super().__init__(config)
```

Supply the matching values when wiring the dataset into Hyrax:

```python
h.set_config(
    "data_request",
    {
        "train": {
            "data": {
                "dataset_class": "YourDataset",
                "data_location": "/path/to/data",
                "dataset_config": {"n_objects": 32, "open_kwargs": {}},
                "fields": ["flux", "object_id"],
                "primary_id_field": "object_id",
            }
        }
    },
)
```

Use pass-through dictionaries for optional keyword arguments owned by an underlying library. Keep them in a single `open_kwargs`-style dict, default it to `{}`, and forward with `**kwargs`:

```python
open_kwargs = config.get("open_kwargs", {})
resource = library.open(data_location, **open_kwargs)
```

Choose defaults that make the common case work with no configuration. Use an explicit sentinel default (e.g. `None`/`False` meaning "disabled" or "infer automatically") only for meaningful user choices.

Do not redefine optional keyword argument keys owned by an underlying library as top-level settings. Keep those inside the pass-through dict unless Hyrax itself needs to interpret the option.

## Productionizing: package `default_config.toml` (optional)

When the class moves into a standalone package, the only required change is referencing it by its fully-qualified import path in `dataset_class`; settings can still be passed inline via `dataset_config`.

A package may also ship defaults in a `default_config.toml`, which Hyrax merges through its layered configuration system. Namespace the table by your package and class name:

```toml
[my_package.YourDataset]
n_objects = 64

[my_package.YourDataset.open_kwargs]
# library_option = "example"
```

See the [external package setup guide](https://hyrax.readthedocs.io/en/stable/external_library_package.html) for the full package layout and the layered configuration system.
