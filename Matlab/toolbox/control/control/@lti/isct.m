function boo = isct(sys)
%ISCT  True for continuous-time LTI models.
%
%   ISCT(SYS) returns 1 (true) if the LTI model SYS is continuous
%   (zero sampling time), and 0 (false) otherwise.
%
%   See also ISDT, LTIMODELS.

%   Author(s): P. Gahinet, 1-4-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:50:35 $

% SYS is continuous if Ts = 0
boo = (get(sys,'Ts')==0);

