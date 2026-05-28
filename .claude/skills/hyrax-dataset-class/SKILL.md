---
name: hyrax-dataset-class
description: Create or update Hyrax dataset classes. Use when the user asks to "create a dataset class", "add a HyraxDataset", "load my data through Hyrax", "add dataset getter methods", "wire dataset defaults", "add dataset tests", or "make a notebook example" for a Hyrax dataset. Also use when a task involves data_request fields, primary_id_field, or dataset config for use with Hyrax in a notebook or external package.
metadata:
  version: "0.1.0"
---

# Hyrax Dataset Class

## First Read

Read the [Hyrax Dataset Class Reference](https://hyrax.readthedocs.io/en/stable/dataset_class_reference.html) before implementing. Treat it as the interface contract.

Read the [external dataset class notebook](https://hyrax.readthedocs.io/en/stable/pre_executed/external_dataset_class.html) for the recommended notebook-first workflow and the `data_request` config structure.

Default to the notebook-first workflow: define the dataset class directly in the user's notebook, reference it by its bare class name, and supply per-dataset settings inline through the `dataset_config` dict in the `data_request`. Moving the class into a standalone package is an optional later step. See [references/config-rules.md](references/config-rules.md) for details.

Use existing dataset modules, tests, and notebook examples only as local patterns. Do not blindly copy an implementation; adapt the shape to the user's data format and requested fields.

Read [references/config-rules.md](references/config-rules.md) before reading or adding dataset config keys.

Read [references/test-checklist.md](references/test-checklist.md) before writing or reviewing dataset tests.

## Canonical Minimal Example

Use this as the starting shape for any new dataset class. Define it directly in the user's notebook and adapt it to their data format.

```python
import numpy as np
from hyrax.datasets import HyraxDataset


class ExampleSurveyDataset(HyraxDataset):
    """Hyrax dataset wrapping a survey data source."""

    def __init__(self, config, data_location=None):
        # Per-dataset settings arrive inline via the data_request "dataset_config" dict.
        n_objects = config.get("n_objects", 64)

        # Use data_location to find real files and load small catalogs or
        # file-path lists here. This example generates fake data instead.
        rng = np.random.default_rng(7)
        self.images = rng.normal(size=(n_objects, 3, 32, 32)).astype(np.float32)
        self.labels = rng.integers(0, 5, size=n_objects, dtype=np.int64)

        # Always call super().__init__ last, after your attributes are set.
        super().__init__(config)

    def __len__(self):
        return len(self.images)

    def get_image(self, idx):
        return self.images[idx]

    def get_label(self, idx):
        return int(self.labels[idx])

    def get_object_id(self, idx):
        return f"obj-{idx:05d}"
```

Wire it into Hyrax in the notebook by referencing the class by its bare name and passing settings through `dataset_config`:

```python
from hyrax import Hyrax

h = Hyrax()
h.set_config(
    "data_request",
    {
        "train": {
            "data": {  # friendly name — any string
                "dataset_class": "ExampleSurveyDataset",
                "data_location": "/path/to/data",
                "dataset_config": {"n_objects": 32},
                "fields": ["image", "label", "object_id"],
                "primary_id_field": "object_id",
            }
        }
    },
)

prepared = h.prepare()
sample = prepared["train"][0]["data"]
```

Key points this example demonstrates:
- Import from `hyrax.datasets`, not `hyrax.datasets.dataset_registry`.
- Class name ends in `Dataset`.
- One-line class docstring.
- Per-dataset settings come from the inline `dataset_config` dict, read with `config.get(name, default)`.
- `super().__init__(config)` is called last, after attributes are set.
- Optional dependency imported inside the method that uses it.
- Explicit getter methods for known fields, including `get_object_id`.
- In the notebook the class is referenced by its bare name in `data_request`.

## User Discovery

Ask only material questions. Get enough information to define the golden path:

- Data location and storage format: file, directory, database, remote service, table name, split name, or other locator.
- Object granularity: what one `idx` represents.
- Dataset length source: catalog rows, files, table rows, remote records, or configured limit.
- Requested Hyrax fields: `fields` values and the `primary_id_field` the data request will use.
- Field shapes and types: scalar, array, image, time series, nested table, label, mask, metadata.
- Required library pass-through kwargs and which settings should be exposed in `dataset_config`.

If the user is still exploring, stay at their level of generality: sketch the class skeleton, identify missing data details, and implement only what can be grounded in their example or specification.

## Implementation Workflow

1. Choose a class name ending in `Dataset` and define it directly in the user's notebook.
2. Import `HyraxDataset` from `hyrax.datasets` (the canonical import path — requires `hyrax` to be installed as a dependency). In the notebook, reference the class by its bare name in `data_request[...]["dataset_class"]`.
3. Implement `__init__(self, config, data_location=None)`. Read per-dataset settings from the inline `dataset_config` dict via `config.get(name, default)`.
4. Store `data_location` when relevant and do one-time setup there: locate files, load small catalogs, open handles, or store pass-through kwargs.
5. Call `super().__init__(config)` last, after dataset-specific setup.
6. Implement `__len__(self)`.
7. Implement `get_<field_name>(self, idx)` for every field Hyrax may request, including `get_<primary_id_field>`.
8. Return stable, unique IDs from the primary ID getter. Prefer an existing unique object ID; otherwise use a stable index or deterministic hash from identifying values. Unique IDs must be strings.
9. Add a one-line class docstring describing what the dataset wraps.
10. Wire the class into Hyrax with `h.set_config("data_request", {...})`, passing settings through `dataset_config`, then call `h.prepare()` and inspect a sample (`prepared[step][friendly_name]`).
11. For variable-length fields (e.g. light curves), add a `collate_<field>(self, samples)` method that pads sequences to a common length and returns a mask of real vs. padded entries.

Keep heavy per-object work inside getters. Keep constructor work limited to setup that should happen once.

Do not implement `__getitem__` or a whole-dataset `collate` unless the user specifically asks for custom batching behavior. The base class and Hyrax machinery handle these; prefer field-level `collate_<field>` methods (step 11) for variable-length fields.

## Productionizing (Optional)

Once the class works in the notebook, the user can move it into a standalone Python package for reuse:

1. Place the class in a module under the package (e.g. `src/my_package/datasets/my_dataset.py`).
2. Change `dataset_class` in the `data_request` to the fully-qualified import path, e.g. `"my_package.datasets.my_dataset.MyDataset"`. Nothing else about the `data_request` needs to change.
3. Optionally ship defaults in the package's `default_config.toml` (see [references/config-rules.md](references/config-rules.md)).
4. Add focused tests under the package test directory (see [references/test-checklist.md](references/test-checklist.md)).

See the [external package setup guide](https://hyrax.readthedocs.io/en/stable/external_library_package.html). Only introduce this path when the user asks to productionize or share their dataset class.

## Code Style

Optimize for readability of the normal path over exhaustive error correction. Validate only the inputs that would otherwise produce confusing failures or silent wrong results.

Default to explicit getters. Use dynamic getter registration (the `_register_getters` pattern) only when the columns come from the data source at runtime and are not known at development time (e.g. CSV columns, database schemas, Parquet fields). For most scientist-written datasets where the fields are known up front, explicit `get_<field>` methods are clearer and easier to debug.

Keep optional dependency imports close to where they are needed when the dependency is dataset-specific.

Preserve underlying library return types when they are already useful to Hyrax. Ensure types passed to hyrax are `float`, `int`, `str`, or NumPy arrays.
