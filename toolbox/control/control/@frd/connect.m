function sysc = connect(sys,q,iu,iy)
%CONNECT  Derive state-space model for block diagram interconnection.
%
%   SYSc = CONNECT(SYS,Q,INPUTS,OUTPUTS)  returns a state-space 
%   model SYSc for the block diagram specified by the block-diagonal, 
%   unconnected LTI model SYS and the interconnection matrix Q.  
%   The matrix Q has a row for each input, where the first element 
%   of each row is the number of the input.  The subsequent elements 
%   of each row specify where the block gets its summing inputs, 
%   with negative elements used to indicate minus inputs to the 
%   summing junction.  For example, if block 7 gets its inputs from 
%   the outputs of blocks 2, 15, and 6, and the block 15 input is 
%   negative, the 7th row of Q would be [7 2 -15 6].  The index 
%   vectors INPUTS and OUTPUTS are used to select the final inputs 
%   and outputs of SYSc.
%
%   For more information see the Control System Toolbox User's Guide.  
% 
%   See also APPEND, SS.

%   J.N. Little 7-24-85
%   Last modified JNL 6-2-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:18:24 $

error('CONNECT is not supported for FRD models.')
