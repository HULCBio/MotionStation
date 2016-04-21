function [ae,be,ce,de] = ssselect(a,b,c,d,e,f,g)
%SSSELECT Extract subsystem from larger system.
%   [Ae,Be,Ce,De] = SSSELECT(A,B,C,D,INPUTS,OUTPUTS) returns the
%   state space subsystem with the specified inputs and outputs.  The
%   vectors INPUTS and OUTPUTS contain indexes into the system
%   inputs and outputs respectively.
%
%   [Ae,Be,Ce,De] =  SSSELECT(A,B,C,D,INPUTS,OUTPUTS,STATES) returns
%   the state space subsystem with the specified inputs, outputs,
%   and states.
%
%   See also: SSDELETE.

%   Clay M. Thompson 6-26-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:20 $

error(nargchk(6,7,nargin));
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

[nx,na] = size(a);

if (nargin==6)
  inputs=e; outputs=f; states=1:nx;
end
if (nargin==7)
  inputs=e; outputs=f; states=g;
end

% --- Extract system ---
if ~isempty(a), ae = a(states,states);  else ae=[]; end
if ~isempty(b), be = b(states,inputs);  else be=[]; end
if ~isempty(c), ce = c(outputs,states); else ce=[]; end
if ~isempty(d), de = d(outputs,inputs); else de=[]; end
