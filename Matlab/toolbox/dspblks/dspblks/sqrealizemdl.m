function sqrealizemdl(UD)
%REALIZEMDL Scalar Quantizer realization (Simulink diagram).
%  Specification:
%  CASE-1: Current model: name:NEWBLOCK, overwrite = 0/1;
%  If gcs=library model or '' , it generates a new model 
%       'Untitled' with  a block named NEWBLOCK
%  else %% gcs= a valid model (say 'My_model')
%     if My_model.mdl DOES'NT have a block named NEWBLOCK
%           in My_model.mdl it adds a block named NEWBLOCK
%     else % My_model.mdl has a block named NEWBLOCK
%           if (overwrite=0)
%                in My_model.mdl it adds a block named NEWBLOCK1
%                and, Gives a message to the user.(we are too good)
%           else % (overwrite=1)
%                if NEWBLOCK is a SQ CODEC block, 
%                      work on it to set_param
%                else %NEWBLOCK is NOT a SQ CODEC block
%                     in My_model.mdl it adds a SQ CODEC block named NEWBLOCK1
%                     and, Gives a message to the user.(we are too good)
%                end
%           end
%     end
%  end
%  CASE-2: New model: name:NEWBLOCK
%     it generates a model with name Untitled. If Untitled.mdl is an open model
%     (not necessarily the GCS), then get model name =Untitled1.mdl
%     Add a block NEWBLOCK to that model and work on it.
%  end of specification

%    Copyright 1988-2003 The MathWorks, Inc.
%    $Revision: 1.2.4.2 $  $Date: 2003/12/06 15:23:13 $

% Check if DSP Blokset is installed
if (nargin ~=1)
    error('Error realizing model');
end    
if ~(exist('dspblks') == 7),
    set(UD.hTextStatus,'ForeGroundColor','Red');  set(UD.hTextStatus,'String','Generate Model: Could not find Signal Processing Blockset.');
    return
end

set(UD.hTextStatus,'ForeGroundColor','Black');  set(UD.hTextStatus,'String', 'Ready');

% Create model
specname = UD.blockName; 
[new_UD, OtherTypeBlock] = sqcreatemodel(UD);

if ~strcmpi(specname,new_UD.blockName),
    if (OtherTypeBlock)
      msgNotSQBlock = strcat(['Generate Model: The target block is not a Scalar Quantizer block. Data have been exported to the block ', new_UD.blockName, '.']);
      set(UD.hTextStatus,'ForeGroundColor','Red');  set(UD.hTextStatus,'String',msgNotSQBlock);
    else
      msgNameChange = ['Generate Model: The generated block has been renamed.']; %renamed to ', new_UD.blockName, '.']);
      set(UD.hTextStatus,'ForeGroundColor','Red');  set(UD.hTextStatus,'String',msgNameChange);
    end
end

% Refresh connections
sys = new_UD.system;
oldpos = get_param(sys, 'Position');
set_param(sys, 'Position', oldpos + [0 -5 0 -5]);
set_param(sys, 'Position', oldpos);
sizePT = size(UD.finalPartition);
sizeCB = size(UD.finalCodebook);
if sizePT(1)>1
    UD.finalPartition = UD.finalPartition';
end
if sizeCB(1)>1
    UD.finalCodebook = UD.finalCodebook';
end

set_param(sys,'codebook',strcat('[',num2str(UD.finalCodebook),']'));

if (UD.whichBlock==1)%encoder
	set_param(sys,'BBoundary',['[-inf ',num2str(UD.finalPartition),'  +inf]']);
    set_param(sys,'UBoundary',['[ ',num2str(UD.finalPartition),'  ]']);
	if (UD.SearchMethod == 1)
       set_param(sys,'SearchMethod','Linear');
	else
       set_param(sys,'SearchMethod','Binary'); 
	end   
	if (UD.TieBreakingRule== 1)
       set_param(sys,'tieBreakRule','Choose the lower index');
	else
       set_param(sys,'tieBreakRule','Choose the higher index'); 
	end 
end
% Open system
slindex = findstr(sys,'/');
open_system(sys(1:slindex(end)-1));

% [EOF]
