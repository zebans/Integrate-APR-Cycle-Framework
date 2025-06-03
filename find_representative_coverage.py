import glob
import numpy as np
import sys
import os

def find_coverage_intersection(project_name, project_id):
    directory = f"/home/ncyu/MyProject/Buggy/{project_name}/{project_name}_{project_id}_buggy/sfl/txt"
    txt_files = glob.glob(f"{directory}/FTC/topk_FTC_coverage.txt")
    
    coverage_arrays = []

    for file in txt_files:
        with open(file, 'r') as f:
            # 讀取數據並轉換成數組
            coverage = np.array([int(x) for x in f.readline().split() if x in {'0', '1'}])
            coverage_arrays.append(coverage)

    if not coverage_arrays:
        return []
        
    if len(coverage_arrays) == 1:
        return coverage_arrays[0].tolist()


    # 計算 coverage 交集（所有數組中共同為 1 的部分）
    intersection = np.logical_and.reduce(coverage_arrays).astype(int)

    return intersection.tolist()

# 從命令列讀取參數
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python find_representative_coverage.py <Project_name> <Project_id>")
        sys.exit(1)

    project_name = sys.argv[1]
    project_id = sys.argv[2]

    coverage_intersection = find_coverage_intersection(project_name, project_id)
#    print("Coverage Intersection Indices:", sorted(coverage_intersection))
    print("Coverage Intersection Vector: ")
    print(" ".join(map(str, coverage_intersection)))
    
    output_file = f"/home/ncyu/MyProject/Buggy/{project_name}/{project_name}_{project_id}_buggy/sfl/txt/repesentative_coverage.txt"
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    with open(output_file, "w") as f:
        f.write(" ".join(map(str, coverage_intersection)) + "\n")
    
    
    
    
    
    
    
    
