function L = vertcat(L1,L2)
%VERTCAT  Vertical concatenation of IDMODEL objects. 
%
%   MOD = VERTCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 ; MOD2 , ...]
% 
%   This operation amounts to appending  the outputs of the 
%   IDMODEL objects MOD1, MOD2,... and feeding all these models
%   with the same input vector.
% 
%   See also HORZCAT.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/10 23:17:49 $


L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [SLTI ; SYSJ.LTI]
   return
end

% Notes and UserData
%L.Notes = {};
%L.UserData = [];
if any(L1.InputDelay ~=L2.InputDelay)
    error('Different InputDelays in the models.')
end
if L1.Ts~=L2.Ts,
   error('Sampling time mismatch in concatenation.')
end


% Append output names
[nol,L.OutputName,ovl] = defnum2(L1.OutputName, 'y',L2.OutputName);
if ~isempty(ovl)
   error(['Non-trivial OutputNames overlap (',...
         L2.OutputName{ovl(1)},') in the two models.'])
end

 L.OutputUnit = [L1.OutputUnit ; L2.OutputUnit];
% OutputName: check compatibility and merge
if ~isempty(L1.InputName) % not time series
	[L.InputName,OutputNameClash] = mrgname(L1.InputName,L2.InputName);
	if OutputNameClash,
		warning('Input Name clash. All input names replaced by u1, u2 etc.')
		EmptyStr = {''};
		L.InputName = defnum({},'u',length(L.InputName));
	end
	[L.InputUnit,OutputNameClash] = mrgname(L1.InputUnit,L2.InputUnit);
	if OutputNameClash,
		warning('Unit clash. All input units deleted.')
		EmptyStr = {''};
		L.InputUnit = EmptyStr(ones(length(L.InputName),1),1);
	end
end

