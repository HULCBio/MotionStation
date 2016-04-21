function [indices,freqIndices] = getfreqindex(sys, indices)
% GETFREQINDEX looks through indices for frequency access indices,
%              returns frequency indices and remaining indices

% since last 2 elements must be  keyword,freqIndices,
% look at last two indices only

%   Author: S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:18:56 $

nind = length(indices);
freqIndices = indices{nind};	% dereference this now

keyword = indices{max(1,nind-1)}; % keyword 'frequency' in end-1 position
if nind < 2 | ...
   ~ischar(keyword) | ...
   ~strncmpi(keyword,'frequencypoints',length(keyword))
   freqIndices = ':';
   return
end

if nind <= 3  % keyword in position 1,2 could be channel/group name
   lasterr('');
   try
      nameref(keyword,sys.lti,nind-1);  % try to match I/O name
   end
   % Give priority to Channel/Group name over 'frequency' keyword
   % If the call to nameref above succeeds or does not return an error
   % which includes the string below, then assume group/channel name match
   % was found.  
   if isempty(findstr(lasterr,xlate('Unmatched name reference')))
      warning(sprintf('Interpreting ''%s'' as channel/group name, not ''%srequency'' keyword.',...
	   keyword,keyword(1)));
      freqIndices = ':';
      return
   end
   % if indices are now empty, use all I/O dimensions at given frequencies
   indices = [repmat({':'},[1 2*(nind==2)]) indices(1:end-2)];
else
   indices = indices(1:end-2);
end
