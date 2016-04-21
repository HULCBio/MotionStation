function L = ltiasgn(L,indices,lrhs,sizes,newsizes,rsizes,zerorhs)
%LTIASGN  LTI property management in assignment operation
%
%   L = LTIASGN(L,INDICES,LRHS,SIZES,NEWSIZES,RSIZES) sets the LTI 
%   properties of the system produced by the assignment
%       SYS(INDICES) = RHS .
%
%   The vectors SIZES and NEWSIZES are the sizes of SYS before and 
%   after the assignment, and RSIZES is the size of RHS.  These
%   vectors are used to resize the delay matrices when necessary.
%
%   See also SUBSASGN.

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2004/04/10 23:13:19 $

indrow = indices{1};
indcol = indices{2};
iscolon = strcmp(indices,':');


% Handle empty assignments separately
if isempty(lrhs),
   % Case lrhs = []  (assignment sys(i1,...,ik) = [])
   % RE: sys(:,:) = [] produces a 0-by-m system as for matrices
   if all(iscolon(3:end))
      % Input or output channel deletion
      if ischar(indcol),
         ikeep = 1:length(L.OutputName);   ikeep(indrow) = [];
         L.OutputName(indrow,:) = [];  
         L.OutputGroup = groupref(L.OutputGroup,ikeep);
         L.OutputDelay(indrow,:,indices{3:end}) = [];
      else
         ikeep = 1:length(L.InputName);    ikeep(indcol) = [];
         L.InputName(indcol,:) = [];  
         L.InputGroup = groupref(L.InputGroup,ikeep);
         L.InputDelay(indcol,:,indices{3:end}) = [];
      end
      L.ioDelay(indices{:}) = [];
   else
      % Model deletion: update Td if multi-dimensional
      if ndims(L.ioDelay)>2,
         L.ioDelay(indices{:}) = [];
      end
      if ndims(L.InputDelay)>2,
         L.InputDelay(indices{:}) = [];
      end      
      if ndims(L.OutputDelay)>2,
         L.OutputDelay(indices{:}) = [];
      end
   end
   L.ioDelay = tdcheck(L.ioDelay);
   L.InputDelay = tdcheck(L.InputDelay);
   L.OutputDelay = tdcheck(L.OutputDelay);
   return
end


% Left with assignments of the form SYS(INDICES) = RHS
% ----------------------------------------------------

% Sample time managament:
% RE: Assumes that the sample time of static gains 
%     has already been adjusted
if (L.Ts==-1 & lrhs.Ts>0) | (lrhs.Ts==-1 & L.Ts>0),
   % Discrete/discrete with one unspecified sample time
   L.Ts = max(L.Ts,lrhs.Ts);
elseif L.Ts~=lrhs.Ts,
   error('Inconsistent sample times in assignment.')
end

% Set all delays to zero if RHS is zero
if zerorhs,
   lrhs.ioDelay = 0;
   lrhs.InputDelay = 0;    % Used below as marker for zero RHS
   lrhs.OutputDelay = 0;
end
if isequal(size(lrhs.ioDelay),[1 1]),
   % RHS is scalar (scalar assgnt): no need to resize
   rsizes = [1 1];
end


% I/O delays assignment:
%%%%%%%%%%%%%%%%%%%%%%%%
if ~any(L.ioDelay(:)) & ~any(lrhs.ioDelay(:)),
   % All zero delays
   L.ioDelay = zeros(newsizes(1:2));
else
   % Expand L.ioDelay when non empty (i.e., LHS is not created by the assignment)
   if length(sizes)>ndims(L.ioDelay) & ~isequal(L.ioDelay,[]),
      L.ioDelay = repmat(L.ioDelay,[1 1 sizes(3:end)]);
   end
   % Expand LRHS.TD when not scalar
   srd = size(lrhs.ioDelay);
   if length(rsizes)>length(srd),
      lrhs.ioDelay = repmat(lrhs.ioDelay,[1 1 rsizes(3:end)]);
   end
   % Perform assignment
   L.ioDelay(indices{:}) = lrhs.ioDelay;
end


% InputDelay management
Dmid = 0;
sid = size(L.InputDelay);
idrhs = lrhs.InputDelay;
if ~any(L.InputDelay(:)) & ~any(idrhs(:)),
   % All zero delays
   L.InputDelay = zeros(newsizes(2),1);
elseif isequal(sizes,[0 0]),
   % Empty LHS
   L.InputDelay = [];
   L.InputDelay(indices{2},1,indices{3:end}) = idrhs;
