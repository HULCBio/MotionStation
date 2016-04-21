#ifndef mtypes_h
#define mtypes_h
typedef enum EngineDimension_tag { 
 ENGINE_DIMENSION_UNKNOWN = 0, 
 ENGINE_DIMENSION_2 = 1 << 2, 
 ENGINE_DIMENSION_3 = 1 << 3, 
 ENGINE_DIMENSION_SUPPORTED = ENGINE_DIMENSION_2 | ENGINE_DIMENSION_3, 
 ENGINE_DIMENSION_AUTO = ENGINE_DIMENSION_SUPPORTED, 
 ENGINE_DIMENSION_DEFAULT = ENGINE_DIMENSION_AUTO 
} EngineDimension; 
typedef enum MatrixType_tag { 
 UNKNOWMATRIXTYPE, 
 GENERAL, 
 TRANSFER, 
 TRANSFERDERIVED 
} MatrixType; 
typedef enum SideType_tag { 
 UNKNOWN_SIDETYPE, 
 INBOARD, 
 OUTBOARD 
} SideType; 
typedef enum IoType_tag { 
 UNKNOWNIOTYPE, 
 POSE, 
 FORCE, 
 TORQUE, 
 SPATIAL, 
 MASS, 
 INERTIA, 
 MASSINERTIA, 
 POSITION, 
 VELOCITY, 
 EFFECTIVE, 
 ACCELERATION, 
 ANGULARVELOCITY, 
 ANGULARACCELERATION, 
 REACTIONFORCE, 
 REACTIONMOMENT 
} IoType; 
typedef enum JointPrimitiveType_tag { 
 UNKNOWN_PRIMITIVE_TYPE, 
 WELD, 
 REVOLUTE, 
 PRISMATIC, 
 SPHERICAL 
} JointPrimitiveType; 
typedef enum JointType_tag { 
 UNKNOWNJOINTTYPE, 
 SCREW, 
 GENERALJOINT, 
 REVOLUTEREVOLUTE, 
 REVOLUTESPHERICAL, 
 SPHERICALSPHERICAL 
} JointType; 
typedef enum ConstraintType_tag { 
 UNKNOWN_CONSTRAINT, 
 CVCONSTRAINT, 
 GEARCONSTRAINT, 
 SCREWCONSTRAINT, 
 GENERALCONSTRAINT, 
 PARALLELCONSTRAINT, 
 POINTCURVECONSTRAINT, 
 ANGLEDRIVERCONSTRAINT, 
 LINEARDRIVERCONSTRAINT, 
 DISTANCEDRIVERCONSTRAINT, 
 DISASSEMBLEDWELDCONSTRAINT, 
 REVOLUTEREVOLUTECONSTRAINT, 
 REVOLUTESPHERICALCONSTRAINT, 
 SPHERICALSPHERICALCONSTRAINT, 
 DISASSEMBLEDREVOLUTECONSTRAINT, 
 DISASSEMBLEDCYLINDRICCONSTRAINT, 
 DISASSEMBLEDPRISMATICCONSTRAINT, 
 DISASSEMBLEDSPHERICALCONSTRAINT 
} ConstraintType; 
typedef enum constraint_solve_tag { 
 UNKNOWNCONSTRAINTSOLVER, 
 STABILISE, 
 TOLERANCE, 
 COMPLETION 
} ConstraintSolver; 
typedef enum AnalysisType_tag { 
 UNKNOWNANALYSISTYPE, 
 TRIM, 
 DYNAMICS, 
 KINEMATICS, 
 INVERSE_DYNAMICS 
} AnalysisType; 
typedef enum LinearDriverType_tag { 
 UNKNOWNLINEARDRIVERTYPE, 
 XDRIVER, 
 YDRIVER, 
 ZDRIVER 
} LinearDriverType; 
typedef enum DrivenType_tag { 
 UNKNOWNDRIVENTYPE, 
 WAIT, 
 EVENT, 
 MOTION, 
 LOCKED, 
 NOEVENT, 
 PASSIVE, 
 POWERED, 
 FORWARD, 
 REVERSE, 
 UNLOCKED, 
 WAITINGFORWARD, 
 WAITINGREVERSE 
} DrivenType; 
typedef enum TransformType_tag { 
 UNKNOWN_TRANSFORM_TYPE, 
 QUATERNION, 
 MATRIX 
} TransformType; 
typedef struct JointInfo_tag JointInfo; 
typedef struct JointPointer_tag JointPointer; 
typedef struct JointOperator_tag JointOperator; 
typedef struct JointData_tag JointData; 
typedef struct JointInput_tag JointInput; 
typedef struct JointMethods_tag JointMethods; 
typedef struct ConstraintInput_tag ConstraintInput; 
typedef struct ConstraintLocate_tag ConstraintLocate; 
typedef struct ConstraintPointer_tag ConstraintPointer; 
typedef struct ConstraintMethods_tag ConstraintMethods; 
typedef struct ConstraintEquation_tag ConstraintEquation; 
typedef struct MechanismMethods_tag MechanismMethods; 
typedef struct KinematicData_tag KinematicData; 
typedef struct LinearizationData_tag LinearizationData; 
typedef struct BodyData_tag BodyData; 
typedef struct BodyMethods_tag BodyMethods; 
typedef struct CoordinateTransformation_tag CoordinateTransformation; 
typedef struct pmArrayRead_tag { 
 boolean_T iszero; 
 MatrixType type; 
 int32_T n; 
 real_T *real; 
} pmArrayRead; 
typedef struct AxisRead_tag { 
 int32_T n; 
 pmArrayRead **subaxis; 
} AxisRead; 
typedef struct NameArrayRead_tag { 
 int32_T n; 
 JointPrimitiveType *type; 
} NameArrayRead; 
typedef struct IndexArrayRead_tag { 
 int32_T n; 
 int32_T *index; 
} IndexArrayRead; 
typedef int16_T MethodRecord; 
typedef struct Sensor_tag { 
 int32_T n; 
 pmArrayRead**T; 
 real_T *outputScaling; 
 int32_T *primitive; 
 IoType *sensorType; 
 SideType *sensedSide; 
 pmArrayRead **transform2D; 
} Sensor; 
typedef struct BodySensor_tag { 
 int32_T n; 
 IoType *sensorType; 
 pmArrayRead **pos_0; 
 pmArrayRead **T; 
 real_T *outputScaling; 
} BodySensor; 
typedef struct BodyActuator_tag { 
 int32_T n; 
 IoType *actuatorType; 
 pmArrayRead **pos_0; 
 pmArrayRead **force; 
 pmArrayRead **T; 
 pmArrayRead **inputScaling; 
} BodyActuator; 
typedef struct GeneralJointEngine_tag { 
 real_T scale; 
 boolean_T linkAxesForEvents; 
 AxisRead *axis; 
 pmArrayRead *lockTolerance; 
 pmArrayRead *inboardT; 
 pmArrayRead *outboardT; 
 NameArrayRead *primitives; 
 IndexArrayRead *eventList; 
 IndexArrayRead *poweredList; 
 IndexArrayRead *icpoweredList; 
 pmArrayRead *icposition; 
 pmArrayRead *icvelocity; 
 pmArrayRead *inputScaling1; 
 pmArrayRead *inputScaling2; 
 pmArrayRead *inputScaling3; 
 Sensor *sensor; 
} GeneralJointEngine; 
typedef struct ScrewJointEngine_tag { 
 real_T scale; 
 boolean_T event; 
 pmArrayRead *pitch; 
 AxisRead *axis; 
 pmArrayRead *lockTolerance; 
 DrivenType poweredList; 
 DrivenType icpoweredList; 
 pmArrayRead *icposition; 
 pmArrayRead *icvelocity; 
 pmArrayRead *inputScaling1; 
 pmArrayRead *inputScaling2; 
 pmArrayRead *inputScaling3; 
 Sensor *sensor; 
} ScrewJointEngine; 
typedef struct RevoluteRevoluteJointEngine_tag { 
 boolean_T isReversed; 
 real_T scale; 
 pmArrayRead *length; 
 AxisRead *axis; 
 Sensor *sensor; 
} RevoluteRevoluteJointEngine; 
typedef struct RevoluteSphericalJointEngine_tag { 
 boolean_T flip; 
 real_T scale; 
 pmArrayRead *length; 
 AxisRead *axis; 
 pmArrayRead *inboardT; 
 pmArrayRead *outboardT; 
 Sensor *sensor; 
} RevoluteSphericalJointEngine; 
typedef struct SphericalSphericalJointEngine_tag { 
 pmArrayRead *length; 
 real_T scale; 
 pmArrayRead *inboardT; 
 pmArrayRead *outboardT; 
 Sensor *sensor; 
} SphericalSphericalJointEngine; 
typedef struct Joint_tag { 
 MethodRecord *table; 
 boolean_T isReversed; 
 const char *blockName; 
 pmArrayRead *pos_0; 
 pmArrayRead *rel_0; 
 JointType type; 
 void *compile; 
 JointInfo *info; 
 JointData *data; 
 JointInput *input; 
 JointPointer *pointer; 
 JointMethods *methods; 
 JointOperator *algebra; 
 struct Joint_tag *pred; 
} Joint; 
typedef struct BodyEngine_tag { 
 pmArrayRead *J_0; 
 pmArrayRead *pos_0; 
 pmArrayRead *mass; 
 BodySensor *sensor; 
 BodyActuator *input; 
 BodyActuator *massinertia; 
 pmArrayRead *transform2D; 
} BodyEngine; 
typedef struct Body_tag { 
 const char *blockName; 
 BodyData *data; 
 BodyMethods *methods; 
 BodyEngine *compile; 
 struct Body_tag *pred; 
} Body; 
typedef struct GeneralJointEngine_tag GeneralConstraintEngine; 
typedef struct ScrewJointEngine_tag ScrewConstraintEngine; 
typedef struct RevoluteRevoluteJointEngine_tag RevoluteRevoluteConstraintEngine; 
typedef struct RevoluteSphericalJointEngine_tag RevoluteSphericalConstraintEngine; 
typedef struct SphericalSphericalJointEngine_tag SphericalSphericalConstraintEngine; 
typedef struct pmSpline_tag { 
 int32_T nbreaks; 
 int32_T pieces; 
 int32_T dim; 
 boolean_T periodic; 
 real_T *breaks; 
 real_T *Xa, *Xb, *Xc, *Xd; 
 real_T *Ya, *Yb, *Yc, *Yd; 
 real_T *Za, *Zb, *Zc, *Zd; 
} pmSpline; 
typedef struct PointCurveConstraintEngine_tag { 
 boolean_T periodic; 
 boolean_T canExtrapolate; 
 real_T scale; 
 pmArrayRead *T; 
 pmSpline *curve; 
 Sensor *sensor; 
} PointCurveConstraintEngine; 
typedef struct GearConstraintEngine_tag { 
 int32_T nWalk1; 
 int32_T nWalk2; 
 int32_T *sign1; 
 int32_T *sign2; 
 boolean_T foundHolonomicWalkPath; 
 real_T scale; 
 pmArrayRead *radius1; 
 pmArrayRead *radius2; 
 pmArrayRead *axis1; 
 pmArrayRead *axis2; 
 Joint **joint1; 
 Joint **joint2; 
 Sensor *sensor; 
} GearConstraintEngine; 
typedef struct LinearDriverConstraintEngine_tag { 
 boolean_T fixed; 
 real_T scale; 
 Sensor *sensor; 
 LinearDriverType type; 
 pmArrayRead *axis; 
 pmArrayRead *inputScaling1; 
} LinearDriverConstraintEngine; 
typedef struct DistanceDriverConstraintEngine_tag { 
 boolean_T fixed; 
 real_T scale; 
 Sensor *sensor; 
 pmArrayRead *inputScaling1; 
} DistanceDriverConstraintEngine; 
typedef struct AngleDriverConstraintEngine_tag { 
 boolean_T fixed; 
 AxisRead *axis; 
 Sensor *sensor; 
 pmArrayRead *inputScaling1; 
} AngleDriverConstraintEngine; 
typedef struct ParallelConstraintEngine_tag { 
 AxisRead *axis; 
 Sensor *sensor; 
} ParallelConstraintEngine; 
typedef struct CVConstraintEngine_tag { 
 boolean_T fixed; 
 boolean_T linearBaseAxisFixedOnBody; 
 boolean_T angularBaseAxisFixedOnBody; 
 boolean_T linearFollowerAxisFixedOnBody; 
 boolean_T angularFollowerAxisFixedOnBody; 
 AxisRead *axis; 
 Sensor *sensor; 
 pmArrayRead *inputScaling1; 
} CVConstraintEngine; 
typedef struct DisassembledConstraintEngine_tag { 
 AxisRead *axis; 
 real_T scale; 
} DisassembledConstraintEngine; 
typedef struct DisassembledConstraintEngine_tag DisassembledPrismaticConstraintEngine; 
typedef struct DisassembledConstraintEngine_tag DisassembledCylindricConstraintEngine; 
typedef struct DisassembledConstraintEngine_tag DisassembledRevoluteConstraintEngine; 
typedef struct DisassembledConstraintEngine_tag DisassembledWeldConstraintEngine; 
typedef struct DisassembledSphericalConstraintEngine_tag { 
 real_T scale; 
} DisassembledSphericalConstraintEngine; 
typedef struct Constraint_tag { 
 MethodRecord *table; 
 Joint *joint1; 
 Joint *joint2; 
 pmArrayRead *pos1_0; 
 pmArrayRead *pos2_0; 
 const char *blockName; 
 void *data; 
 ConstraintType type; 
 void *compile; 
 ConstraintInput *input; 
 ConstraintLocate *locate; 
 ConstraintMethods *methods; 
 ConstraintEquation *equation; 
} Constraint; 
typedef struct Branch_tag { 
 int32_T njoints; 
 Body **body; 
 Joint **joint; 
 struct Branch_tag *pred; 
} Branch; 
typedef struct Connect_tag { 
 int32_T n; 
 Branch **branch; 
} Connect; 
typedef struct Recursion_tag { 
 int32_T nLeafBranches; 
 int32_T nTrunkBranches; 
 Branch **leaf; 
 Branch **trunk; 
 Connect **trunkConnectors; 
} Recursion; 
typedef struct MachineData_tag { 
 int32_T numModes; 
 int32_T numZcFunctions; 
 int32_T numBlock1States; 
 int32_T numBlock1Inputs; 
 int32_T numBlock1Outputs; 
 int32_T numBlock2Inputs; 
 int32_T numBlock2Outputs; 
 int32_T numBlock3Inputs; 
 boolean_T haveEvents; 
 boolean_T haveForceSensors; 
 boolean_T haveMotionDrivers; 
 boolean_T haveVelocitySensors; 
 boolean_T detectSingularities; 
 boolean_T haveAccelerationSensors; 
 boolean_T haveEffectiveForceSensors; 
 boolean_T haveConstraintForceSensors; 
 real_T rTol; 
 real_T aTol; 
 real_T sqrtEps; 
 real_T linearAssemblyTolerance; 
 real_T angularAssemblyTolerance; 
 const char *system; 
 void *machine; 
 pmArrayRead *gravity; 
 Recursion *recurse; 
 AnalysisType mode; 
 ConstraintSolver solve; 
 boolean_T linFixedPerturbation; 
 real_T linPerturbationSize; 
} MachineData; 
typedef enum SimulationEvent_tag { 
 MECH_INVALID = -1, 
 MECH_PAUSE, 
 MECH_CONTINUE 
} SimulationEvent; 
typedef struct VisData_tag { 
 boolean_T enabled; 
 boolean_T (*drawMethod)(const struct VisData_tag *); 
 int32_T modelId; 
 int32_T machineId; 
 TransformType transformType; 
 real_T **q; 
 real_T **p; 
 boolean_T (*changeStatusMethod)(const struct VisData_tag *, SimulationEvent); 
} VisData; 
typedef struct MemManager_tag { 
 void *(*calloc_fn)(size_t, size_t); 
 void (*free_fn) (void *); 
} MemManager; 
typedef struct ErrorRecord_tag { 
 const char_T *errorMsg; 
 const char_T *blocks[(5)]; 
 boolean_T errorFlag; 
} ErrorRecord; 
typedef struct WarningFlags_tag { 
 boolean_T warnOnRedundantConstraints; 
 boolean_T warnOnUnstableNumberOfConstraints; 
} WarningFlags; 
typedef struct Mechanism_tag { 
 int32_T nbranches; 
 int32_T nconstraints; 
 boolean_T engineData; 
 ErrorRecord * engineError; 
 boolean_T generatingCode; 
 void (* destroyEngine)(struct Mechanism_tag *); 
 real_T time; 
 boolean_T isMajorTimeStep; 
 real_T * state; 
 MethodRecord * table; 
 MechanismMethods * methods; 
 Branch ** branch; 
 Constraint ** constraint; 
 MachineData * data; 
 KinematicData * kdata; 
 LinearizationData * ldata; 
 uint32_T nruntimeData; 
 real_T * runtimeData; 
 EngineDimension allowedSimulationDimensions; 
 boolean_T echoSimulationDimension; 
 CoordinateTransformation * coordTransform; 
 pmArrayRead * transform2D; 
 WarningFlags * warningFlags; 
 boolean_T (*mapRuntimeData)(struct Mechanism_tag *, const real_T *, char_T *, uint32_T); 
 void (*errorFcn) (struct Mechanism_tag *); 
} Mechanism; 

#endif /* mtypes_h */
