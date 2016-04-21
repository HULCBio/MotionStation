function [aa,bb,cc,dd] = append(a1,b1,c1,d1,a2,b2,c2,d2)
%APPEND  Group LTI models by appending their inputs and outputs.
%
%   SYS = APPEND(SYS1,SYS2, ...) produces the aggregate system
% 
%                 [ SYS1  0       ]
%           SYS = [  0   SYS2     ]
%                 [           .   ]
%                 [             . ]
%
%   APPEND concatenates the input and output vectors of the LTI
%   models SYS1, SYS2,... to produce the resulting model SYS.
%
%   If SYS1,SYS2,... are arrays of LTI models, APPEND returns an LTI
%   array SYS of the same size where 
%      SYS(:,:,k) = APPEND(SYS1(:,:,k),SYS2(:,:,k),...) .
%
%   See also SERIES, PARALLEL, FEEDBACK, LTIMODELS.

% Old help
%APPEND Append together the dynamics of two state-space systems.
%	[A,B,C,D] = APPEND(A1,B1,C1,D1,A2,B2,C2,D2)  produces an aggregate
%	state-space system consisting of the appended dynamics of systems
%	1 and 2.  The resulting system is:
%	         .
%	        |x1| = |A1 0| |x1| + |B1 0| |u1|
%	        |x2|   |0 A2| |x2| + |0 B2| |u2|
%
%	        |y1| = |C1 0| |x1| + |D1 0| |u1|
%	        |y2|   |0 C2| |x2| + |0 D2| |u2|
%
%	See also: SERIES, FEEDBACK, CLOOP, PARALLEL.

%	Copyright 1986-2002 The MathWorks, Inc. 
% 	$Revision: 1.14 $  $Date: 2002/04/10 06:22:36 $

if nargin~=8,
   error('Wrong number of input arguments for obsolete matrix-based syntax.')
end
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
error(abcdchk(a1,b1,c1,d1));
error(abcdchk(a2,b2,c2,d2));

[aa,bb,cc,dd] = ssdata(append(ss(a1,b1,c1,d1),ss(a2,b2,c2,d2)));

