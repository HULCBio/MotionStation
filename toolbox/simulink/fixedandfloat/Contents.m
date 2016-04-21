% Simulink Fixed Point utilities.
%
% These are utilities that are used in the context of the Simulink Fix Point
% blocks.
%
% Utilities for creating fixed-point data:
%
%  fixdt  - Create an object describing a fixed-point or floating-point data type.
%  sfix   - Create structure describing Signed FIXed point data type.
%  sfrac  - Create structure describing Signed FRACtional data type.
%  sint   - Create structure describing Signed INTeger data type.
%  ufix   - Create structure describing Unsigned FIXed point data type.
%  ufrac  - Create structure describing Unsigned FRACtional data type.
%  uint   - Create structure describing Unsigned INTeger data type.
%  float  - Create structure describing a floating point data type.
%
% Utilities for manipulating and displaying fixed-point data:
%
%  fixptbestexp  - Determine the exponent that gives the best precision.
%  fixptbestprec - Determine the maximum precision that can be used in the fixed-point
%                  representation of a value.
%  fxptdlg       - Graphical interface for Fixed-Point Blockset simulation log.
%  fxptplt       - Graphical interface for plotting blocks in a Fixed-Point system.
%  num2fixpt     - Quantize a value using a fixed point blockset representation.
%  fixpt_interp1           - Fixed-point 1-D interpolation (table lookup).
%  fixpt_look1_func_approx - Find points for lookup table approximate to a function. 
%  fixpt_look1_func_plot   - Plot an ideal function and its lookup approximation. 
%
% Run HELP on any of these commands for usage information. For example, typing
%
% help sfix
% 
% at the MATLAB prompt will display the usage information related to the SFIX function.


% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $