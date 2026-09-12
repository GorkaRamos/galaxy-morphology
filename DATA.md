# Data manifest

Four public datasets. Nothing here is redistributed by this repository: every file is
fetched from its own archive, and the table below is what a reader needs in order to
be certain they fetched the same thing we did.

`python -m src.download_data` retrieves the first two. `python -m src.prepare_fmh`
and `python -m src.replication` retrieve the other two on first use, since they are
small enough that a separate download step would be ceremony.

## Galaxy Zoo 2

The study set. 243,434 SDSS cutouts of the original sample, with the volunteer vote
tables behind them.

| | |
|---|---|
| images | `images_gz2.zip`, 3.4 GB, [10.5281/zenodo.3565489](https://doi.org/10.5281/zenodo.3565489) |
| filename mapping | `gz2_filename_mapping.csv`, same record |
| vote table | `gz2_hart16.csv.gz`, <https://gz2hart.s3.amazonaws.com/gz2_hart16.csv.gz> |
| licence | Creative Commons Attribution 4.0 |
| citation | Willett et al. (2013); debiased fractions from Hart et al. (2016) |

The vote table is the one that matters for this paper. `t01_smooth_or_features` holds
the per-galaxy counts for the three answers to task 01, and the label is the
renormalised fraction over the first two, `p_featured` in
`$GZM_WORK/arrays/gz2_table.csv`.

## Galaxy10 DECaLS

Held out entirely, used once for the zero-shot cross-survey evaluation.

| | |
|---|---|
| file | `Galaxy10_DECals.h5`, 2.7 GB, [10.5281/zenodo.10845026](https://doi.org/10.5281/zenodo.10845026) |
| licence | Creative Commons Attribution 4.0 |
| citation | Leung and Bovy (2019), distributed with `astroNN`; imaging from Dey et al. (2019) |

Categorical classes only, with no vote fractions, which is why the cross-survey
evaluation is the one experiment in the paper that cannot be resolved by agreement.

## Fashion-MNIST-H

The replication set. About sixty-seven annotations for each of the ten thousand
Fashion-MNIST test images.

| | |
|---|---|
| annotations | `fmh_counts.csv`, <https://raw.githubusercontent.com/ishida-lab/irreducible/main/data/fmh_counts.csv> |
| images | the four Fashion-MNIST idx files, <https://github.com/zalandoresearch/fashion-mnist> |
| licence | MIT (Fashion-MNIST); the annotations are released with the paper below |
| citation | Ishida et al. (2023); images from Xiao et al. (2017) |

The annotations cover the test split only. `src/prepare_fmh.py` builds one binary pair
from them, renormalising over the two answers exactly as the artefact votes are
dropped on Galaxy Zoo 2.

## CIFAR-10H

The negative control. About fifty annotations for each of the ten thousand CIFAR-10
test images, and a panel that almost never divides.

| | |
|---|---|
| annotations | `cifar10h-counts.npy`, 800 kB, <https://github.com/jcpeterson/cifar-10h> |
| licence | Creative Commons Attribution 4.0 |
| citation | Peterson et al. (2019) |

Only the count vectors are needed. The images are never downloaded, because the
control is a statement about the annotation and not about any model.

## Checking what you downloaded

The archives are versioned by DOI, so a Zenodo record is already a fixed object. For
the two files served outside Zenodo, and for anyone who wants to be sure, record the
digests of what you actually have:

```bash
cd "$GZM_DATA"
sha256sum gz2_hart16.csv gz2_filename_mapping.csv images_gz2.zip \
          Galaxy10_DECals.h5 fashion_mnist/* cifar10h/*.npy > sha256.txt
```

`sha256.txt` is not committed here, because a digest published by the party that also
publishes the pipeline vouches for nothing that the DOIs do not already vouch for. It
is worth keeping alongside your own copy of the data so that a rerun months later can
tell whether an upstream file moved underneath it.
