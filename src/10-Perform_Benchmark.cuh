#ifndef GCPVE_10_PERFORM_BENCHMARK_CUH
#define GCPVE_10_PERFORM_BENCHMARK_CUH

#include <vector>

#include "01-Gpu_Information.cuh"
#include "02-Benchmark_Properties.cuh"
#include "03-Info_Prop_Derivatives.cuh"
#include "04-Core_Characteristics.cuh"
#include "05-Data_Collection.cuh"

/**
 *
 * @param info
 * @param prop
 * @param derivatives
 */
void performBenchmark1(GpuInformation info, BenchmarkProperties prop, InfoPropDerivatives derivatives) {

    // Declare all core characteristics.
    std::vector<coreCharacteristics> gpuCores (gpuInfo.totalNumberOfCores);
    for (unsigned int i = 0; i < gpuInfo.multiProcessorCount; i++) {
        for (unsigned int j = 0; j < gpuInfo.warpCoresPerSm; j++) {
            for (unsigned int k = 0; k < gpuInfo.warpSize; k++) {
                unsigned int gpuCore = (i * gpuInfo.numberOfCoresPerSm) + (j * gpuInfo.warpSize) + k;
                gpuCores[gpuCore] = new CoreCharacteristics(i, j ,k);
            }
        }
    }

    // Multiprocessor: deterministic mapping
    // HardwareWarp: random mapping
    // WarpCore: deterministic mapping

    // Perform the benchmark loop.
    for (unsigned int iteration; iteration < numberOfIterations; iteration++) {
        unsigned int dataSize;
        if (gpuInfo.totalGlobalMem > sizeof(LargeDataCollection)) {
            LargeDataCollection data;
            dataSize = large;
        } else if (gpuInfo.totalGlobalMem > sizeof(MediumDataCollection)) {
            MediumDataCollection data;
            dataSize = medium;
        } else {
            SmallDataCollection data;
            dataSize = small;
        }


    }

}

#endif //GCPVE_10_PERFORM_BENCHMARK_CUH

