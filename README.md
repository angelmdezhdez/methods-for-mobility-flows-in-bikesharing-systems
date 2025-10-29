# Methods for mobility flows in bikesharing systems 🚴‍♂️💻
In this repository, we provide code that I used in my master's thesis to analyze mobility flows in bikesharing systems. The study case focuses on the bikesharing system in Mexico City (Ecobici) and Guadalajara (MiBici).
The code was written in Python and R programming languages. 
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) ![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)

## Repository structure
The repository is structured as follows:
- `envs/`: Contains the conda environment files for setting up the required dependencies.
- `src/`: Contains the folders with the code for methods implemented in the thesis.
  - `spk_flows_clustering/`: Code for clustering mobility flows using the Shortest Path Kernel (SPK) method for flows.
  - `dictionary_learning/`: Code for learning the dictionary and the weights of the flows using dictionary learning.
  - `learned_weights_clustering/`: Code for clustering the learned weights of the flows.