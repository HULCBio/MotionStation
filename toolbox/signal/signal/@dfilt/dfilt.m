function varargout=dfilt(varargin)
%DFILT  Discrete-time filter object.
%   Hd = DFILT.STRUCTURE(input1,...) returns a discrete-time filter object,
%   Hd, of type STRUCTURE. You must specify a structure with DFILT. Each
%   structure takes one or more inputs. When you specify a DFILT.STRUCTURE
%   with no inputs, a filter with default property values is created (the
%   defaults depend on the particular filter structure). The properties may
%   be changed with SET(Hd,PARAMNAME,PARAMVAL).
%
%   DFILT.STRUCTURE can be one of the following (type help dfilt/STRUCTURE
%   to get help on a specific structure - e.g. help dfilt/df1):
%
%   dfilt.df1             - Direct-form I.
%   dfilt.df1sos          - Direct-form I, second-order sections.
%   dfilt.df1t            - Direct-form I transposed.
%   dfilt.df1tsos         - Direct-form I transposed, second-order sections.
%   dfilt.df2             - Direct-form II.
%   dfilt.df2sos          - Direct-form II, second-order sections.
%   dfilt.df2t            - Direct-form II transposed.
%   dfilt.df2tsos         - Direct-form II transposed, second-order sections.
%   dfilt.dffir           - Direct-form FIR.
%   dfilt.dffirt          - Direct-form FIR transposed.
%   dfilt.dfsymfir        - Direct-form symmetric FIR.
%   dfilt.dfasymfir       - Direct-form antisymmetric FIR.
%   dfilt.fftfir          - Overlap-add FIR.
%   dfilt.latticeallpass  - Lattice allpass.
%   dfilt.latticear       - Lattice autoregressive (AR).
%   dfilt.latticearma     - Lattice autoregressive moving-average (ARMA).
%   dfilt.latticemamax    - Lattice moving-average (MA) for maximum phase.
%   dfilt.latticemamin    - Lattice moving-average (MA) for minimum phase.
%   dfilt.scalar          - Scalar.
%   dfilt.statespace      - State-space.
%   dfilt.cascade         - Cascade (filters arranged in series).
%   dfilt.parallel        - Parallel (filters arranged in parallel).
%   dfilt.calattice       - Coupled-allpass (CA) lattice (available only with
%                           the Filter Design Toolbox).
%   dfilt.calatticepc     - Coupled-allpass (CA) lattice with power complementary (PC)
%                           output (available only with the Filter Design Toolbox).                                
%
%   The following methods are available for discrete-time filters (type
%   help dfilt/METHOD to get help on a specific method - e.g. help
%   dfilt/filter):
%
%   ---------------------Signal Processing Toolbox-------------------------
%   dfilt/addstage     - Add a stage to a cascade or parallel filter.
%   dfilt/cascade      - Cascade filter objects.
%   dfilt/coefficients - Filter coefficients.
%   dfilt/convert      - Convert structure of DFILT object.
%   dfilt/copy         - Copy discrete-time filter.
%   dfilt/fcfwrite     - Write a filter coefficient file.
%   dfilt/filter       - Execute ("run") discrete-time filter.
%   dfilt/firtype      - Determine the type (1-4) of a linear phase FIR filter.
%   dfilt/freqz        - Frequency response of a discrete-time filter.
%   dfilt/grpdelay     - Group delay of a discrete-time filter.
%   dfilt/impz         - Impulse response of a discrete-time filter.
%   dfilt/impzlength   - Length of the impulse response for a discrete-time filter.
%   dfilt/info         - Filter information.
%   dfilt/isallpass    - True for allpass discrete-time filter.
%   dfilt/iscascade    - True for cascaded discrete-time filter.
%   dfilt/isfir        - True for FIR discrete-time filter.
%   dfilt/islinphase   - True for linear discrete-time filter.
%   dfilt/ismaxphase   - True if maximum phase.
%   dfilt/isminphase   - True if minimum phase.
%   dfilt/isparallel   - True for discrete-time filter with parallel sections.
%   dfilt/isreal       - True for discrete-time filter with real coefficients.
%   dfilt/isscalar     - True if discrete-time filter is scalar.
%   dfilt/issos        - True if discrete-time filter is in second-order sections form.
%   dfilt/isstable     - True if the filter is stable.
%   dfilt/nsections    - Number of sections in a discrete-time filter.
%   dfilt/nstages      - Number of stages in a cascade or parallel filter.
%   dfilt/nstates      - Number of states in discrete-time filter.
%   dfilt/order        - Filter order.
%   dfilt/parallel     - Connect filters in parallel.
%   dfilt/phasez       - Phase response of a discrete-time filter.
%   dfilt/removestage  - Remove a stage in a cascade or parallel filter.
%   dfilt/reset        - Reset discrete-time filter.
%   dfilt/setstage     - Set a stage in a cascade or parallel filter.
%   dfilt/sos          - Convert to second-order-sections.
%   dfilt/ss           - Discrete-time filter to state-space conversion.
%   dfilt/stepz        - Discrete-time filter step response. 
%   dfilt/tf           - Convert to transfer function.
%   dfilt/zerophase    - Zero-phase response of a discrete-time filter.
%   dfilt/zpk          - Discrete-time filter zero-pole-gain conversion.
%   dfilt/zplane       - Pole/Zero plot
%
%   ----------------------Signal Processing Blockset-----------------------
%   dfilt/block        - Generate a Signal Processing Blockset block.
%   dfilt/realizemdl   - Filter realization (Simulink diagram). 
%
%   -------------------------Filter Design Toolbox-------------------------
%   dfilt/coewrite     - Write a XILINX CORE Generator(tm) coefficient (.COE) file.
%   dfilt/cumsec       - Vector of cumulative second-order section filters.
%   dfilt/denormalize  - Restore the coefficients from a NORMALIZE.
%   dfilt/double       - Cast filter to double-precision floating-point arithmetic.
%   dfilt/firlp2hp     - FIR Type I lowpass to highpass transformation.
%   dfilt/firlp2lp     - FIR Type I lowpass to lowpass transformation.
%   dfilt/iirbpc2bpc   - Complex bandpass to complex bandpass.
%   dfilt/iirlp2bp     - Real lowpass to real    bandpass.
%   dfilt/iirlp2bpc    - Real lowpass to complex bandpass.
%   dfilt/iirlp2bs     - Real lowpass to real    bandstop.
%   dfilt/iirlp2bsc    - Real lowpass to complex bandstop.
%   dfilt/iirlp2hp     - Real lowpass to real    highpass.
%   dfilt/iirlp2lp     - Real lowpass to real    lowpass.
%   dfilt/iirlp2mb     - Real lowpass to real    multi-band.
%   dfilt/iirlp2mbc    - Real lowpass to complex multi-band.
%   dfilt/iirlp2xc     - Real lowpass to N-point complex one.
%   dfilt/iirlp2xn     - Real lowpass to N-point real one.
%   dfilt/noisepsd     - Power spectral density of filter output due to roundoff noise.
%   dfilt/norm         - Filter norm.
%   dfilt/normalize    - Normalize filter coefficients.
%   dfilt/reffilter    - Reference double-precision floating-point filter.
%   dfilt/reorder      - Reorder second-order sections.
%   dfilt/scale        - Scale second-order sections.
%   dfilt/scalecheck   - Check scale of second-order sections.
%   dfilt/scaleopts    - Create options object for sos scaling.
%   dfilt/specifyall   - Fully specify fixed-point filter settings.
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point
%   Toolbox, enables single precision floating-point and fixed-point
%   support for all DFILT structures.
%
%   ------------------------Filter Design HDL Coder------------------------
%   dfilt/generatehdl        - Generate HDL.
%   dfilt/generatetb         - Generate an HDL Test Bench.
%   dfilt/generatetbstimulus - Generate HDL Test Bench Stimulus.
%
%   % EXAMPLE: Design and construct a direct-form FIR lowpass filter and
%   % analyze its various responses
%   b = firls(80,[0 .4 .5 1],[1 1 0 0],[1 10]);
%   Hd = dfilt.dffir(b)
%   fvtool(Hd) % Analyze filter
%
%   For more information, enter
%       doc dfilt
%   at the MATLAB command line.
%
%   See also ADAPTFILT, MFILT in the Filter Design Toolbox. 
%

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2004/04/13 00:00:00 $

msg = sprintf(['Use DFILT.STRUCTURE to create a discrete-time filter.\n',...
               'For example,\n   Hd = dfilt.df2']);
error(msg)
