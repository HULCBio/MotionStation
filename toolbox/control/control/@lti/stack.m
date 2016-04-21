function L = stack(dim,L1,L2,s1,s2)
%STACK  Stack LTI models into LTI array.
%
%   SYS = STACK(ARRAYDIM,SYS1,SYS2,...) produces an array of LTI
%   models SYS by stacking the LTI models SYS1,SYS2,... along
%   the array dimension ARRAYDIM.  All models must have the same 
%   number of inputs and outputs, and the I/O dimensions are not
%   counted as array dimensions.
%
%   For example, if SYS1 and SYS2 are two LTI models with the 
%   same I/O dimensions,
%     * STACK(1,SYS1,SYS2) produces a 2-by-1 LTI array
%     * STACK(2,SYS1,SYS2) produces a 1-by-2 LTI array
%     * STACK(3,SYS1,SYS2) produces a 1-by-1-by-2 LTI array.
%
%   You can also use STACK to concatenate LTI arrays SYS1,SYS2,...
%   along some array dimension ARRAYDIM.
%
%   See also HORZCAT, VERTCAT, APPEND, LTIMODELS.

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/01/07 19:32:34 $


%LTI/STACK  Property management in LTI array concatenation.
% 
%   SYS.LTI = STACK(DIM,SYS1.LTI,SYS2.LTI,S1,S2) sets the LTI 
%   properties of 
%      SYS = STACK(DIM,SYS1,SYS2)  
%   The last inputs S1 and S2 give the sizes of SYS1 and SYS2.

L = L1;

% Notes and UserData
L.Notes = {};
L.UserData = [];

% Sample time managament
% RE: Assumes that the sample time of static gains 
%     has already been adjusted
if (L1.Ts==-1 & L2.Ts>0) | (L2.Ts==-1 & L1.Ts>0),
   % Discrete/discrete with one unspecified sample time
   L.Ts = max(L1.Ts,L2.Ts);
elseif L1.Ts~=L2.Ts,
   error('Sampling time mismatch in concatenation.')
end

% Delay times
dim = dim+2;
L.ioDelay = DelayCat(dim,L1.ioDelay,L2.ioDelay,s1,s2);
L.InputDelay = DelayCat(dim,L1.InputDelay,L2.InputDelay,s1,s2);
L.OutputDelay = DelayCat(dim,L1.OutputDelay,L2.OutputDelay,s1,s2);
   
% I/O channel names should match 
[L.InputName,InputNameClash] = mrgname(L1.InputName,L2.InputName);
if InputNameClash,
   warning('Name clash. All input names deleted.')
   L.InputName(:,1) = {''}; 
end

[L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
if OutputNameClash,
   warning('Name clash. All output names deleted.')
   L.OutputName(:,1) = {''}; 
end

% I/O groups should match
[L.InputGroup,InputGroupClash] = mrggroup(L1.InputGroup,L2.InputGroup);
if InputGroupClash,
   warning('Group clash. All input groups deleted.')
   L.InputGroup = struct;
end

[L.OutputGroup,OutputGroupClash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if OutputGroupClash,
   warning('Group clash. All output groups deleted.')
   L.OutputGroup = struct;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Td = DelayCat(dim,Td1,Td2,s1,s2)

nd1 = length(size(Td1));
nd2 = length(size(Td2));

if nd1==2 & nd2==2 & isequal(Td1,Td2),
   % TD1 and TD2 are uniform and equal 
   % (only case where result is uniform)
   Td = Td1;
else
   if nd1<length(s1),
      % Expand 2D compact form of Td1
      Td1 = repmat(Td1,[1 1 s1(3:end)]);
   end
   if nd2<length(s2),
      % Expand 2D compact form of Td2
      Td2 = repmat(Td2,[1 1 s2(3:end)]);
   end
   Td = cat(dim,Td1,Td2); 
end

