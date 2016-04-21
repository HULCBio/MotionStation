function ncdupdate(Model)
%NCDUPDATE  Upgrade models with old NCD blocks.
%
%   NCDUPDATE('DiagramName') searches the Simulink model specified
%   by the string 'DiagramName' for NCD Outport blocks and replaces 
%   them by the equivalent Signal Constraint block from the Simulink 
%   Response Optimization library.  Note that the model must be open 
%   prior to calling NCDUPDATE.
%
%   If your NCD block settings are saved in some "ncdStruct" variable,
%   first load this variable in the workspace before calling NCDUPDATE,
%   and resave this variable afterwards.  This will ensure that your
%   settings carry over to the upgraded block.
%
%   See also SROLIB, SLUPDATE.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.5 $ $Date: 2004/04/19 01:33:52 $
%   Copyright 1990-2004 The MathWorks, Inc.

error(nargchk(1,1,nargin))
Model = strrep(Model,'.mdl','');

% Find NCD blocks
try
   NCDBlocks = find_system(Model,'MaskType','NCD Outport');
catch
   error('The model %s must be open prior to calling NCDUPDATE.',Model)
end
nb = length(NCDBlocks);

if nb==0
   % No such blocks found
   warning('No NCD blocks to update.')
elseif ~isempty(find_system(Model,'MaskType','Signal Constraint'))
   error('First update old NCD blocks before adding new Response Optimization blocks.')
else
   % Save info about old blocks
   PortNum = zeros(nb,1);
   OldNames = cell(nb,1);
   OldPos = cell(nb,1);
   for ct=1:nb
      % Save port number
      blk = NCDBlocks{ct};
      PortNum(ct) = str2double(get_param(blk,'Port'));
      OldNames{ct} = get_param(blk,'Name');
      try
         OldPos{ct} = get_param(blk,'ncdGUIlocation');
      end
   end

   % Is the library loaded?
   LoadLibFlag = isempty(find(get_param(0,'Object'),'Name','srolib'));
   if LoadLibFlag
      load_system('srolib');
   end

   % Replace blocks
   replace_block(Model,'NCD Outport','srolib/Signal Constraint','noprompt')
   
   % Find new block names and undo possible reordering
   SROBlocks = find_system(Model,'MaskType','Signal Constraint');
   NewNames = get_param(SROBlocks,'Name');
   [junk,iold,inew] = intersect(OldNames,NewNames);
   iperm(inew) = iold;
   
   % Configure new blocks
   for ct=1:nb
      Pos = OldPos{iperm(ct)};
      if ~isempty(Pos)
         set_param(SROBlocks{ct},'DialogPosition',Pos)
      end
   end
   
   % Create project 
   Proj = getsro(Model,1);

   % Look for ncdStruct in workspace
   ncdStruct = evalin('base','ncdStruct','[]');
   if isNCDStruct(ncdStruct)
      % Convert saved constraint data into new format
      Proj.loadNCDStruct(ncdStruct,PortNum(iperm))
      Proj.Dirty = false;
      % Overwrite ncdStruct by project
      assignin('base','ncdStruct',Proj)
      % Link blocks to this variable
      for ct=1:nb
         set_param(SROBlocks{ct},'SaveAs','ncdStruct')
      end
      % Issue warning to resave variables
      msg = sprintf('%s\n%s','You must resave the workspace variable "ncdStruct"',...
         'to retain your NCD block settings');
      warndlg(msg,'Update Warning','modal')
   end
   
   % Clean up
   if LoadLibFlag
      close_system('srolib',0);
   end
end

