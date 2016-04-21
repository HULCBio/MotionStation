function [ar,br,cr,dr] = ssdelete(a,b,c,d,e,f,g)
%SSDELETE Remove inputs, outputs and states from state-space system.
%   [Ar,Br,Cr,Dr] = SSDELETE(A,B,C,D,INPUTS,OUTPUTS) returns the 
%   state-space system with the specified inputs and outputs removed
%   from the system.  The vectors INPUTS and OUTPUTS contain indexes
%   into the system inputs and outputs, respectively.
%
%   [Ar,Br,Cr,Dr] = SSDELETE(A,B,C,D,INPUTS,OUTPUTS,STATES) returns
%   a state-space system with the specified inputs, outputs, and 
%   states removed from the system.
%
%   See also: SSSELECT.

%   Clay M. Thompson 6-27-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:23 $

error(nargchk(6,7,nargin));
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

if (nargin==6)
  inputs=e; outputs=f; states=[];
end
if (nargin==7)
  inputs=e; outputs=f; states=g;
end

% --- Remove the specified inputs,outputs and states ---
ar=a; br=b; cr=c; dr=d;
[nx,na] = size(a);
[ny,nu] = size(d);
if length(states)~=nx,
  if ~isempty(a), ar(:,states)=[]; ar(states,:)=[]; else ar=[]; end
  if ~isempty(b), br(states,:)=[]; br(:,inputs)=[]; else br=[]; end
  if ~isempty(c), cr(:,states)=[]; cr(outputs,:)=[]; else cr=[]; end
else
  ar=[]; br=[]; cr=[];
end
if (length(inputs)~=nu)&(~isempty(d)),
  dr(:,inputs)=[]; dr(outputs,:)=[];
else
  dr=[];
end

% end ssdelete
