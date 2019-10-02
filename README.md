

# DSSL-AAAI2019
Codes for AAAI 2019 paper "Distribution-based Semi-Supervised Learning for Activity Recognition".
> ```
>@inproceedings{DBLP:conf/aaai/QianPM19,
>  author    = {Hangwei Qian and
>               Sinno Jialin Pan and
>               Chunyan Miao},
>  title     = {Distribution-Based Semi-Supervised Learning for Activity Recognition},
>  booktitle = {{AAAI}},
>  pages     = {7699--7706},
>  publisher = {{AAAI} Press},
>  year      = {2019}
>}
> ```


The codes are tested in Ubuntu 14.04, with Matlab R2017b. Current file contains codes on [WISDM v1.1 dataset](http://www.cis.fordham.edu/wisdm/dataset.php#actitracker). The data preprocessing needs two Matlab packages to be installed, i.e., `matlab2weka` and `weka`, as shown in folder `/Code_Matlab`.


To run the code, please run the following script:

```
bash z_run_all.sh
```


Something to note:

-  Note that some of the file paths may need to be modified to your own paths.
-  WISDM dataset do not contain Null class. If the codes are applied to other datasets with Null class, kindly uncoment the codes of F-measure calculation in `micro_macro_PR_WISDM.m` accordingly. 






