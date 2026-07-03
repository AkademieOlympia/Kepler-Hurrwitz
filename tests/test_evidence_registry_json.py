import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "EVIDENCE_REGISTER.json"


def load_registry():
    with REGISTRY_PATH.open("r", encoding="utf-8") as f:
        return json.load(f)


def test_evidence_registry_json_is_loadable():
    data = load_registry()
    assert isinstance(data, dict)
    assert "entries" in data
    assert isinstance(data["entries"], list)


def test_evidence_ids_are_unique():
    data = load_registry()
    ids = [entry["id"] for entry in data["entries"]]
    assert len(ids) == len(set(ids))


def test_referenced_evidence_ids_exist():
    data = load_registry()
    ids = {entry["id"] for entry in data["entries"]}
    for entry in data["entries"]:
        for field in ("depends_on", "supports"):
            for ref in entry.get(field, []):
                if isinstance(ref, str) and ref.startswith("E-"):
                    assert ref in ids, (
                        f"{entry['id']} references missing {field} id {ref}"
                    )


def test_a_entries_have_valid_aclass():
    data = load_registry()
    valid_aclasses = {"A-T", "A-I", "A-D"}
    for entry in data["entries"]:
        if entry.get("level") == "A":
            assert entry.get("aclass") in valid_aclasses, (
                f"{entry['id']} is level A but has invalid aclass"
            )
        else:
            assert entry.get("aclass") in (None, "", "-"), (
                f"{entry['id']} is not level A but has aclass"
            )


def test_b_entries_have_scope_and_metric():
    data = load_registry()
    for entry in data["entries"]:
        if entry.get("level") == "B":
            assert entry.get("scope"), f"{entry['id']} is B but has no scope"
            assert entry.get("metric_or_result"), (
                f"{entry['id']} is B but has no metric_or_result"
            )
