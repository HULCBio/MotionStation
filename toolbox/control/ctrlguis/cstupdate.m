function cstupdate(diagram_name);
%CSTUPDATE  Updates older versions of Control System Toolbox blocks.
%
%   CSTUPDATE('DiagramName') searches the Simulink model specified
%   by the string 'DiagramName' for LTI Blocks, Input Point, and 
%   Output Point Blocks.  Older versions of these blocks are replaced 
%   by their current versions.  Note that the model must be open 
%   prior to calling CSTUPDATE.

%   Karen Gondoly, 7-24-98
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/10 23:14:44 $

if ~isempty(nargchk(1,1,nargin)),
   error('You must specify a model name to update.')
elseif length(diagram_name)>4 & strcmpi(diagram_name(end-3:end),'.mdl')
   diagram_name = diagram_name(1:end-4);
end

if isempty(find_system('SearchDepth',0,'Name',diagram_name)),
  error(sprintf('You must open the model ''%s'' first before using cstupdate.',diagram_name));
end

%---Make sure the I/O Points and LTI Block are loaded
closeLTIflag=0;

if isempty(find_system('Name','cstblocks')),
   load_system('cstblocks');
   closeLTIflag=1;
end

closeSLflag=0;
%---Make sure the diagram, itself, is open
if isempty(find_system('Name',diagram_name)),
   load_system(diagram_name);
   closeSLflag=1;
end

allLTIblks = find_system(diagram_name,'LookUnderMasks','all','MaskType','LTI Block');

%---For LTI Blocks, make sure to retain current block values
MaskStrs = get_param(allLTIblks,'MaskValueString');
NewBlocks = replace_block(diagram_name,'MaskType','LTI Block', ...
   'cstblocks/LTI System','noprompt');
for ct=1:length(MaskStrs),
   set_param(NewBlocks{ct},'MaskValueString',MaskStrs{ct});
end

if closeLTIflag, close_system('cstblocks'); end
if closeSLflag, close_system(diagram_name,1); end
