#include <cstdio>
#include <cuda.h>
#include "cuda-samples/Common/helper_cuda.h"

#include "1_Gpu_Information.cuh"
#include "2_Analyze_SM.cuh"

#define MAX_LINE_LENGTH 1024

int main(int argCount, char *argVariables[]) {
    // argVariables[0] is the command.
    if (argCount >= 2) {
        if (argCount >= 3) {
            for (int i = 2; i < argCount; i++) {
                char *arg = argVariables[i];
                if (strcmp(arg, "-help") == 0) {
                    // Lists all available parameters.
                    printf("Here is a list of all available parameters:\n");
                    printf("-help Lists all available parameters.\n");
                    printf("-info Creates a file with all available information of the GPU.\n");
                    printf("-random Creates a Benchmark of random cores of the GPU.\n");
                } else if (strcmp(arg, "-info") == 0) {
                    // Creates a file with all available information of the GPU.
                    char *ptr;
                    int gpuId = strtol(argVariables[1], &ptr, 10);
                    GpuInformation info = getGpuInformation(gpuId);
                    createInfoFile(info);
                    printf("The file with all available information of the GPU was created.\n");
                } else if (strcmp(arg, "-random") == 0) {
                    // Creates a Benchmark of random cores of the GPU.
                    performRandomCoreBenchmark();
                    printf("The Benchmark of random cores of the GPU was created.\n");
                }
            }
        } else {
            printf("No parameters were given. Therefore gcPve won't do anything.\n");
            printf("To get a list of all available parameters use the parameter -help.\n");
        }
    } else {
        printf("Please select the GPU for which the benchmarks should be created.\n");
        printf("To do so, use the following syntax (here for GPU 0): \"gcPve 0\"");
        printf("To get a list of all available GPUs use the command \"nvidia-smi -L\".\n");
    }
}


/*
int cvtCharArrToInt(char* start) {
    char* cvtPtr;
    int num = strtol(start, &cvtPtr, 10);
    if (start == cvtPtr) {
        fprintf(out, "Char* is not an Int - Conversion failed!\n");
        return 0;
    } else if (*cvtPtr != '\0') {
        fprintf(out, "Non-Int rest in Char* after Conversion - Conversion Warning!\n");
        fprintf(out, "Rest char* starts with character with ascii value: %d\n", int(cvtPtr[0]));
    } else if (errno != 0 && num == 0) {
        fprintf(out, "Conversion failed!\n");
        return 0;
    }
    return num;
}

int parseCoreLine(char* line) {
    char *ptr = strstr(line, "MP");
    if (ptr == nullptr) {
        fprintf(out, "Output has unknown format!\n");
        return 0;
    }
    ptr = ptr + strlen("MP");
    if (strlen(ptr) < 10 || ptr[0] != ':' || ptr[1] != ' ' ||  ptr[2] != ' ' ||  ptr[3] != ' ' ||
        ptr[4] != ' ' || ptr[5] != ' ') {
        fprintf(out, "Output has unknown format!\n");
        return 0;
    }
    ptr = ptr + 6;
    char* start = ptr;
    while(isdigit(ptr[0])) {
        ++ptr;
    }
    ptr[0] = '\0';
    return cvtCharArrToInt(start);
}

int getCoreNumber(char* cmd) {
    printf("Execute command to get number of cores: %s\n", cmd);
    if (strstr(cmd, "nvidia-settings") != nullptr && strstr(cmd, "deviceQuery") != nullptr)  {
        printf("Nvidia-settings or deviceQuery not in command!\n");
        return 0;
    }
    FILE *p;
    p = popen(cmd, "r");
    if (p == nullptr) {
        printf("Could not execute command %s!\n", cmd);
    }

    int totalNumOfCores;
    if (strstr(cmd, "deviceQuery") != nullptr) {
        printf("Using deviceQuery option for number of cores\n");
        char line[MAX_LINE_LENGTH] = {0};

        while (fgets(line, MAX_LINE_LENGTH, p)) {
            if (strstr(line, "core") || strstr(line, "Core")) {
                totalNumOfCores = parseCoreLine(line);
                break;
            }
        }
    } else {
        printf("Using nvidia-settings option for number of cores\n");
        char num[16] = {0};
        fgets(num, 16, p);
        totalNumOfCores = cvtCharArrToInt(num);
    }
    pclose(p);
    return totalNumOfCores;
}

CudaDeviceInfo getDeviceProperties(char* nviCoreCmd, int coreSwitch, int deviceID) {
    CudaDeviceInfo info;
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);
    cudaDeviceProp deviceProp{};
    if (deviceID >= deviceCount) {
        deviceID = 0;
    }
    cudaGetDeviceProperties(&deviceProp, deviceID);
    strcpy(info.GPUname, deviceProp.name);
    info.cudaVersion = (float)deviceProp.major + (float)((float)deviceProp.minor / 10.);
    info.sharedMemPerThreadBlock = deviceProp.sharedMemPerBlock;
    info.sharedMemPerSM = deviceProp.sharedMemPerMultiprocessor;
    info.numberOfSMs = deviceProp.multiProcessorCount;
    info.registersPerThreadBlock = deviceProp.regsPerBlock;
    info.registersPerSM = deviceProp.regsPerMultiprocessor;
    info.cudaMaxGlobalMem = deviceProp.totalGlobalMem;
    info.cudaMaxConstMem = deviceProp.totalConstMem;
    info.L2CacheSize = deviceProp.l2CacheSize;
    info.memClockRate = deviceProp.memoryClockRate;
    info.memBusWidth = deviceProp.memoryBusWidth;
    info.GPUClockRate = deviceProp.clockRate;
    info.maxThreadsPerBlock = deviceProp.maxThreadsPerBlock;
    if (coreSwitch == 0) {
        printf("Using helper_cuda option for number of cores\n");
        info.numberOfCores = _ConvertSMVer2Cores(deviceProp.major, deviceProp.minor) * info.numberOfSMs;
    } else {
        info.numberOfCores = getCoreNumber(nviCoreCmd);
    }
    return info;
}

void createOutputFile(CudaDeviceInfo cardInformation) {
    printf("Create the output file...\n");
    char output[] = "Output.csv";
    FILE *csv = fopen(output, "w");
    if (csv == nullptr) {
        printf("[WARNING]: Cannot open output file for writing.\n");
        csv = stdout;
    }
    fprintf(csv, "GPU_vendor; \"%s\"; ", "Nvidia");
    fprintf(csv, "GPU_name; \"%s\"; ", cardInformation.GPUname);
    fprintf(csv, "CUDA_compute_capability; \"%.2f\"; ", cardInformation.cudaVersion);
    fprintf(csv, "Number_of_streaming_multiprocessors; %d; ", cardInformation.numberOfSMs);
    fprintf(csv, "Number_of_cores_in_GPU; %d; ", cardInformation.numberOfCores);
    fprintf(csv, "Number_of_cores_per_SM; %d; ", cardInformation.numberOfCores / cardInformation.numberOfSMs);
    fprintf(csv, "Registers_per_thread_block; %d; \"32-bit registers\"; ", cardInformation.registersPerThreadBlock);
    fprintf(csv, "Registers_per_SM; %d; \"32-bit registers\"; ", cardInformation.registersPerSM);
    fclose(csv);
}
*/


