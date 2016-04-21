#ifndef sim_mechanics_imports_h
#define sim_mechanics_imports_h
 void pmConvertToRotationMatrix(uint32_T rotn, const real_T *in, real_T *out); 
 boolean_T createEngineMechanism(Mechanism *mechanism); 
 void destroyEngineMechanism(Mechanism *mechanism); 
 boolean_T dynamicSfcnOutputMethod(Mechanism *mechanism,SimulationDataGeneral *sdg,SimulationDataOutputs *sdo); 
 const ErrorRecord *getErrorMsg(void); 
 boolean_T eventSfcnOutputMethod(Mechanism *mechanism,SimulationDataGeneral *sdg,SimulationDataOutputs *sdo); 
 boolean_T kinematicSfcnOutputMethod(Mechanism *mechanism,SimulationDataGeneral *sdg,SimulationDataOutputs *sdo); 
 void pmVec(real_T *c,const real_T *a,const real_T *b, int32_T ma, int32_T na, int32_T mb, int32_T nb); 
 void pmMult(real_T *c,const real_T *a,const real_T *b,int32_T ma,int32_T na,int32_T mb,int32_T nb,MatrixType type_a,MatrixType type_b,int32_T flag); 
 void pmMultAndZero(real_T *c,const real_T *a,const real_T *b,int32_T ma,int32_T na,int32_T mb,int32_T nb,MatrixType type_a,MatrixType type_b,int32_T flag); 
 double pmDet3by3(const double *a); 
 void pmVectorFunction(real_T *c, 
 const real_T *a, 
 const real_T *b, 
 real_T x, 
 real_T y, 
 real_T z, 
 size_t a_s, 
 int32_T c_inc, 
 int32_T a_inc, 
 int32_T b_inc); 
 boolean_T sFcnDerivativesMethod(Mechanism *mechanism, real_T *dxdt); 
 boolean_T sFcnProjectionMethod(Mechanism *mechanism,SimulationDataGeneral *sdg); 
 boolean_T sFcnUpdateStateMethod(Mechanism *mechanism, real_T *x); 
 boolean_T zcFunction(real_T **uPtr,Mechanism *mechanism,real_T *zcSignals); 

#endif /* sim_mechanics_imports_h */
