% SimPowerSystems Demos
%
% General Demos library
%   power_filter        - Steady-state operation of linear circuit filter
%   power_transient     - Transient analysis of a linear circuit
%   power_transfo       - Three-winding distribution transformer
%   power_transfosat    - Energization of a three-phase Saturable Transformer
%   power_surgnetwork   - AC network Surge Arrester
%   power_rectifier     - Three-phase diode rectifier
%   power_converter     - Thyristor Converter
%   power_switching     - Ideal Switch in switching circuit
%   power_mosconv       - Mosfet converter
%   power_buckconv      - Gto Thyristor in buck converter topology
%   power_loadshed      - Load shedding on a simplified alternator
%   power_turbine       - Synchronous generator powered by hydraulic turbine
%   power_pwm           - Asynchronous machine fed by PWM inverter
%   power_pmmotor       - PM synchronous motor fed by PWM inverter
%   power_triphaseline  - Single phase energization of a three-phase line
%   power_monophaseline - Switching of a single phase line
%   power_machines      - Machines and load flow
%
% Case studies demonstration files
%   power_3phseriescomp - Case study 1 Series compensated network
%   power_dcdrive       - Case study 2 Chopper fed DC motor drive
%   power_regulator     - Case study 3 Synchronous machine and regulator
%   power_acdrive       - Case study 4 Variable frequency induction motor drive
%   power_hvdc12pulse   - Case study 5 HVDC transmission system
%
% Utility functions for demos
%   power_filterbode    - Used by power_filter demo
%   power_fft_scope     - Compute and display spectrum of a fixed-step signal in Structure with Time format
%   etazline            - Compute the equivalent PI model of a transmission line
%   triphazicon         - Used by powerlib_extras library
%
% Utility functions for Case Study 3
%   power_regulinit     - Initialization function
%   power_regulset      - Initialization function  
%   power_reguldelta    - Initialization function  
%   power_regulzero     - Initialization function     
%   power_regul_init    - MAT file for fast steady-state initialization 
%
% Demo examples used in the reference documentation
%   power_accurrent      - AC current source
%   power_acvoltage      - AC voltage source
%   power_arrester       - Surge arrester
%   power_breaker        - Breaker
%   power_busbar         - Bus Bar
%   power_circ2ss_psb    - power_statespace command
%   power_circ2ss_slk    - power_statespace command
%   power_controlcurr    - Controlled current source 
%   power_controlvolt    - Controlled voltage source
%   power_currmeasure    - Current measurement
%   power_dcmotor        - DC motor (powerlib_extras)
%   power_dcvoltage      - DC voltage source
%   power_diode          - Diode
%   power_distline       - Distributed Parameters Line
%   power_ground         - Ground
%   power_mutual         - Mutual inductance
%   power_neutral        - Neutral
%   power_netsim1        - power_analyze example 1
%   power_netsim2        - power_analyze example 2
%   power_paralbranch    - Parallel RLC Branch 
%   power_paralload      - Parallel RLC Load
%   power_piline         - PI section line
%   power_seriesbranch   - Series RLC Branch 
%   power_seriesload     - Series RLC Load 
%   power_simplealt      - Simplified Synchronous Machine
%   power_switch         - Ideal Switch
%   power_syncmachine    - Synchronous Machine
%   power_thyristor      - Thyristor
%   power_transformer    - Linear transformer 
%   power_voltmeasure    - Voltage measurement
%   power_xfosaturable   - Saturable transformer

%   Copyright 1997-2004 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.1