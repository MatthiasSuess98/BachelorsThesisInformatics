#ifndef GCPVE_10_PERFORM_BENCHMARK_CUH
#define GCPVE_10_PERFORM_BENCHMARK_CUH

#include <vector>

#include "01-Gpu_Information.cuh"
#include "02-Benchmark_Properties.cuh"
#include "03-Info_Prop_Derivatives.cuh"
#include "04-Core_Characteristics.cuh"
#include "05-Data_Collection.cuh"
#include "20-L1_Cache_Launcher.cuh"




/*
void performSmallBenchmark(GpuInformation info, BenchmarkProperties prop, InfoPropDerivatives derivatives) {

    // Initialize data collection.
    SmallDataCollection data;

    // Declare and initialize all core characteristics.
    std::vector<CoreCharacteristics> gpuCores;
    CoreCharacteristics gpuCore = CoreCharacteristics(0, 0, 0);
    for (int i = 0; i < info.multiProcessorCount; i++) {
        for (int j = 0; j < derivatives.hardwareWarpsPerSm; j++) {
            for (int k = 0; k < info.warpSize; k++) {
                gpuCore = CoreCharacteristics(i, j, k);
                gpuCores.push_back(gpuCore);
            }
        }
    }

    // Perform the benchmark loop.
    int hardwareWarpScore;
    int smallestNumber;
    int bestHardwareWarp;
    long double currentTime;
    std::vector<int> dontFits;
    int dontFit;
    for (int warpLoop = 0; warpLoop < info.warpSize; warpLoop++) {
        dontFit = 0;
        dontFits.push_back(dontFit);
    }
    for (int trailLoop = 0; trailLoop < prop.numberOfTrialsPerform; trailLoop++) {
        for (int resetLoop = 0; resetLoop < prop.small; resetLoop++) {
            data.mulp[resetLoop] = 0;
            data.warp[resetLoop] = 0;
            data.lane[resetLoop] = 0;
            data.time[resetLoop] = 0;
        }
        data = performSmallL1Benchmark(info, prop, derivatives);
        for (int blockLoop = 0; blockLoop < prop.small; blockLoop = blockLoop + info.warpSize) {
            if (data.time[blockLoop] != 0) {
                hardwareWarpScore = 0;
                for (int hardwareWarpLoop = 0; hardwareWarpLoop < derivatives.hardwareWarpsPerSm; hardwareWarpLoop++) {
                    dontFits[hardwareWarpLoop] = 0;
                }
                for (int hardwareWarpLoop = 0; hardwareWarpLoop < derivatives.hardwareWarpsPerSm; hardwareWarpLoop++) {
                    if (gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (hardwareWarpLoop * info.warpSize)].getTypicalL1Time() != 0.0) {
                        hardwareWarpScore++;
                    }
                }
                if (hardwareWarpScore == 0) {
                    for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                        gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + laneLoop].setTypicalL1Time(((long double) data.time[blockLoop + laneLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor)));
                    }
                } else if (hardwareWarpScore == derivatives.hardwareWarpsPerSm) {
                    for (int hardwareWarpLoop = 0; hardwareWarpLoop < derivatives.hardwareWarpsPerSm; hardwareWarpLoop++) {
                        for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                            if (std::abs(gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (hardwareWarpLoop * info.warpSize) + laneLoop].getTypicalL1Time() - (((long double) data.time[blockLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor)))) >= prop.maxDelta) {
                                dontFits[hardwareWarpLoop]++;
                            }
                        }
                    }
                    smallestNumber = 0;
                    bestHardwareWarp = 0;
                    for (int hardwareWarpLoop = 0; hardwareWarpLoop < derivatives.hardwareWarpsPerSm; hardwareWarpLoop++) {
                        if (hardwareWarpLoop == 0) {
                            smallestNumber = dontFits[hardwareWarpLoop];
                        } else {
                            if (smallestNumber > dontFits[hardwareWarpLoop]) {
                                smallestNumber = dontFits[hardwareWarpLoop];
                            }
                        }
                    }
                    for (int hardwareWarpLoop = 0; hardwareWarpLoop < derivatives.hardwareWarpsPerSm; hardwareWarpLoop++) {
                        if (smallestNumber == dontFits[hardwareWarpLoop]) {
                            bestHardwareWarp = hardwareWarpLoop;
                        }
                    }
                    for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                        currentTime = gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (bestHardwareWarp * info.warpSize) + laneLoop].getTypicalL1Time();
                        gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (bestHardwareWarp * info.warpSize) + laneLoop].setTypicalL1Time(((((long double) data.time[blockLoop + laneLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor))) + currentTime) / 2);
                    }
                } else {
                    for (int hardwareWarpLoop = 0; hardwareWarpLoop < hardwareWarpScore; hardwareWarpLoop++) {
                        for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                            if (std::abs(gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (hardwareWarpLoop * info.warpSize) + laneLoop].getTypicalL1Time() - (((long double) data.time[blockLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor)))) >= prop.maxDelta) {
                                dontFits[hardwareWarpLoop]++;
                            }
                        }
                    }
                    smallestNumber = 0;
                    bestHardwareWarp = 0;
                    for (int hardwareWarpLoop = 0; hardwareWarpLoop < hardwareWarpScore; hardwareWarpLoop++) {
                        if (hardwareWarpLoop == 0) {
                            smallestNumber = dontFits[hardwareWarpLoop];
                        } else {
                            if (smallestNumber > dontFits[hardwareWarpLoop]) {
                                smallestNumber = dontFits[hardwareWarpLoop];
                            }
                        }
                    }
                    for (int hardwareWarpLoop = 0; hardwareWarpLoop < hardwareWarpScore; hardwareWarpLoop++) {
                        if (smallestNumber == dontFits[hardwareWarpLoop]) {
                            bestHardwareWarp = hardwareWarpLoop;
                        }
                    }
                    if (dontFits[bestHardwareWarp] > prop.maxDontFit) {
                        for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                            gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (hardwareWarpScore * info.warpSize) + laneLoop].setTypicalL1Time(((long double) data.time[blockLoop + laneLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor)));
                        }
                    } else {
                        for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                            currentTime = gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (bestHardwareWarp * info.warpSize) + laneLoop].getTypicalL1Time();
                            gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (bestHardwareWarp * info.warpSize) + laneLoop].setTypicalL1Time(((((long double) data.time[blockLoop + laneLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor))) + currentTime) / 2);
                        }
                    }
                }
            }
        }
    }

    // Create file with all benchmark data.
    char output[] = "raw/Benchmark_L1.csv";
    FILE *csv = fopen(output, "w");
    for (int i = 0; i < info.multiProcessorCount; i++) {
        for (int j = 0; j < derivatives.hardwareWarpsPerSm; j++) {
            for (int k = 0; k < info.warpSize; k++) {
                fprintf(csv, "%Lf", gpuCores[(i * derivatives.hardwareWarpsPerSm * info.warpSize) + (j * info.warpSize) + k].getTypicalL1Time());
                fprintf(csv, " ; ");
            }
            fprintf(csv, "\n");
        }
        fprintf(csv, "\n");
    }
    fclose(csv);
    printf("[INFO] The L1 cache benchmark file was created.\n");
}

*/




