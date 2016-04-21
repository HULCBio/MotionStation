function busdemoscript(varargin)
%BUSDEMOSCRIPT Controls the Bus Block Demo HTML page
%   BUSDEMOSCRIPT(action) executes the hyperlink callback associated with the 
%   the string action.
%
%   BUSDEMOSCRIPT(action,blockName) is used for the hiliteblock action. blockName
%   contains the string name of the block to be highlighted using hilite_system.
%
%   The complete set of demo files is as follows.
%      1) busdemo.mdl
%      2) busdemo.htm 
%      3) sldemo1_fig1.gif
%      4) sldemo1_fig2.gif
%      5) sldemo1_fig3.gif
%      6) sldemo1_fig4.gif
%      7) busdemoscript.m

%   Karen Gondoly
%	Copyright 1990-2002 The MathWorks, Inc.
%	$Revision: 1.7.4.1 $  $Date: 2004/04/13 00:34:55 $

persistent BUSDEMO_STEP_COUNTER
try % Wrap the whole thing in a try catch, in case the user doesn't go in order.
	
	ni=nargin;
	
	if ~ni,
		step = 'initialize';
	else 
		step = varargin{1};
	end

    % If the Close link was selected, immediately close the model and bail
    % out of the function
    if strcmp(step,'closemodel'),
        close_system('busdemo',0);
        return
    end
        
	% If first time running the demo, or they closed the model
	% Open the model and initialize the counter
	if isempty(find_system('Name','busdemo')) | ~ni
		busdemo;
	end
    if isempty(BUSDEMO_STEP_COUNTER)
        BUSDEMO_STEP_COUNTER=zeros(1,14);
    end
        
	switch step
	case 'initialize',
		% Open the web browser with the html file
		fullPathName=which('busdemoscript');
		tok=filesep;
		indtok = findstr(fullPathName,tok);
		pathname = fullPathName(1:indtok(end));
		web([pathname,'busdemo.htm']);
		
	case 'step1',
		% Open the Simulink model
		BUSDEMO_STEP_COUNTER(1)=1;
		
	case 'step2',
		% Run the model
		BUSDEMO_STEP_COUNTER(2)=1;
		sim('busdemo'); % Executing just this line will automatically open the model
		
	case 'step3',
		BUSDEMO_STEP_COUNTER(3)=1;
		% Turn on signal dimensions
		set_param('busdemo','ShowLineDimensions','on');
		set_param('busdemo','SimulationCommand','update'); % In case they didn't run the diagram
		
	case 'step4',
		BUSDEMO_STEP_COUNTER(4)=1;
		% Turn on wide vector lines
		%-This should actually be step 8, so make sure up to step 7 has been done
		if ~BUSDEMO_STEP_COUNTER(7),
			busdemoscript('step7');
		end	
		set_param('busdemo','WideLines','on');
		set_param('busdemo','SimulationCommand','update'); % Needed when invoked from command line
		
	case 'step5',
		BUSDEMO_STEP_COUNTER(5)=1;
		hilite_system('busdemo/Sine Wave','find');
		open_system('busdemo/Sine Wave')
		
	case 'step6',
		BUSDEMO_STEP_COUNTER(6)=1;
		set_param('busdemo/Sine Wave','Amplitude','[1 2]')
		%---If they come here, make sure to reset later steps that were already clicked
		BUSDEMO_STEP_COUNTER(7:14)=0;
		
	case 'step7',
		BUSDEMO_STEP_COUNTER(7)=1;
		% Make sure the signal dimensions are already shown
		if ~BUSDEMO_STEP_COUNTER(3),
			busdemoscript('step3');
		end	
		
		close_system('busdemo/Sine Wave')
		hilite_system('busdemo/Sine Wave','none')
		set_param('busdemo/Sine Wave','Amplitude','[1 2]');
		%---If they come here, make sure to reset later steps that were already clicked
		BUSDEMO_STEP_COUNTER(8:14)=0;
		
	case 'step8',
		BUSDEMO_STEP_COUNTER(8)=1;
		set_param('busdemo/Sine Wave','VectorParams1D','off');
		
	case 'step9',
		BUSDEMO_STEP_COUNTER(9)=1;
		% Make sure the wide vector lines are already shown
		if ~BUSDEMO_STEP_COUNTER(4),
			busdemoscript('step4');
		end	
		close_system('busdemo/Sine Wave')
		hilite_system('busdemo/Sine Wave','none')
		set_param('busdemo/Sine Wave','VectorParams1D','off');
		
	case 'step9_5',
		BUSDEMO_STEP_COUNTER(10)=1;
		% Make sure the wide vector lines are already shown
		if ~BUSDEMO_STEP_COUNTER(4),
			busdemoscript('step4');
		end	
		close_system('busdemo/Sine Wave') % Close the dialog, if opened so changes are applied
		set_param('busdemo/Sine Wave','Amplitude','[1 2; 3 4]');
		set_param('busdemo','SimulationCommand','update');
		
	case 'step9_75', % Open the Bus Creator
		%---Get demo up to the point where a matrix has been entered
		if ~BUSDEMO_STEP_COUNTER(10),
			busdemoscript('step9_5');
		end	
		open_system(find_system('busdemo','BlockType',...
            'BusCreator','Name',sprintf('%s\n%s','Bus','Creator')))
        
    case 'step9_80', % Expand the tree nodes
		%---Get demo up to the point where a matrix has been entered
		if ~BUSDEMO_STEP_COUNTER(10),
			busdemoscript('step9_5');
        end
        busCreatorDlgObj = FindDdgDlgInDAStudioRootFromFullBlkPath('busdemo/Bus Creator');
        busCreatorDlgObj.setWidgetValue('bcSignalsTree','bus1/Chirp');
        busCreatorDlgObj.setWidgetValue('bcSignalsTree','bus2/Pulse');

    case 'step9_85', % Select the Pulse signal
		%---Get demo up to the point where a matrix has been entered
		if ~BUSDEMO_STEP_COUNTER(10),
			busdemoscript('step9_5');
        end
        busCreatorDlgObj = FindDdgDlgInDAStudioRootFromFullBlkPath('busdemo/Bus Creator');
        busCreatorDlgObj.setWidgetValue('bcSignalsTree','bus2/Pulse');
        
    case 'step9_90', % Press the Find button
		%---Get demo up to the point where a matrix has been entered
		if ~BUSDEMO_STEP_COUNTER(10),
			busdemoscript('step9_5');
        end	
        busCreatorDlgObj = FindDdgDlgInDAStudioRootFromFullBlkPath('busdemo/Bus Creator');
        busCreatorddg_cb(busCreatorDlgObj,'doFind');
        
	case 'step10',
		BUSDEMO_STEP_COUNTER(11)=1;
		%---Get demo up to the point where a matrix has been entered
		if ~BUSDEMO_STEP_COUNTER(10),
			busdemoscript('step9_5');
		end	
        hilite_system(sprintf('%s\n%s','busdemo/Pulse','Generator'),'none');
        open_system(find_system('busdemo','BlockType','BusSelector'));
		
        case 'step10_5',
        %---Get demo up to the point where the Bus Selector is open
		if ~BUSDEMO_STEP_COUNTER(11),
			busdemoscript('step10');
        end	
        busSelectorDlgObj = FindDdgDlgInDAStudioRootFromFullBlkPath('busdemo/Bus Selector');
        busSelectorDlgObj.setWidgetValue('bcInputsTree','bus1/Chirp');
        pause(1); % For animation
        busSelectorDlgObj.setWidgetValue('bcInputsTree','bus2/Pulse');
        pause(1); % For animation
        
	case 'step11',
		BUSDEMO_STEP_COUNTER(12)=1;
		if ~BUSDEMO_STEP_COUNTER(11),
			busdemoscript('step10');
		end	
		
		% Animate the steps in this piece of the demo.
        busSelectorDlgObj = FindDdgDlgInDAStudioRootFromFullBlkPath('busdemo/Bus Selector');
        busSelectorDlgObj.setWidgetValue('bcOutputsList',1);
        pause(1); % For animation
        busCreatorddg_cb(busSelectorDlgObj,'doRemove');
        busSelectorDlgObj.setWidgetValue('bcOutputsList',0);
        pause(1); % For animation
    
	case 'step12',
		BUSDEMO_STEP_COUNTER(13)=1;
		if ~BUSDEMO_STEP_COUNTER(11),
			busdemoscript('step10');
		end	
		
		% Animate the steps in this piece of the demo.
        busSelectorDlgObj = FindDdgDlgInDAStudioRootFromFullBlkPath('busdemo/Bus Selector');
        busSelectorDlgObj.setWidgetValue('bcInputsTree','');
        busSelectorDlgObj.setWidgetValue('bcInputsTree','');
        busSelectorDlgObj.setWidgetValue('bcInputsTree','bus2/Sine');
		pause(0.75)
		
		% 2) Simulate adding the signal to the Selected signal list
		busCreatorddg_cb(busSelectorDlgObj,'doSelect');
        
	case 'step13',
		BUSDEMO_STEP_COUNTER(14)=1;
		if ~BUSDEMO_STEP_COUNTER(13),
			busdemoscript('step12');
        end	
        busSelectorDlgObj = FindDdgDlgInDAStudioRootFromFullBlkPath('busdemo/Bus Selector');
        busSelectorDlgObj.apply;
        close_system('busdemo/Bus Selector');
        
	case 'step14',
		% Final run of the diagram
		if ~BUSDEMO_STEP_COUNTER(14),
			busdemoscript('step13');
		end	
		sim('busdemo'); 
		
	case 'update',
		type = varargin{2};
		switch type
		case 'vector',
			% Make sure the Sine Wave contains a vector param
			if ~BUSDEMO_STEP_COUNTER(7),
				busdemoscript('step7');
			end	
		case 'matrix',
			% Make sure the up to step 9 is done
			if ~BUSDEMO_STEP_COUNTER(9),
				busdemoscript('step9');
			end	
		end
		set_param('busdemo','SimulationCommand','update')
		
	case 'hiliteblock'
		%---hilite appropriate blocks
		blockName = varargin{2};
		b=find_system('busdemo','Type','block');
		
		% Hilite the specific block for 2 seconds
		hilite_system(['busdemo/',blockName],'find')
		pause(2)	
		hilite_system(['busdemo/',blockName],'none')
		
	otherwise
		warning('The requested action could not be taken.')
		
	end	 % switch action
catch
	warndlg({'There was an error executing the link you selected.';
		'Please, restart the demonstration as additional links ';
		'may be broken due to this problem.';
		'';
		'To avoid future errors, please run the links in the order ';
		'in which they occur in the demo.'})
end % Try/catch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ddgDlgObjHdl = FindDdgDlgInDAStudioRootFromFullBlkPath(blkName)
ddgDlgObjHdl = [];

if isempty(blkName)
    return;
end

ddgDlgRoot = DAStudio.ToolRoot;
openDlgs   = ddgDlgRoot.getOpenDialogs;

for idx = 1:length(openDlgs)
  cleanName = strrep(openDlgs(idx).getDialogSource.getBlock.getFullName,sprintf('\n'),' ');
  if strcmp(cleanName,blkName)
        ddgDlgObjHdl = openDlgs(idx);
        break;
    end
end