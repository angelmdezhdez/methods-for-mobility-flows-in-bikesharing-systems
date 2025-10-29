# libraries
import os
import time
import multiprocessing
import sys
import numpy as np
import argparse
import matplotlib.pyplot as plt
sys.stdout.flush()

#############################################################################
# Distance matrix 
#############################################################################

def compute_matrix(data, dist_function = np.linalg.norm):
    n = len(data)
    D = np.zeros((n,n))
    for i in range(n):
        for j in range(i,n):
            D[i,j] = dist_function(data[i] - data[j])
            D[j,i] = D[i,j]
    return D

################################################################################
# Main
################################################################################

if __name__ == "__main__":
    multiprocessing.set_start_method("fork")
    # python3 dist_matrix.py -dir test -flows data_mibici_2018_4/flows.npy -sys mibici -ind 'i[2,12]'
    parser = argparse.ArgumentParser(description="SP Kernel Matrix")
    parser.add_argument('-dir', '--directory', type=str, default=None, help='Directory to save results', required=False)
    parser.add_argument('-flows', '--flows', type=str, default=None, help='Path to flows file', required=True)
    parser.add_argument('-sys', '--system', type=str, default='ecobici', help='System to use (ecobici or mibici)', required=False)
    parser.add_argument('-ind', '--indexes', type=str, default='i[0,10]', help='Indexes to use', required=False)
    parser.add_argument('-trips', '--total_trips', type=str, default=None, help='Path to total trips file', required=False)
    args = parser.parse_args()

    # arguments
    directory = args.directory
    flows_path = args.flows
    trips_path = args.total_trips
    system = args.system

    if args.indexes[0] == 'i':
        indexes = [i for i in range(int(args.indexes[2:-1].split(',')[0]), int(args.indexes[2:-1].split(',')[1])+1)]
    else:
        indexes = [int(x) for x in args.indexes[1:-1].split(',')]

    flows = np.load(flows_path, allow_pickle=True)
    total_trips = np.load(trips_path, allow_pickle=True)

    flows_ = flows[indexes]
    total_trips = total_trips[indexes]

    flows = []

    for i in range(len(flows_)):
        flow = flows_[i]
        t = total_trips[i]
        flows.append(t*flow)

    flows = np.array(flows)

    # kernel matrix
    print('\n\nComputing kernel matrix')
    sys.stdout.flush()
    start_time = time.time()

    D = compute_matrix(flows)

    print(f"Kernel matrix completed")
    sys.stdout.flush()
    elapsed_time = time.time() - start_time
    print(f'Kernel matrix computed in {elapsed_time:.2f} seconds')
    sys.stdout.flush()

    if os.path.exists(directory):
        np.save(os.path.join(directory, 'distance_matrix.npy'), D)
        with open(os.path.join(directory, 'dist_params.txt'), 'w') as f:
            f.write(f'system: {system}\n')
            f.write(f'flows dir: {flows_path}\n')
            f.write(f'indexes: {indexes}\n')
            f.write(f'time: {elapsed_time/60:.2f} minutes\n')
        plt.figure(figsize=(10, 8))
        plt.imshow(D, cmap='viridis', interpolation='nearest')
        plt.colorbar()
        plt.title('Distance Matrix Heatmap')
        plt.savefig(os.path.join(directory, 'distance_matrix.pdf'))
        plt.close()
    else:
        os.makedirs(directory)
        np.save(os.path.join(directory, 'distance_matrix.npy'), D)
        with open(os.path.join(directory, 'dm_params.txt'), 'w') as f:
            f.write(f'system: {system}\n')
            f.write(f'flows dir: {flows_path}\n')
            f.write(f'indexes: {indexes}\n')
            f.write(f'time: {elapsed_time/60:.2f} minutes\n')
        plt.figure(figsize=(10, 8))
        plt.imshow(D, cmap='viridis', interpolation='nearest')
        plt.colorbar()
        plt.title('Distance Matrix Heatmap')
        plt.savefig(os.path.join(directory, 'distance_matrix.png'))
        plt.close()