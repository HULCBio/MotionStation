function TunablePars  = getTunableParams(this,ReferenceFlag)
% Gets list of tunable parameters in model.
% 
%   Returns a struct array with fields Name, Type, and ReferencedBy.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:44:59 $

% Base workspace parameters
bwRefs = get_param( this.Model, 'ReferencedWSVars' );
nbwp = length(bwRefs);
if nbwp>0
   bwRefsNames = {bwRefs.Name};
   bwParams = struct('Name',bwRefsNames,'Type',[],'ReferencedBy',{cell(0,1)});
   % Get parameter type
   S = evalin('base', 'whos');
   [dummy, ia, ib] = intersect( {S.name}, bwRefsNames );
   for ct=1:length(ia)
      bwParams(ib(ct)).Type = S(ia(ct)).class;
   end
else
   bwParams = struct('Name',cell(0,1),'Type',[],'ReferencedBy',[]);
end

% Model workspace parameters
s = whos(get_param(this.Model,'ModelWorkspace'));
mwParams = struct('Name',{s.name},'Type',{s.class},'ReferencedBy',{cell(0,1)});

% Full parameter list
TunablePars = [bwParams , mwParams];

% References (only for base workspace for now)
if nargin>1
   for ct=1:nbwp
      % Referring blocks
      blks = handle(bwRefs(ct).ReferencedBy);
      % Construct reference display
      nb = length(blks);
      refs = cell(nb,1);
      for ctb=1:nb
         Name = blks(ctb).Name;
         Parent = blks(ctb).Parent;
         if ~strcmp(Parent,this.Model)
            idx = find(Parent=='/',1,'last');
            Parent = regexprep(Parent(idx+1:end), '\s', ' ');
            Name = [Parent '/' Name];
         end
         refs{ctb} = Name;
      end
      TunablePars(ct).ReferencedBy = refs;
   end
end
