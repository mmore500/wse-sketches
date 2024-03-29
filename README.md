# wse-sketches

[![CI](https://github.com/mmore500/wse-sketches/actions/workflows/ci.yaml/badge.svg)](https://github.com/mmore500/wse-sketches/actions/workflows/ci.yaml)
[![GitHub stars](https://img.shields.io/github/stars/mmore500/wse-sketches.svg?style=flat-square&logo=github&label=Stars&logoColor=white)](https://github.com/mmore500/wse-sketches)
[![DOI](https://zenodo.org/badge/650194447.svg)](https://zenodo.org/doi/10.5281/zenodo.10779280)

Development work for agent-based evolution/epidemiological modeling on the Cerebras Wafer-scale Engine (WSE) hardware.
Incoprorates [hereditary stratigraphy](https://github.com/mmore500/hstrat) methodology for distributed tracking of agent phylogenies.

Requires [Cerebras SDK](https://www.cerebras.net/developers/sdk-request/), available through invitation.

## Contents

- `ziglib`: port of [`hsurf` algorithms](https://github.com/mmore500/hstrat-surface-concept/) from Python to Zig
- `cerebraslib`: port of `hsurf` algorithms to Cerebras Software Language (CSL) as well other supporting materials for WSE kernels
- `kernel-test-cerebraslib`: uses Cerebras WSE hardware simulator to run unit tests on `cerebraslib` components
- `kernel-async-ga`: general purpose framework for decentralized, island-model genetic algorithm across WSE Processing Elements (PEs), with configurably-sized agent genomes, customizable mutation operator, and customizable fitness function; includes scripts to run on Cerebras WSE hardware simulator
- `kernel-self-driving` and `kernel-simple-ga`: early exploration of WSE capabilities and design patterns
- `pylib`: Python support code for data analysis
- `binder`: data analysis notebooks (empty; ran in CI and synced to `binder` branch)
- `tex`: manuscript source materials

## Installation and Running

See our [Continuous Integration config](https://github.com/mmore500/wse-sketches-mirror/blob/master/.github/workflows/ci.yaml) for detailed instructions on installing dependencies and running project components.

Note that the `test-csl` continuous integration components do not run within the scope of the public-facing `wse-sketches` repository in order to protect Cerebras' intellectual property.

## Citing

If wse-sketches contributes to a scientific publication, please cite it as

> Matthew Andres Moreno and Connor Yang. (2024). mmore500/wse-sketches. Zenodo. https://doi.org/10.5281/zenodo.10779280

```bibtex
@software{moreno2024wse,
  author = {Matthew Andres Moreno and Connor Yang},
  title = {mmore500/wse-sketches},
  month = mar,
  year = 2024,
  publisher = {Zenodo},
  doi = {10.5281/zenodo.10779280},
  url = {https://doi.org/10.5281/zenodo.10779280}
}
```

Consider also citing [hsurf](https://github.com/mmore500/hstrat-surface-concept/blob/master/README.md#citing) and [hstrat](https://hstrat.readthedocs.io/en/stable/citing.html).
And don't forget to leave a [star on GitHub](https://github.com/mmore500/pecking/stargazers)!

## Contact

Matthew Andres Moreno
<morenoma@umich.edu>
