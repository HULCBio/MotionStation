function sys = subsasgn(sys,Struct,rhs)
%SUBSASGN  Meta data management in assignment operation.

%   Author(s):  P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:12:48 $

% RE: restricted to assignment of the form
%           sys(row_indices,col_indices) = rhis
indices = Struct(1).subs;
indrow = indices{1};
indcol = indices{2};
iscolon = strcmp(indices,':');
Ny = length(sys.OutputName);
Nu = length(sys.InputName);
CreateLHS = (Ny==0 && Nu==0);

% Handle empty assignments separately
if isempty(rhs),
   % Case rhs = [] 
   % sys(:,j,:,...,:) = [] or sys(i,:,:,...,:) = [] or
   % sys(:,:,:,...,:) = []
   % RE: sys(:,:) = [] produces a 0-by-m system as for matrices
   if all(iscolon) || ~iscolon(1)
      % Output deletion
      ikeep = 1:Ny;   ikeep(indrow) = [];
      sys.OutputName(indrow,:) = [];  
      sys.OutputGroup = groupref(sys.OutputGroup,ikeep);
   elseif ~iscolon(2)
      % Input deletion
      ikeep = 1:Nu;    ikeep(indcol) = [];
      sys.InputName(indcol,:) = [];  
      sys.InputGroup = groupref(sys.InputGroup,ikeep);
   end
   return
end

% Left with assignments of the form SYS(INDICES) = RHS
% ----------------------------------------------------
% Resize InputName and OutputName to new I/O size
% RE: Ensures proper filling with empty names
if ~CreateLHS
   tmpin = sys.InputName;
end
tmpin(indcol,:) = rhs.InputName;
sys.InputName(Nu+1:length(tmpin),:) = {''}; 

if ~CreateLHS
   tmpout = sys.OutputName;
end
tmpout(indrow,:) = rhs.OutputName; 
sys.OutputName(Ny+1:length(tmpout),:) = {''}; 

% Update InputName and InputGroup
if length(sys.InputName(indcol))==length(rhs.InputName)
   % Ignore rhs in scalar assignments
   if all(iscolon([1 3:end]))
      % Subset of columns are fully reassigned (SYS(:,j,:,...,:) = RHS)
      if any(cellfun('length',rhs.InputName))
         % Some RHS names are specified
         sys.InputName = tmpin;
      end
      sys.InputGroup = groupasgn(sys.InputGroup,indcol,rhs.InputGroup);
   else
      % Columns are only partially reassigned
      [sys.InputName(indcol,:),clash] = mrgname(sys.InputName(indcol,:),rhs.InputName);
      if clash, 
         warning('control:ioNameClash','Input name clash. Conflicting RHS names ignored.')
      end
      % Compare input groups. Overwrite only if original was empty
      if islogical(indcol)
         indcol = find(indcol);
      end
      Glhs = groupref(sys.InputGroup,indcol);
      [Grhs,clash] = mrggroup(Glhs,rhs.InputGroup);
      if clash,
         warning('control:GroupClash','Input group clash. RHS groups ignored.')
      else
         if iscolon(2)
            indcol = 1:length(sys.InputName);
         end
         sys.InputGroup = groupasgn(sys.InputGroup,indcol,Grhs);
      end
   end
end
   
% Update OutputName and OutputGroup
if length(sys.OutputName(indrow))==length(rhs.OutputName)
   % Ignore rhs in scalar assignments
   if all(iscolon(2:end))
      % Subset of rows are fully reassigned (SYS(i,:,:,...,:) = RHS)
      if any(cellfun('length',rhs.OutputName))
         % RHS names are not all undefined
         sys.OutputName = tmpout; 
      end
      sys.OutputGroup = groupasgn(sys.OutputGroup,indrow,rhs.OutputGroup);
   else
      % Rows are only partly reassigned
      [sys.OutputName(indrow,:),clash] = mrgname(sys.OutputName(indrow,:),rhs.OutputName);
      if clash, 
         warning('control:ioNameClash','Output name clash. Conflicting RHS names ignored.')
      end
      
      % Compare output groups. Overwrite only if original was empty
      if islogical(indrow)
         indrow = find(indrow);
      end
      Glhs = groupref(sys.OutputGroup,indrow);
      [Grhs,clash] = mrggroup(Glhs,rhs.OutputGroup);
      if clash,
         warning('control:GroupClash','Output group clash. RHS groups ignored.')
      else
         if iscolon(1)
            indrow = 1:length(sys.OutputName);
         end
         sys.OutputGroup = groupasgn(sys.OutputGroup,indrow,Grhs);
      end 
   end
end
