function setInitial(this)
%  setInitial  
%
%  Initializes common properties of an MPCnode object

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:36:27 $

this.Created = datestr(now);
this.Updated = this.Created;
A = ver;
for i = 1:length(A)
    if strcmp(A(i).Name, 'Model Predictive Control Toolbox')
        this.Version = A(i).Version;
        break
    end
end
