function [oppoint,opreport] = trim(this,varargin)
% TRIM   
% 
% [OPPOINT, OPREPORT] = TRIM(OP,OPTIONS)
%       Finds steady state parameters for a Simulink system given a set of 
%       conditions.  TRIM enables steady state parameters to be found that 
%       satisfy certain input, output and state conditions.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:20 $

if nargin == 1
    [oppoint, opreport] = findop(this.Model,this);
elseif nargin == 2
    [oppoint, opreport] = findop(this.Model,this);
else
    
end

