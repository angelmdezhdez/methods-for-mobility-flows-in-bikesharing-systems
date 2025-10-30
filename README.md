# Methods for mobility flows in bikesharing systems 🚴‍♂️💻
In this repository, we provide code that I used in my master's thesis to analyze mobility flows in bikesharing systems. The study case focuses on the bikesharing system in Mexico City (Ecobici) and Guadalajara (MiBici).
The code was written in Python and R programming languages. \
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) ![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)

## Repository structure
The repository is structured as follows:
- `envs/`: Contains the conda environment files for setting up the required dependencies.
- `src/`: Contains the folders with the code for methods implemented in the thesis.
  - `spk_flows_clustering/`: Code for clustering mobility flows using the Shortest Path Kernel (SPK) method for flows.
  - `dictionary_learning/`: Code for learning the dictionary and the weights of the flows using dictionary learning.
  - `learned_weights_clustering/`: Code for clustering the learned weights of the flows.
- `data/`: Contains data files.

## Shortest Path Kernel for flows and agglomerative clustering
The `src/spk_flows_clustering/` folder contains the implementation of the Shortest Path Kernel (SPK) for clustering mobility flows in bikesharing systems. The SPK method is based on the idea of representing flows as graphs and computing similarities between them using the shortest path distances. First, the code in `spk_matrix.py` computes the Gram matrix using the SPK method. This script, for its execution requires some arguments:
- `--directory`: (string) Path to save results.
- `--flows`: (string) Path to the file containing the flows data (.npy format).
- `--system`: (string) The bikesharing system to use: 'ecobici' or 'mibici' (default: 'ecobici').
- `--indexes`: (string) Indexes of the flows to consider. You can indicates as '[$a_1, a_2, ..., a_n$]' that is uniquely the indexes indicated or 'i[$a_1, a_2$]' that means the range since $a_1$ to $a_2$ (default: 'i[0,10]').
- `--sigma`: (float) $\sigma$ value for the Gaussian kernel in case you want to specify it, but with the system value the scripts choose the default by the respective system.
- `--normalize`: (int) Boolean value to indicate if the final Gram matrix should be normalized (default: 0).

You can run the script as follows (example) with the conda environment activated (env_py1 or env_py2):
```bash
python3 spk_matrix.py -dir ./results/ -flows ./data/ecobici_flows.npy --system ecobici --indexes i[0,100] --sigma 1.0 --normalize 0
```
After running the script, the Gram matrix will be saved in the specified directory in .npy format, as well as a .txt file with the parameters used and a heatmap of the Gram matrix as a .pdf file.

With the kernel matrix computed, you can proceed to cluster the flows using agglomerative clustering. The script `ker_aglo_clustering.r` performs agglomerative clustering on the kernel matrix. This script requires the following arguments:

- `--kernel_matrix`: (string) Path to the kernel matrix file (.npy format).
- `--names`: (string) Path to the names file of each object to cluster in format .CSV (optional, can contain a 'labels' to color the names in the dendrogram accordingly to a class).
- `--outdir`: (string) Path to save results.

You can run the script as follows (example) with the conda environment activated (env_r):
```bash
Rscript ker_aglo_clustering.r -km ./results/kernel_matrix.npy -names ./data/flow_names.csv -odir ./results/
```

This will generate the dendrogram plot saved as a .pdf file in the specified output directory as well as .npy files containing the cluster labels for different numbers of possible clusters.

## Dictionary learning for mobility flows
The `src/dictionary_learning/` folder contains the implementation of dictionary learning for mobility flows in bikesharing systems. 
The code in `train_dict.py` learns a dictionary of atoms and the corresponding weights for representing the flows. This script requires the following arguments:
- `--directory`: (string) Path to save results.
- `--flows`: (string) Path to the file containing the flows data (.npy).
- `--laplacian`: (string) Path to the file containing the graph Laplacian (.npy).
- `--number_atoms`: (int) Number of dictionary atoms to learn.
- `--epochs`: (int) Number of training epochs (default: 1000).
- `--regularization`: (string) Type of regularization to use ('l1' or 'l2').
- `--lambda_reg`: (float) Regularization parameter.
- `--smooth`: (int) Boolean value indicating whether to use smoothness regularization (1 for True, 0 for False).
- `--gamma_reg`: (float) Smoothness regularization parameter (default: 0.1).
- `--alpha_steps`: (int) Number of steps for the weight update (default: 100).
- `--dict_steps`: (int) Number of steps for the dictionary update (default: 100).
- `--learning_rate`: (float) Learning rate for the optimizer (default: 1e-4).
- `--batch_size`: (int) Batch size for training (default: 32).
- `--tolerance`: (float) Tolerance for early stopping (default: 1e-4).
- `--patience`: (int) Patience for early stopping (default: 15).

