function L = horzcat(L1,L2)
%HORZCAT  Horizontal concatenation of IDMODEL objects.
%
%   MOD = HORZCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 , MOD2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the models MOD1, MOD2,...
% 
%   See also VERTCAT,  IDMODEL.
 
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2001/10/12 15:57:15 $


L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [SLTI ; SYSJ.LTI]
   return
end

% Notes and UserData
L.Notes = {};
L.UserData = [];

 if L1.Ts~=L2.Ts,
   error('Sampling time mismatch in concatenation.')
end

 % Append input names
[nol,L.InputName,ovl] = defnum2(L1.InputName, 'u',L2.InputName);
if ~isempty(ovl)
   error(['Non-trivial InputNames overlap (',...
         L2.InputName{ovl(1)},') in the two models.'])
end
L.InputUnit = [L1.InputUnit ; L2.InputUnit];
L.InputDelay = [L1.InputDelay;L2.InputDelay];
% OutputName: check compatibility and merge
[L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
if OutputNameClash,
   warning('Name clash. All output names deleted.')
   EmptyStr = {''};
   L.OutputName = defnum({},'y',length(L.OutputName)); 
end
[L.OutputUnit,OutputNameClash] = mrgname(L1.OutputUnit,L2.OutputUnit);
if OutputNameClash,
   warning('Unit clash. All output units deleted.')
   EmptyStr = {''};
   L.OutputUnit = EmptyStr(ones(length(L.OutputName),1),1);
end

 
