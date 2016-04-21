function vqrealizemdl(UD)
%REALIZEMDL Vector Quantizer realization (Simulink diagram).
% creates model with either VQ Enc or VQ Dec block
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
%                if NEWBLOCK is a VQ CODEC block, 
%                      work on it to set_param
%                else %NEWBLOCK is NOT a VQ ENC/DEC block
%                     in My_model.mdl it adds a VQ CODEC block named NEWBLOCK1
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
%    $Revision: 1.1.6.3 $  $Date: 2003/12/06 15:23:15 $

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
[new_UD, OtherTypeBlock] = vqcreatemodel(UD);

if ~strcmpi(specname,new_UD.blockName),
    if (OtherTypeBlock)
      msgNotVQBlock = strcat(['Generate Model: The target block is not a Vector Quantizer block. Data have been exported to the block ', new_UD.blockName, '.']);
      set(UD.hTextStatus,'ForeGroundColor','Red');  set(UD.hTextStatus,'String',msgNotVQBlock);
    else
      msgNameChange = ['Generate Model: The generated block has been renamed'];%  to ', new_UD.blockName, '.']);  
      set(UD.hTextStatus,'ForeGroundColor','Red');  set(UD.hTextStatus,'String',msgNameChange);
    end
end

% Refresh connections
sys = new_UD.system;
oldpos = get_param(sys, 'Position');
set_param(sys, 'Position', oldpos + [0 -5 0 -5]);
set_param(sys, 'Position', oldpos);

sizeCB= size(UD.finalCodebook);
tempCB = reshape(UD.finalCodebook,1,sizeCB(1)*sizeCB(2));
set_param(sys,'codebook',['reshape(', '[', num2str(tempCB), ']',',',num2str(sizeCB(1)),',',num2str(sizeCB(2)),')' ]);

%set_param(sys,'codebook',strcat('[',num2str(UD.finalCodebook),']'));
if (UD.whichBlock==1)%encoder
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
