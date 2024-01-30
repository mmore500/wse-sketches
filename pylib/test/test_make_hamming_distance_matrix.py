from pylib._make_hamming_distance_matrix import make_hamming_distance_matrix


def test_make_hamming_distance_matrix_known_input():
    seq = [0b01, 0b11, 0b10]
    taxa = ["A", "B", "C"]
    expected_distances = {
        ("A", "B"): 1,
        ("A", "C"): 2,
        ("B", "C"): 1,
    }

    distance_matrix = make_hamming_distance_matrix(seq, taxa)
    lookup = dict(
        zip(
            ["A", "B", "C"],
            sorted(distance_matrix.taxon_iter(), key=lambda x: x.label),
        )
    )

    for (taxon1, taxon2), expected_distance in expected_distances.items():
        assert lookup[taxon1].label == taxon1
        assert lookup[taxon2].label == taxon2
        calculated_distance = distance_matrix.distance(
            lookup[taxon1], lookup[taxon2]
        )
        assert calculated_distance == expected_distance, (taxon1, taxon2)


def test_make_hamming_distance_matrix_known_input_default_taxa():
    seq = [0b01, 0b11, 0b10]
    expected_distances = {
        ("0", "1"): 1,
        ("0", "2"): 2,
        ("1", "2"): 1,
    }

    distance_matrix = make_hamming_distance_matrix(seq)
    lookup = dict(
        zip(
            ["0", "1", "2"],
            sorted(distance_matrix.taxon_iter(), key=lambda x: x.label),
        )
    )
    for (taxon1, taxon2), expected_distance in expected_distances.items():
        assert lookup[taxon1].label == taxon1
        assert lookup[taxon2].label == taxon2
        calculated_distance = distance_matrix.distance(
            lookup[taxon1], lookup[taxon2]
        )
        assert calculated_distance == expected_distance


def test_make_hamming_distance_matrix_singleton():
    seq = [0b01]
    taxa = ["A"]
    expected_distances = {
        ("A", "A"): 0,
    }

    distance_matrix = make_hamming_distance_matrix(seq)

    for (taxon1, taxon2), expected_distance in expected_distances.items():
        calculated_distance = distance_matrix.distance(taxon1, taxon2)
        assert calculated_distance == expected_distance


def test_make_hamming_distance_matrix_empty():
    seq = []
    distance_matrix = make_hamming_distance_matrix(seq)
    assert len(distance_matrix.distances()) == 0
