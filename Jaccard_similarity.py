import numpy as np
import sys
import os

def jaccard_similarity(arr1, arr2):
    """ 計算 Jaccard 相似度 """
    intersection = np.logical_and(arr1, arr2).sum()
    union = np.logical_or(arr1, arr2).sum()
    return intersection / union if union != 0 else 0

def compute_similarity():
    # 讀取 intersection_coverage_output.txt 作為基準
    with open(baseline_coverage_file, "r") as f:
        base_coverage = np.array([int(x) for x in f.readline().split()])

    # 讀取 testcase_coverage
    with open(testcase_coverage_file, "r") as f:
        lines = f.readlines()

    result = []

    for line in lines:
        # 假設每行有三筆資料，忽略最後一個 "+/-" 符號
        coverage = np.array([int(x) for x in line.split()[:-1]])  # 去除最後一個 "+"
        
        if len(base_coverage) != len(coverage):
             return ValueError("Baseline coverage and Testcase coverage length not same!")
        
        similarity = jaccard_similarity(base_coverage, coverage)

        result.append(f"Similarity: {similarity:.4f}")

    # 輸出結果到 coverage_similarity_results.txt
    if test_result_index == "FTC":
        with open("FTC_coverage_similarity_results.txt", "w") as f:
             f.write("\n".join(result) + "\n")
        print("✅ Jaccard 相似度計算完成，結果已寫入 FTC_coverage_similarity_results.txt")
    elif test_result_index == "PTC":
        with open("PTC_coverage_similarity_results.txt", "w") as f:
             f.write("\n".join(result) + "\n")
        print("✅ Jaccard 相似度計算完成，結果已寫入 PTC_coverage_similarity_results.txt")
    else:
        print("❌ Incorrect Index Symbol! Only PTC/FTC. tks")

    

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python similarity.py <Project_name> <Project_id> <file_name> <file_name> <PTC/FTC>")
        print("Example: python similarity.py <chart> <1> <repesentatvie_coverage.txt> <FTC_coverage_file> <PTC/FTC>")
        sys.exit(1)
        
    project_name = sys.argv[1]
    project_id = sys.argv[2]
    baseline_coverage_file = sys.argv[3]    
    testcase_coverage_file = sys.argv[4]
    test_result_index = sys.argv[5]
        
    compute_similarity()

