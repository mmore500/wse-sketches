import copy

from Bio import Phylo as BioPhylo
from matplotlib import pyplot as plt
from matplotlib.figure import Figure as mpl_Figure


# adapted from https://github.com/mmore500/hstrat-recomb-concept/blob/b71d36216f1d2990343b6435240d8c193a82690b/pylib/tree/draw_biopython_tree.py
def draw_biopython_tree(
    tree: BioPhylo.BaseTree,
    fig_size: tuple = (6.5, 4),
    line_width: float = 4.0,
    drop_overlapping_labels: bool = False,
) -> mpl_Figure:
    biopy_tree = copy.deepcopy(tree)

    with plt.rc_context(
        {
            "lines.linewidth": line_width,
        }
    ):
        plt.gcf().set_size_inches(*fig_size)
        BioPhylo.draw(
            biopy_tree,
            axes=plt.gca(),
            label_func=lambda node: ""
            if not node.is_terminal()
            else node.name,
            do_show=False,
        )

        colormap = {
            terminal.name: terminal.color
            for terminal in biopy_tree.get_terminals()
        }
        for label in plt.gca().texts:
            text = label.get_text().strip()
            if text in colormap:
                branch_color = colormap[text]
                label.set_color(branch_color.to_hex())

        if drop_overlapping_labels:
            # Code to remove overlapping annotations
            bboxes = []
            for label in plt.gca().texts:
                bbox = label.get_window_extent()
                # Check if current label overlaps with the others
                overlaps = any(bbox.overlaps(bbox_) for bbox_ in bboxes)
                if overlaps:
                    label.set_visible(False)
                else:
                    bboxes.append(bbox)

        plt.gca().spines["top"].set_visible(False)
        plt.gca().spines["right"].set_visible(False)

        plt.gca().spines["left"].set_visible(False)
        plt.gca().set_yticklabels([])
        plt.gca().set_yticks([])
        plt.gca().axes.get_yaxis().set_visible(False)

        plt.gca().set_xlabel("Generations")
