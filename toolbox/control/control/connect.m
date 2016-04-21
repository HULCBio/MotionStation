function [aa,bb,cc,dd] = connect(a,b,c,d,q,varargin)
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

%Old help
%CONNECT Connects unconnected block diagonal State Space system.
%   [Ac,Bc,Cc,Dc] = CONNECT(A,B,C,D,Q,INPUTS,OUTPUTS)  returns the 
%   state-space matrices (Ac,Bc,Cc,Dc) of a system given the block 
%   diagonal, unconnected (A,B,C,D) matrices and a matrix Q that 
%   specifies the interconnections.  The matrix Q has a row for each 
%   input, where the first element of each row is the number of the 
%   input.  The subsequent elements of each row specify where the 
%   block gets its summing inputs, with negative elements used to 
%   indicate minus inputs to the summing junction.  For example, if 
%   block 7 gets its inputs from the outputs of blocks 2, 15, and 6, 
%   and the block 15 input is negative, the 7'th row of Q would be 
%   [7 2 -15 6].  The vectors INPUTS and OUTPUTS are used to select 
%   the final inputs and outputs for (Ac,Bc,Cc,Dc). 
%
%   For more information see the Control System Toolbox User's Guide.   
%   See also BLKBUILD and CLOOP.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 06:22:57 $
%   J.N. Little 7-24-85
%   Last modified JNL 6-2-86


error(nargchk(5,7,nargin))
error(abcdchk(a,b,c,d));

[aa,bb,cc,dd] = ssdata(connect(ss(a,b,c,d),q,varargin{:}));


% end connect
