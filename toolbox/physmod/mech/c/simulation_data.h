#ifndef simulation_data_h
#define simulation_data_h
typedef struct SimulationDataGeneral_tag { 
 real_T time; 
 real_T tStart; 
 int32_T *iwork; 
 uint32_T numInputPorts; 
 real_T **inputSignals[6]; 
 int32_T *modeVector; 
 uint32_T cacheNeedsReset; 
} SimulationDataGeneral; 
typedef struct SimulationDataOutputs_tag { 
 boolean_T outputTimesOnly; 
 int32_T numOutputTimes; 
 int32_T outputTimesIndex; 
 real_T nextOutputTime; 
 boolean_T majorTimestep; 
 boolean_T consistencyChecking; 
 uint32_T numOutputPorts; 
 real_T *outputSignals[6]; 
} SimulationDataOutputs; 

#endif /* simulation_data_h */
