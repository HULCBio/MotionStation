function setInitial(this)
%  setInitial  
%
%  Initializes common properties of an MPCnode object

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.6.1 $ $Date: 2003/10/15 18:48:55 $

this.Created = datestr(now);
this.Updated = this.Created;
A = ver;
for i = 1:length(A)
    if strcmp(A(i).Name, 'Model Predictive Control Toolbox')
        this.Version = A(i).Version;
        break
    end
end
