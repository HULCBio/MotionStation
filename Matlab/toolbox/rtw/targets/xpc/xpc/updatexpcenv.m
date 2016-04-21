function updatexpcenv(silent)
%UPDATEXPCENV Updates the new Environment settings to become the current ones
%
%   UPDATEXPCENV updates all Environment related files to reflect the new
%   settings made before with SETXPCENV. This procedure includes patching the
%   xPC kernels and system DLL's. Calling UPDATEXPCENV is necessary before the
%   creation of a target boot floppy with XPCBOOTDISK, after Environment
%   settings have been changed with SETXPCENV.
%
%   See also SETXPCENV, GETXPCENV, XPCBOOTDISK, XPCSETUP

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.10.2.4 $ $Date: 2004/03/04 20:09:48 $

% check if environment mat file exists
xpcinit;

load(xpcenvdata);

n=length(actpropval);

for i=1:n
  if ~isempty(newpropval{i})
    actpropval{i}=newpropval{i};
    newpropval{i}=[];
  end
end

save(xpcenvdata,'propname','actpropval','newpropval');

if nargin==0
  getxpcenv;
end
