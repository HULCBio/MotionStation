function varargout = power_statespace(varargin)
% POWER_STATESPACE  Generate the continuous state-space representation of
%         a linear electrical circuit. The state variables are inductor
%         currents and capacitor voltages.
% 
%         POWER_STATESPACE can be called in two different ways:
%
%     1)  POWER_STATESPACE is called automatically by the POWER_ANALYZE command,
%         producing the topology and state-space representation of an electrical
%         circuit previously drawn in a SIMULINK window from the blocks of the
%         SimPowerSystems library.
%     2)  Directly from the MATLAB command line
%     
%  Input arguments
%  ===============
%       The number of arguments can be 7, 12, 13, 14 or 16.
%       The first 7 arguments must be specified. Arguments 8 to 16 are optional.
%
%       rlc : Branch matrix (nbr,6) or (nbr,7) specifying the network topology
%             and R L C values; see format below
%  switches : switch matrix (nsw,7) ; see format below
%    source : source matrix (nsrc,5) or (nsrc,6) or nsrc(7) ; see format below
% line_dist : distributed parameter line matrix (nline,7) ; see format below
%      yout : string matrix (nb_output,ncar) of output expressions
%             see format below
%    y_type : vector indicating output types
%             (0=voltage output ; 1=current output)
%      unit : units used to specify R L and C values in the rlc matrix 'rlc
%             unit = 'OHM' R L C values specified in ohms at fundamental
%                     frequency specified by freq_sys.
%             unit = 'OMU' R L C values specified in ohms millihenries (mH) and 
%                     microfarads(uF)
%
%       The following  9 arguments are optional:
%
%       Specify empty variables [] for the next 3 arguments 
%       if POWER_STATESPACE is not called by POWER_ANALYZE:
%
%    blocks : string matrix containing names of blocks  
%    srcstr : string matrix containing names of source blocks
%             starting with I_ or V_ prefix
% BranchREF : Integer matrix = cross reference list between POWER_ANALYZE topology 
%             and rlc matrix
%
% power_analyze_flag: Integer value (either 0, 1 or 2):
%                      0: POWER_STATESPACE is called from the MATLAB command
%                         line. Information on circuit (topology, modes,
%                         outputs ...) is displayed during execution.
%                      1: POWER_STATESPACE is called by POWER_ANALYZE. Only version number,
%                         number of states, inputs and outputs are displayed.
%                      2: Silent mode. 
%
% fid_outfile: File identifier of output file containing detailed messages 
%
%  freq_sys : Fundamental frequency (Hz) considered for specification of
%             L and C reactances if unit = 'OHM';  default value = 60 Hz
%
%  ref_node : reference node number used for pi transmission lines.
%             -1 = node is not specified (the user will be prompted to
%             specify a node number).
%
% vary_name : String matrix (nvary,n) containing the variable names 
%             used in output expressions          
%  vary_val : Vector containing the values of the variable names specified
%             in vary_name.      
%
%  Output arguments
%  ================
%   A,B,C,D :  State-space matrices of the linear circuit with all switches
%              open.
%              A(nstates,nstates) B(nstates,ninput)
%              C(noutput,nstates) D(noutput,ninput)
%    states :  String matrix (n,nstates) containing the names of the
%              state variables. Each string has the following format:
%                   Inductor  currents: Il_bxx_nzz1_zz2 
%                   Capacitor voltages: Uc_bxx_nzz2_zz2 
%                   where : xx = branch number 
%                           zz1= 1st node number of the branch
%                           zz2= 2nd node number of the branch
%        x0 :  Column vector of initial values of state variables
%              specifying the status (open or closed) of switches
%      x0sw :  Vector of initial values of switch currents
%  rlswitch :  Matrix (nsw,2) containing the R and L values of series switch
%              impedances in Ohms and Henrys
%     u,x,y :  Matrices  u(ninput,nfreq) x(nstates,nfreq) y(noutput,nfreq)
%              containing the steady-state complex values of inputs, states
%              and outputs. Each column corresponds to a different source
%              frequency as specified by the next argument (freq).
%      freq :  Column vector containing the (nfreq) source frequencies 
%              ordered by increasing frequency.
%   Asw,Bsw :  State-space matrices of the circuit including the 
%   Csw,Dsw    closed switches (one extra state per closed switch)
%      Hlin :  Complex transfer impedance matrix (noutput,ninput) of the
%              linear system corresponding to the first nonzero frequency
%              of the FREQ vector.
%
% Format of the RLC input matrix
% ==============================
% Two formats are allowed:
%     6 columns :  No branch numbering; 
%                  Branch numbers correspond to the RLC line numbers (1-nbr)
%     7 columns :  Branch numbering is imposed by the user
%
%     Each line of the RLC matrix must be specified according to the
%     following format:
%
%             (1)   (2)  (3)  (4)  (5)  (6)   [7]
%           node1 node2  TYPE  R    Xl  Xc   [Nobr] for a RLC or line branch
%      or   node1 node2  TYPE  R    L   C    [Nobr]
%           node1 node2  TYPE  R    Xl  U    [Nobr] for a transformer branch
%      or   node1 node2  TYPE  R    L   U    [Nobr]
%
%           node1 : Node number 1 of the branch
%           node2 : Node number 2 of the branch
%                   NOTE:
%                   Node numbers must be positive or zero.
%                   Decimal node numbers are allowed.                       
%            TYPE : Code indicating the type of connection of R L C elements
%                   (0-3) or the transmission line length (negative value).
%                   0 : series R L C
%                   1 : parallel R L C
%                   2 : transformer winding
%                   3 : coupled (mutual) winding
%                       For a mutual or a transformer having N windings,
%                       N+1 consecutive lines must be specified:
%                      -N lines TYPE=2 or TYPE=3; (one line per winding)
%                       Each line specifies R/L/U or R/Xl/Xc
%                       where : R/L R/Xl = winding resistance and leakage
%                            reactance or winding resistance and self-reactance
%                               U = Nominal voltage of transformer winding 
%                                   (specify 0 for TYPE 3)
%                      - one line TYPE=1 for the magnetizing branch of a
%                        transformer (parallel R/L or R/XLl)
%                        or one line TYPE=0 for a mutual impedance
%                        (series R/L or R/XL)
% 
%                   Negative value:  transmission line length (km)
%                   --------------
%                    For a transmission line, the R,L,C or R/Xl/Xc values
%                    must be specified in (ohm/km) or (ohm,mH,uF /km)
%
%            R    : Branch resistance (ohms or pu)
%            Xl   : Branch inductive reactance  (ohms or pu at FREQ_SYS)
%                   or transformer winding leakage reactance (ohms)
%             L   : Branch inductance (mH)
%            Xc   : Branch capacitive reactance (ohms or pu at FREQ_SYS)
%                   (The negative sign for Xc is optional)
%             C   : Capacitance (uF)
%             U   : Nominal voltage of transformer winding
%                   Same units Volts or kV must be used for each winding.
%                   For a mutual (TYPE=3), this value must be set to zero.
%
%                   Zero values
%                   ----------- 
%                   For R, L or Xl, C or Xc, in a series or parallel branch,
%                   indicates that the corresponding element does not exist.
%
%                   Restrictions on transformers and mutuals
%                   ----------------------------------------
%                 - Null values are not allowed for winding resistances
%                   of transformers and mutuals. Specify a very low value
%                   (e.g. 1e-6 pu based on rated voltage and power)
%                   to simulate a quasi-ideal transformer.
%                   The leakage reactances can be set to zero.
%                 - The resistive part of the magnetizing branch of a   
%                   transformer must have a finite value. Specify a very
%                   high value (low losses, e.g 1e4 pu or 0.01% based on 
%                   rating) to simulate a quasi-ideal transformer.
%                   The inductive part of the magnetizing branch can be 
%                   set to infinity (no reactive losses: specify Xm = 0)
%                 - A null value is not allowed for the mutual inductance 
%                   of coupled windings. The resistive part of 
%                   series mutual branch can set to zero. 
%
% Format of the SOURCE input matrix
% =================================
% Three formats are allowed:
%     5 columns : All sources are generating the same frequency specified
%                 by FREQ_SYS
%     6 columns : The frequency of each source is specified in column 6
%     7 columns : This column is used to specify the type
%                 of nonlinear element modeled by the current source
%
%     Each line of the SOURCE matrix must be specified according to the
%     following format:
%
%             (1)   (2)  (3)    (4)   (5)    [6]    [7]
%           node1 node2  TYPE  AMP   PHASE  [FREQ]  [MODEL]
%
%     node1,node2 : Node numbers corresponding to the source terminals
%                   Polarity conventions:
%                     Voltage source : Node 1 is the positive terminal.
%                     Current source : Current is flowing out of node 1. 
%            TYPE : Code indicating type of source
%                     0 = voltage source
%                     1 = current source
%             AMP : amplitude of the AC or DC voltage or current (V,A or pu)
%           PHASE : phase of the AC voltage or current (degrees)
%            FREQ : Frequency (Hz) of the generated voltage or current.
%                   For a DC voltage or current source, specify
%                   PHASE=0 and FREQ=0. AMP can be set to a negative value. 
%                   Generated signal:
%                                      AMP*sin(2*pi*FREQ*t+PHASE) for AC
%                                      AMP for DC
%           MODEL : integer specifying the type of nonlinear element
%                   modeled by the current source (saturable inductance,
%                   thyristor, switch...);  Used by POWER_ANALYZE only.
%
% Format of the SWITCHES input matrix
% =================================
%    Switches are nonlinear elements simulating mechanical or electronic
%    devices such as circuit breakers, diodes, or thyristors. Like other nonlinear
%    elements, they are simulated by current sources driven by the voltage
%    imposed across their terminals. Therefore, they cannot have exactly
%    zero impedances. They are simulated as ideal switches in series with a
%    series R-L circuit.
%
%    The switch parameters must be specified  in a line of the SWITCHES matrix
%    in 7 different columns according to the following format:
%
%             (1)   (2)  (3)    (4)   (5)     (6)     (7)
%          node1  node2 STATUS   R    L/Xl    No_I    No_U
%
%    node1, node2 : Node numbers corresponding to the switch terminals
%          STATUS : Code indicating the initial status of the switch at t = 0
%                     0 = open
%                     1 = closed
%              R  : Resistance of the switch when closed (ohms or pu)
%            L/Xl : Inductance of the switch when closed (mH)
%                   or inductive reactance (ohms or pu at FREQ_SYS)
%                   Note: For these last two fields, the same units as
%                         specified for the RLC matrix (UNIT) must be used.
%                         Null inductance values are not allowed. However,
%                         the resistance value can be set to zero.
%
%                   The next two fields specify the current input number
%                   and the voltage output number to be used for 
%                   interconnecting the switch model to state-space block.
%
%            no_I : Current input number coming from the output of
%                   the switch model
%            no_U : Voltage output number driving the input of the 
%                   switch model
%
% Format of the LINE_DIST matrix
% ==============================
%    Each row of the LINE_DIST matrix is used to specify a distributed
%    parameter transmission line.
%    The number of columns of LINE_DIST depends on the number of phases
%    of the transmission line.
%    For an NPHASE line, the first (4+3*NPHASE+NPHASE^2) columns are used.
%    For example, for a three-phase line, 22 columns are used.
%
%             (1)   (2)   (3)   (4)  (5...                 ...)
%          NPHASE  No_I  No_U  LONG  L/Xl   Zc  Rm   SPEED Ti
%
%       NPHASE = Number of phases of the transmission line
%        No_I  = Input number in the SOURCE matrix corresponding to the
%                first current source Is_1 of the line model.
%                Each line model uses 2*NPHASE current sources specified
%                in the SOURCE matrix as follows:
%                  Is_1 Is_2 ...Is_nphase for the sending end followed by
%                  Ir_1 Ir_2 ...Ir_nphase for the receiving end.
%        No_U  = Output number of the state-space corresponding to the
%                first voltage output Vs_1 feeding the line model.
%                Each line model uses 2*NPHASE voltage outputs
%                in the SOURCE matrix as follows:
%                  Vs_1 Vs_2 ...Vs_NPHASE for the sending end followed by
%                  Vr_1 Vr_2 ...Vr_NPHASE for the sending end followed by
%       LONG   = Length of the line (km)
%         Zc   = Vector of the NPHASE modal characteristic impedances (ohms)
%         Rm   = Vector of the NPHASE modal series linear resistances
%                (ohms/km)
%       SPEED  = Vector of the NPHASE modal propagation speeds (km/s)
%         Ti   = Transformation matrix from  mode to phase currents
%                such that Iphase=Ti.Imode
%                The  NPHASE*NPHASE matrix is given in vector format
%                  [col_1,col_2, ... col_NPHASE]
%
% Format of the YOUT matrix
% =========================
%   The desired outputs are specified by a string matrix (YOUT). Each line of
%   the YOUT matrix must be an algebraic expression containing any linear
%   combination of states and state derivatives specified according to the
%   following format:
%                 
%                Uc_bn  : Capacitor voltage of branch #n
%                Il_bn  : Inductor current of branch #n
%      dUc_bn,  dIl_bn  : Derivative of Uc_bn or Il_bn
%               Un, In  : Source voltage or current specified by line #n
%                         of the SOURCE matrix
%             U_nx1_x2  : Voltage between node x1 and node x2
%                 I_bn  : Current in branch #n
%                         For a parallel RLC branch, I_bn corresponds
%                         to the total current IR+IL+IC
%              I_bn_nx  : Current flowing into node x of a transmission 
%                         line specified by line #n of the RLC matrix.
%                         (This current includes the series inductive branch
%                         current and the capacitive shunt current).
%
%   Each output expression is built from the above voltage and current variable
%   names, constants, variable names, parentheses, and operators (+-*/^) in
%   order to form a valid MATLAB expression.  
%
%   Example :  YOUT=[ '10*I_b1 + Uc_b3 -L2*dIl_b2', ...
%                     'U_n10_20                  '];
%
%   If variable names are used (e.g., L2 in the above example), their names and
%   values must be specified by the two input arguments VARY_NAME and VARY_VAL.
%
%   Sign conventions for voltages and currents
%   ------------------------------------------
%       I_bn Il_bn, In = Branch current, inductor current of branch or
%                        current of source #n is oriented from node1 to node2.
%            I_bn_nx   = Current at one end (node x) of a transmission line  
%                        If x= node1, the current is entering the line.
%                        If x= node2, the current is exiting of the line.
%            Uc_bn, Un = Voltage across capacitor or voltage source
%                          = Unode1 - Unode2
%            U_nx1_x2  = Voltage between nodes x1 and x2 = Ux1 - Ux2
%
%   See also  POWER_ANALYZE

%   Gilbert Sybille (IREQ),Jan-31-96, P.Brunelle 25-10-2000, 15-03-2001
%   Updated to PSB 2.0 by Roger Champagne (ETS), 1999-Jul-15 Revision: 1.4
%   Date: 1999-08-13 11:03:51-04

%   Copyright 1997-2004 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

if nargout == 0,
  power_statespace_pr(varargin{:});
else
  [varargout{1:nargout}] = power_statespace_pr(varargin{:});
end