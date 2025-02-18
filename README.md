# pre-commit-pylyzer

A [pre-commit](https://pre-commit.com/) hook for [pylyzer](https://github.com/mtshiba/pylyzer).

## Using pylyzer with pre-commit

To run pylyzer via pre-commit, add the following to your ``.pre-commit-config.yaml``:
```yaml
repos:
- repo: https://github.com/LoicRiegel/pylyzer-pre-commit
  # pylyzer version.
  rev: v0.9.6
  hooks:
    - id: pylyzer
```
