function localizeInputs(this)
% Determines which subset of the input channels drives each response.

%  Author: P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:56 $

% RE: Active input set stored in Context.InputIndex of each response.

% Adjust input width and update input names
InputNames = this.Input.ChannelName;

% Update connection between responses and input channels
for r=this.Responses'
   if isempty(r.DataSrc)
      InputIndex = [];
   else
      % Use data source info for sizing and named-based localization
      InputIndex = 1:getsize(r.DataSrc,2);
      try
         [junk,SrcInputNames] = getrcname(r.DataSrc);
         InputIndex = LocalMatchName(SrcInputNames,InputNames);
      end
   end
   r.Context.InputIndex = InputIndex;
end

% ----------------------------------------------------------------------------%
% Purpose: Localize a given set of names among a reference set of input names
% ----------------------------------------------------------------------------%
function Index = LocalMatchName(Names,RefNames)
if isempty(RefNames)
   % Axes grid row or column have fixed size = 1
   Index = 1;
else
   if all(cellfun('length',Names))
      % All names defined
      [junk,ia,ib] = intersect(RefNames,Names);
      [junk,is] = sort(ib);
      Index = ia(is).';
   else
      Index = [];
   end
   % Use default location if not all names were matched
   % REVISIT: assumes unique names!
   if length(Index)<length(Names)
      Index = 1:length(Names);
   end
end