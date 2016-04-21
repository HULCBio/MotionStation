function L = utLFT(L1,L2,indu1,indy1,indu2,indy2)
% Metadata management for LFT.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:13:01 $
L = L1;
L.Notes = {};
L.UserData = [];
L.Name = '';

% Sizes
[ny1,nu1] = iosize(L1);
[ny2,nu2] = iosize(L2);
indw1 = 1:nu1; indw1(indu1) = [];
indz1 = 1:ny1; indz1(indy1) = [];
indw2 = 1:nu2; indw2(indu2) = [];
indz2 = 1:ny2; indz2(indy2) = [];

% I/O names
L.InputName = [L1.InputName(indw1,:) ; L2.InputName(indw2,:)];
L.OutputName = [L1.OutputName(indz1,:) ; L2.OutputName(indz2,:)];

% I/O groups
nw1 = length(indw1);
L.InputGroup = groupcat(...
   groupref(L1.InputGroup,indw1),...
   groupref(L2.InputGroup,indw2),nw1+1:nw1+length(indw2));
nz1 = length(indz1);
L.OutputGroup = groupcat(...
   groupref(L1.OutputGroup,indz1),...
   groupref(L2.OutputGroup,indz2),nz1+1:nz1+length(indz2));