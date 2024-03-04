import io
import numbers
import typing

import dendropy as dp
import opytional as opyt
import pandas as pd


def make_hamming_distance_matrix(
    seq: typing.Iterable[numbers.Integral],
    taxa: typing.Optional[typing.Iterable[str]] = None,
) -> dp.PhylogeneticDistanceMatrix:
    """Constructs a Hamming distance matrix for a given sequence of integer
    bit fields.

    This function calculates the pairwise Hamming distance between elements of
    `seq`, then constructs and returns a DendroPy PhylogeneticDistanceMatrix
    object from the resulting distance matrix. If `taxa` is provided, it labels
    the rows and columns of the distance matrix with these labels; otherwise,
    integer indices are used as labels.

    Parameters
    ----------
    seq : typing.Iterable[numbers.Integral]
        An iterable of integral numbers for which the pairwise Hamming
        distances will be calculated.
    taxa : typing.Optional[typing.Iterable[str]], optional
        An optional iterable of strings to label the elements in `seq`.

        If not provided, integer indices will be used as labels.

    Returns
    -------
    dp.PhylogeneticDistanceMatrix
        A DendroPy PhylogeneticDistanceMatrix object representing the
        Hamming distance among items in seq.
    """
    seq = list(seq)
    taxa = opyt.apply_if_or_value(taxa, list, [*map(str, range(len(seq)))])

    distances = [[int(row ^ col).bit_count() for col in seq] for row in seq]
    df = pd.DataFrame(distances, index=taxa, columns=taxa)
    buffer = io.StringIO()
    df.to_csv(buffer)
    buffer.seek(0)
    return dp.PhylogeneticDistanceMatrix.from_csv(
        buffer, is_allow_new_taxa=True
    )