else
   % Align dimensions of delay matrices with those of SYS and RHS
   L.InputDelay = repmat(L.InputDelay,[1 1 sizes(1+length(sid):end)]);
   idrhs = repmat(idrhs,[1 1 rsizes(1+ndims(idrhs):end)]);
   
   if iscolon(1),
      % All outputs reassigned: go ahead with direct assignment
      L.InputDelay(indices{2},1,indices{3:end}) = idrhs;
   else
      % Perform the assignment for the corresponding I/O delay matrices
      % Add +1 to all delays, and subtract -1 to result, to identify 
      % zero entries in transfer matrix (neutral for delay matters)
      % REVISIT: replace PERMUTE by transpose when available
      L.InputDelay = permute(L.InputDelay,[2 1 3:length(sizes)]);
      idrhs = permute(idrhs,[2 1 3:ndims(idrhs)]);
      iodlhs = repmat(1+L.InputDelay,[sizes(1) 1]);
      iodrhs = repmat((~zerorhs)+idrhs,[rsizes(1) 1]);
      iodlhs(indices{:}) = iodrhs;
      iodnew = iodlhs-1;
      % When replacing -1 entries by max delay along corresponding column,
      % resulting I/O delay matrix should be reducible to pure input delays
      maxcol = repmat(max(iodnew,[],1),[newsizes(1) 1]);
      iodnew(iodnew<0) = maxcol(iodnew<0);
      notid = any(any(abs(diff(iodnew(:,:,:),1,1))>1e3*eps,1),2);
      notid = notid(:);  % 0 for models with pure input delays, 1 otherwise
      % Absorb delays that are no longer pure input delays in ioDelay
      if any(notid),
         Dmid = zeros(newsizes);
         Dmid(:,:,notid) = max(0,iodlhs(:,:,notid)-1);      
      end
      % Update InputDelay
      L.InputDelay = reshape(max(0,iodnew(1,:,:)),[newsizes(2) 1 newsizes(3:end)]);
      L.InputDelay(:,1,notid) = 0;  % Zero what is no longer pure input delays
   end
end


% OutputDelay management
Dmod = 0;
sod = size(L.OutputDelay);
odrhs = lrhs.OutputDelay;
if ~any(L.OutputDelay(:)) & ~any(odrhs(:)),
   % All zero delays
   L.OutputDelay = zeros(newsizes(1),1);
elseif isequal(sizes,[0 0]),
   % Empty LHS
   L.OutputDelay = [];
   L.OutputDelay(indices{1},1,indices{3:end}) = odrhs;
else
   % Align dimensions of delay matrices with those of SYS and RHS
   L.OutputDelay = repmat(L.OutputDelay,[1 1 sizes(1+length(sod):end)]);
   odrhs = repmat(odrhs,[1 1 rsizes(1+ndims(odrhs):end)]);
   
   if iscolon(2),
      % All inputs reassigned: go ahead with direct assignment
      L.OutputDelay(indices{1},1,indices{3:end}) = odrhs;
   else
      % Perform the assignment for the corresponding I/O delay matrices
      iodlhs = repmat(1+L.OutputDelay,[1 sizes(2)]);
      iodrhs = repmat((~zerorhs)+odrhs,[1 rsizes(2)]);
      iodlhs(indices{:}) = iodrhs;
      iodnew = iodlhs-1;
      % Find for which models the resulting I/O delay can be reduce to output delays
      maxrow = repmat(max(iodnew,[],2),[1 newsizes(2)]);
      iodnew(iodnew<0) = maxrow(iodnew<0);
      notod = any(any(abs(diff(iodnew(:,:,:),1,2))>1e3*eps,1),2);
      notod = notod(:);
      % Absorb delays that are no longer pure input delays in ioDelay
      if any(notod),
         Dmod = zeros(newsizes);
         Dmod(:,:,notod) = max(0,iodlhs(:,:,notod)-1);      
      end
      % Update OutputDelay
      L.OutputDelay = reshape(max(0,iodnew(:,1,:)),[newsizes(1) 1 newsizes(3:end)]);
      L.OutputDelay(:,1,notod) = 0;  % Zero what is no longer pure input delays
   end
end
   
% Look for case where input (output) delays are common to all models
L.InputDelay = tdcheck(L.InputDelay);
L.OutputDelay = tdcheck(L.OutputDelay);
         
% Update I/O ioDelay for models which lost their input or output delays
if any(Dmid(:)) | any(Dmod(:)),
   % Revisit: remove next IF when ND add is OK
   if ndims(L.ioDelay)<length(newsizes),
      L.ioDelay = repmat(L.ioDelay,[1 1 newsizes(3:end)]);
   end
   L.ioDelay = L.ioDelay + Dmid + Dmod;
end

