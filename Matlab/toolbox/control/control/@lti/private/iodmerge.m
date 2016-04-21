function [iod,L1,L2] = iodmerge(iostr,iod1,iod2,L1,L2)
%IODMERGE  Merge two sets of input or output delays.
%
%   [IOD,L1,L2] = IODMERGE(IOSTR,IOD1,IOD2,L1,L2) checks
%   if the two sets IOD1 and IOD2 of input or output delays 
%   of the LTI objects L1 and L2 are compatible and absorbs 
%   conflicting delay sets into the I/O delay matrices of
%   L1 and L2.
%
%   See also HORZCAT, VERTCAT, PLUS.

%   Author(s):  P. Gahinet  5-13-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:53:35 $

if ~any(iod1(:)) & ~any(iod2(:)),
   iod = iod1;
   return
end

% Get shared delays
iod = tdcheck(ndops('min',iod1,iod2));

% Find model pairs with different input (output) delays
gap = abs(ndops('add',iod1,-iod2));
kgap = find(any(gap(:,:)>1e3*eps,1));

if ~isempty(kgap),
   % Subtract shared input(output) delays from IOD1 and IOD2
   iod1 = ndops('add',iod1,-iod);
   iod2 = ndops('add',iod2,-iod);
   
   % Absorb offending input(output) delays into corresponding I/O Delay Matrix
   if strcmp(iostr,'i'),
      iod1 = ndops('trans',iod1);
      iod2 = ndops('trans',iod2);
      L1.ioDelay = ndops('add',L1.ioDelay,repmat(iod1,[size(L1.ioDelay,1) 1]));
      L2.ioDelay = ndops('add',L2.ioDelay,repmat(iod2,[size(L2.ioDelay,1) 1]));
      L1.InputDelay = iod;
      L2.InputDelay = iod;
   else
      L1.ioDelay = ndops('add',L1.ioDelay,repmat(iod1,[1 size(L1.ioDelay,2)]));
      L2.ioDelay = ndops('add',L2.ioDelay,repmat(iod2,[1 size(L2.ioDelay,2)]));
      % Eliminate offending output delays                 
      L1.OutputDelay = iod;
      L2.OutputDelay = iod;
   end
end