You can run the script as follows (example) with the conda environment activated (env_py2):
```bash
python3 train_dict.py -dir ./results/ -flows ./data/ecobici_flows.npy -lap ./data/ecobici_laplacian.npy -natoms 20 -ep 1000 -reg l1 -lambda 0.01 -smooth 1 --gamma 0.1 -as 100 -ds 100 -lr 0.0001 -bs 32 -tol 0.0001 -pat 15
```
After running the script, the learned dictionary and weights will be saved in the specified directory in .npy format, along with plots of the loss over epochs and some reconstructed flows as .pdf files. Also, a .txt file with the parameters used during training will be saved.

In the same folder, you will find the script `test_dict.py`, which allows you to test a pre-trained dictionary on new flow data. This script requires the following arguments:
- `--directory`: (string) Path to save results.
- `--flows`: (string) Path to the file containing the new flows data (.npy).
- `--dictionary`: (string) Path to the pre-trained dictionary file (.npy).
- `--regularization`: (string) Type of regularization to use ('l1' or 'l2').
- `--lambda_reg`: (float) Regularization parameter.
- `--alpha_steps`: (int) Number of steps for the weight update (default: 100).
- `--learning_rate`: (float) Learning rate for the optimizer (default: 1e-4).
- `--batch_size`: (int) Batch size for testing (default: 32).

As you can see, there is not need to provide the Laplacian or the number of atoms since the dictionary is already learned.
You can run the script as follows (example) with the conda environment activated (env_py2):
```bash
python3 test_dict.py -dir ./results/ -flows ./data/new_ecobici_flows.npy -dict ./results/learned_dictionary.npy -reg l1 -lambda 0.01 -as 100 -lr 0.0001 -bs 32
```
After running the script, the reconstructed flows and weights will be saved in the specified directory in .npy format, along with plots of the loss over epochs and some reconstructed flows as .pdf files. Also, a .txt file with the parameters used during testing will be saved.

## Clustering for learned weights
The `src/learned_weights_clustering/` folder contains the implementation of clustering for the learned weights obtained from the dictionary learning method. In fact, the idea is the same as in the SPK clustering, but now we use the weights as features to cluster the flows. So, the first script `dist_matrix.py` computes the distance matrix using the learned weights. This script requires the following arguments:
- `--directory`: (string) Path to save results.
- `--flows`: (string) Path to the file containing the learned weights data (.npy).
- `--system`: (string) The bikesharing system to use: 'ecobici' or 'mibici' (default: 'ecobici').
- `--indexes`: (string) Indexes of the flows to consider. You can indicates as '[$a_1, a_2, ..., a_n$]' that is uniquely the indexes indicated or 'i[$a_1, a_2$]' that means the range since $a_1$ to $a_2$ (default: 'i[0,10]').

You can run the script as follows (example) with the conda environment activated (env_py1 or env_py2):
```bash
python3 dist_matrix.py -dir ./results/ -flows ./data/learned_weights.npy --system ecobici --indexes i[0,100]
```
After running the script, the distance matrix will be saved in the specified directory in .npy format, as well as a .txt file with the parameters used and a heatmap of the distance matrix as a .pdf file. Also a pdf file with the heatmap of the distance matrix will be saved.

The script `w_aglo_clustering.r` performs agglomerative clustering on the distance matrix. This script requires the same arguments as the previous R script for SPK clustering: 
- `--distance_matrix`: (string) Path to the distance matrix file (.npy format).
- `--names`: (string) Path to the names file of each object to cluster in format .CSV (optional, can contain a 'labels' to color the names in the dendrogram accordingly to a class).
- `--outdir`: (string) Path to save results.
You can run the script as follows (example) with the conda environment activated (env_r):
```bash
Rscript w_aglo_clustering.r -dm ./results/distance_matrix.npy -names ./data/flow_names.csv -odir ./results/
```
This will generate the dendrogram plot saved as a .pdf file in the specified output directory as well as .npy files containing the cluster labels for different numbers of possible clusters.