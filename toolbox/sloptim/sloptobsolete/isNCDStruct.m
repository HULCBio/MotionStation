function boo = isNCDStruct(s)
% Checks if variable is an ncdStruct.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:56 $
boo = isa(s,'struct') && isfield(s,'TvarStr') && ...
   isfield(s,'CnstrLB') && isfield(s,'CnstrUB');