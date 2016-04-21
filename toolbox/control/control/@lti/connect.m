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

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:51:37 $
%   J.N. Little 7-24-85
%   Last modified JNL 6-2-86

error(nargchk(2,4,nargin))

% Extract data
if isa(sys,'frd'),
   error('CONNECT is not supported for FRD models.')
elseif ndims(sys)>2,
   error('CONNECT is not supported for arrays of LTI models.')
end
[a,b,c,d] = ssdata(sys);
[mq,nq] = size(q);
[md,nd] = size(d); 

% Form k from q, the feedback matrix such that u = k*y forms the
% desired connected system.  k is a matrix of zeros and plus or minus ones.

k = zeros(nd,md);
% Go through rows of Q
for i=1:mq
    % Remove zero elements from each row of Q
    qi = q(i,find(q(i,:)));
    [m,n] = size(qi);
    % Put the zeros and +-ones in K
    if n ~= 1
        k(qi(1),abs(qi(2:n))) = sign(qi(2:n));
    end
end

% Use output feedback to form closed loop system
%   .
%   x = Ax + Bu
%   y = Cx + Du      where  u = k*y + Ur 
%
bb = b/(eye(nd) - k*d);
aa = a + bb*k*c;
t = eye(md) - d*k;
cc = t\c;
dd = t\d;

% Form SYSc (inherits all properties of SYS)
sysc = ss(aa,bb,cc,dd,sys);

% Select just the outputs and inputs wanted:
if nargin>2,
   sysc = sysc(iy,iu);
end

% Convert to original model type
sysc = feval(class(sys),sysc);


