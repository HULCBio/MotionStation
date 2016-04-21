function Li = inv(L)
%INV  LTI model inverse.
%
%   ISYS = INV(SYS) computes the inverse model ISYS such that
%
%       y = SYS * u   <---->   u = ISYS * y 
%
%   The LTI model SYS must have the same number of inputs and
%   outputs. For arrays of LTI models, INV is performed on each 
%   individual model.
%   
%   See also MLDIVIDE, MRDIVIDE, LTIMODELS.

%       Author(s): P. Gahinet, 5-28-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.11.4.1 $  $Date: 2004/04/16 22:01:37 $
Li = L;

% Delete Notes and UserData
Li.Notes = {};
Li.UserData = [];

% Swap I/O names
Li.InputName = L.OutputName;
Li.OutputName = L.InputName;

% Swap I/O groups
Li.InputGroup = L.OutputGroup;
Li.OutputGroup = L.InputGroup;

% Zero time delays
nio = size(L.ioDelay,1);
L.ioDelay = zeros(nio);
L.InputDelay = zeros(nio,1);
L.OutputDelay = zeros(nio,1);