% In the array case, keep only one copy if ioDelay is the same for all models
L.ioDelay = tdcheck(L.ioDelay);



% I/O names and I/O groups:
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isequal(newsizes(1:2),[0 0]),
   % Watch for clear sys, sys(:,:) = scalar model -> empty sys
   L.InputName = cell(0,1);
   L.OutputName = cell(0,1);
   L.InputGroup = struct;
   L.OutputGroup = struct;
   return
end
   
% Turn INDROW and INDCOL into vectors of true indices
Prhs = length(lrhs.OutputName);
if ischar(indrow),
   indrow = 1:max(length(L.OutputName),Prhs);
elseif islogical(indrow),
   indrow = find(indrow);
end
Mrhs = length(lrhs.InputName);
if ischar(indcol),
   indcol = 1:max(length(L.InputName),Mrhs);
elseif islogical(indcol),
   indcol = find(indcol);
end

% Resize I/O names of LHS if necessary
L.InputName(end+1:max(indcol),1) = {''};    
L.OutputName(end+1:max(indrow),1)  = {''};
   
% Pre-process scalar assignments
if length(indrow)>Prhs | length(indcol)>Mrhs,
   % Delete I/O names
   lrhs.InputName(ones(length(indcol),1),1) = {''};
   lrhs.OutputName(ones(length(indrow),1),1) = {''};
end

% InputName and InputGroup
if all(iscolon(1:2))
   % Reassigning subset of LTI array models
   [L.InputName,clash] = mrgname(L.InputName,lrhs.InputName);
   if clash,
      warning('control:ltiasgn:inputnameclash','Input name clash. Conflicting RHS names ignored.')
   end
   [L.InputGroup,clash] = mrggroup(L.InputGroup,lrhs.InputGroup);
   if clash,
      warning('control:ltiasgn:inputgroupclash','Input group clash. RHS groups ignored.')
   end
   
elseif iscolon(1) || all(ismember(1:length(L.OutputName),indrow)),
   % Subset of columns are fully reassigned (SYS(:,j) = RHS)
   if any(cellfun('length',lrhs.InputName))
      % RHS names are not all undefined
      L.InputName(indcol,1) = lrhs.InputName;
   end
   L.InputGroup = groupasgn(L.InputGroup,indcol,lrhs.InputGroup);

else
   % Columns are only partially reassigned
   [L.InputName(indcol,1),clash] = mrgname(L.InputName(indcol,1),lrhs.InputName);
   if clash, 
      warning('control:ltiasgn:inputnameclash','Input name clash. Conflicting RHS names ignored.')
   end
   
   % Compare input groups. Overwrite only if original was empty
   Glhs = groupref(L.InputGroup,indcol);
   [Grhs,clash] = mrggroup(Glhs,lrhs.InputGroup);
   if clash,
      warning('control:ltiasgn:inputgroupclash','Input group clash. RHS groups ignored.')
   else
      L.InputGroup = groupasgn(L.InputGroup,indcol,Grhs);
   end
end

% OutputName and OutputGroup
if all(iscolon(1:2))
   [L.OutputName,clash] = mrgname(L.OutputName,lrhs.OutputName);
   if clash,
      warning('control:ltiasgn:outputnameclash','Output name clash. Conflicting RHS names ignored.')
   end
   [L.OutputGroup,clash] = mrggroup(L.OutputGroup,lrhs.OutputGroup);
   if clash,
      warning('control:ltiasgn:outputgroupclash','Output group clash. RHS groups ignored.')
   end

elseif iscolon(2) || all(ismember(1:length(L.InputName),indcol)),
   % Subset of rows are fully reassigned (SYS(i,:) = RHS)
   if any(cellfun('length',lrhs.OutputName))
      % RHS names are not all undefined
      L.OutputName(indrow,1) = lrhs.OutputName; 
   end
   L.OutputGroup = groupasgn(L.OutputGroup,indrow,lrhs.OutputGroup);
   
else
   % Rows are only partly reassigned
   [L.OutputName(indrow,1),clash] = mrgname(L.OutputName(indrow,1),lrhs.OutputName);
   if clash, 
       warning('control:ltiasgn:outputnameclash','Output name clash. Conflicting RHS names ignored.')
   end
    
   % Compare output groups. Overwrite only if original was empty
   Glhs = groupref(L.OutputGroup,indrow);
   [Grhs,clash] = mrggroup(Glhs,lrhs.OutputGroup);
   if clash,
      warning('control:ltiasgn:outputgroupclash','Output group clash. RHS groups ignored.')
   else
      L.OutputGroup = groupasgn(L.OutputGroup,indrow,Grhs);
   end 
end