/**
 * Performs the small benchmark.
 * @param info All available information of the current GPU.
 * @param prop All properties of the benchmarks.
 * @param derivatives All derivatives of info and prop.
 */
void performSmallBenchmark(GpuInformation info, BenchmarkProperties prop, InfoPropDerivatives derivatives) {

    // Initialize data collection.
    SmallDataCollection data;

    // Declare and initialize all core characteristics.
    std::vector<CoreCharacteristics> gpuCores;
    CoreCharacteristics gpuCore = CoreCharacteristics(0, 0, 0);
    for (int i = 0; i < info.multiProcessorCount; i++) {
        for (int j = 0; j < derivatives.hardwareWarpsPerSm; j++) {
            for (int k = 0; k < info.warpSize; k++) {
                gpuCore = CoreCharacteristics(i, j, k);
                gpuCores.push_back(gpuCore);
            }
        }
    }

    // Perform the benchmark loop.
    long double currentTime;
    for (int trailLoop = 0; trailLoop < prop.numberOfTrialsPerform; trailLoop++) {
        for (int resetLoop = 0; resetLoop < prop.small; resetLoop++) {
            data.mulp[resetLoop] = 0;
            data.warp[resetLoop] = 0;
            data.lane[resetLoop] = 0;
            data.time[resetLoop] = 0;
        }
        data = performSmallL1Benchmark(info, prop, derivatives);
        for (int blockLoop = 0; blockLoop < prop.small; blockLoop = blockLoop + info.warpSize) {
            if (data.time[blockLoop] != 0) {
                if (gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (data.warp[blockLoop] * info.warpSize) + data.lane[blockLoop]].getTypicalL1Time() == 0) {
                    for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                        gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (data.warp[blockLoop] * info.warpSize) + laneLoop].setTypicalL1Time(((long double) data.time[blockLoop + laneLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor)));
                    }
                } else {
                    for (int laneLoop = 0; laneLoop < info.warpSize; laneLoop++) {
                        currentTime = gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (data.warp[blockLoop] * info.warpSize) + laneLoop].getTypicalL1Time();
                        gpuCores[(data.mulp[blockLoop] * derivatives.hardwareWarpsPerSm * info.warpSize) + (data.warp[blockLoop] * info.warpSize) + laneLoop].setTypicalL1Time(((((long double) data.time[blockLoop + laneLoop]) / ((long double) (derivatives.smallNumberOfTrialsDivisor * derivatives.smallNumberOfTrialsDivisor))) + currentTime) / 2);
                    }
                }
            }
        }
    }

    // Create file with all benchmark data.
    char output[] = "raw/Benchmark_L1.csv";
    FILE *csv = fopen(output, "w");
    for (int i = 0; i < info.multiProcessorCount; i++) {
        for (int j = 0; j < derivatives.hardwareWarpsPerSm; j++) {
            for (int k = 0; k < info.warpSize; k++) {
                fprintf(csv, "%Lf", gpuCores[(i * derivatives.hardwareWarpsPerSm * info.warpSize) + (j * info.warpSize) + k].getTypicalL1Time());
                fprintf(csv, " ; ");
            }
            fprintf(csv, "\n");
        }
        fprintf(csv, "\n");
    }
    fclose(csv);
    printf("[INFO] The L1 cache benchmark file was created.\n");
}

#endif //GCPVE_10_PERFORM_BENCHMARK_CUH

//FINISHED

