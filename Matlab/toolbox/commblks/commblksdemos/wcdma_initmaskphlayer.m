function varargout = wcdma_initmaskphlayer(block, action, varargin)
% WCDMA_INITMASKPHLAYER Sets up workspace variables for the 
% Wcdmaphlayer model included in the Wcdma application examples.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.2.4.3 $  $Date: 2004/04/12 23:02:07 $

%-- Disable changes when the simulation is not stopped
if ~strcmp(get_param(bdroot(block),'simulationstatus'),'stopped')
    
    % Init variables
    eStr.emsg=[];
    eStr.emsg_w =[];

    varargout{1} = eStr;
    return;
end

s = 'wcdma_initmaskphlayer';

%**************************************************************************
% --- Action switch -- Determines which of the callback functions is called
%**************************************************************************
switch(action)
    
%*********************************************************************
% Function Name:     init
% Description:       Main initialization code
%********************************************************************
case 'init'
    
    Vals = get_param(block, 'MaskValues');
    
    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
    
    nameBlk = find_system(bdroot(block),'Regexp','on','Name','\<Channel Models\>');
    if(~isempty(nameBlk))
        if(strcmp(Vals{idxPropConditions},'No Channel'))   % No Channel
            set_param([bdroot(block) '/Wcdma Channel Models'],'BlockChoice','No Channel');
            
        elseif(strcmp(Vals{idxPropConditions},'Static - AWGN'))   % Static Case   
            set_param([bdroot(block) '/Wcdma Channel Models'],'BlockChoice','AWGN');
            
        else % Multipath Case
            set_param([bdroot(block) '/Wcdma Channel Models'],'BlockChoice','Multipath+AWGN');
        end
    end
    
    % --- Set Init Values
    eStr = setInitValues(block);
       
    % --- Return without error
    varargout{1} = eStr;

%*********************************************************************
% Function Name:     cbShowTrCh
% Description:       
%********************************************************************    
case 'cbShowTrCh'
    
    % -- Get variables from mask
    En   = get_param(block, 'MaskEnables');
    Vis  = get_param(block, 'MaskVisibilities');
    Vals = get_param(block, 'MaskValues');
    
    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
    
    % -- Set Visibilities
    switch(Vals{idxShowTrCh})
        
    case 'on' %User Defined : All options enable and visible
        if(strcmp(Vals{idxMeasurChannel},'User Defined'))
            
            idxOn = [idxMeasurChannel idxTrBlkSetSize idxTrBlkSize idxTti idxCrcSize idxErrorCorr ...
                    idxRMAttribute idxPosTrChMask idxNumPhCH idxSlotFormat];
                
            [En{idxOn}, Vis{idxOn}]  = deal('on');
                
        else % Predefined Cases : All options are visible but only Measurement channel is enable
            idxEnOff = [idxTrBlkSetSize idxTrBlkSize idxTti idxCrcSize idxErrorCorr ...
                        idxRMAttribute idxPosTrChMask idxNumPhCH idxSlotFormat];
            idxVisOn = [idxMeasurChannel idxEnOff];
                    
            [En{idxMeasurChannel}, Vis{idxVisOn}]  = deal('on');
            [En{idxEnOff}]  = deal('off');
        end
                
    case 'off'
        
        idxOff = [idxMeasurChannel idxTrBlkSetSize idxTrBlkSize idxTti idxCrcSize idxErrorCorr ...
                    idxRMAttribute idxPosTrChMask idxNumPhCH idxSlotFormat];
                
        [En{idxOff}, Vis{idxOff}]  = deal('off');
    end
    
    % --- Update parameters
    set_param(block,'MaskVisibilities', Vis, 'MaskEnables', En);

%*********************************************************************
% Function Name:     cbMeasurChannel
% Description:       Depending on the variable measurChannel,
%                       preloads variables according to the 3GPP TS 25.101 specs. 
% Return Values:     None
%********************************************************************
case 'cbMeasurChannel'   
    
    % -- Get variables from mask
    Vals = get_param(block, 'maskvalues');
    En   = get_param(block, 'MaskEnables');
    Vis  = get_param(block, 'MaskVisibilities');

    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
    
    % -- Set visibilities
    idxEn  = [idxTrBlkSetSize idxTrBlkSize idxTti idxCrcSize idxErrorCorr ...
            idxRMAttribute idxPosTrChMask idxNumPhCH idxSlotFormat];
        
    [En{idxEn}]  = deal('off');
        
    % -- Preload parameters
    switch(Vals{idxMeasurChannel})
        
    case '12.2 Kbps'
                
        Vals{idxTrBlkSetSize}    = '[244 100]';
        Vals{idxTrBlkSize}       = '[244 100]';
        Vals{idxTti}             = '[20 40]';
        Vals{idxCrcSize}         = '[16 12]';
        Vals{idxErrorCorr}       = '[2 2]';
        Vals{idxRMAttribute}     = '[256 256]';
        Vals{idxPosTrChMask}     = 'Fixed';
        Vals{idxNumPhCH}         = '1'; 
        Vals{idxSlotFormat}      = '11';        
        Vals{idxDpchCode}        = '127';
        
        
    case '64 Kbps'
        
        Vals{idxTrBlkSetSize}    = '[1280 100]';
        Vals{idxTrBlkSize}       = '[1280 100]';
        Vals{idxTti}             = '[20 40]';
        Vals{idxCrcSize}         = '[16 12]';
        Vals{idxErrorCorr}       = '[3 2]';
        Vals{idxRMAttribute}     = '[256 256]';
        Vals{idxPosTrChMask}     = 'Fixed';
        Vals{idxNumPhCH}         = '1'; 
        Vals{idxSlotFormat}      = '13';
        Vals{idxDpchCode}        = '31';
        
        
    case '144 Kbps'

        Vals{idxTrBlkSetSize}    = '[2880 100]';
        Vals{idxTrBlkSize}       = '[2880 100]';
        Vals{idxTti}             = '[20 40]';
        Vals{idxCrcSize}         = '[16 12]';
        Vals{idxErrorCorr}       = '[3 2]';
        Vals{idxRMAttribute}     = '[256 256]';
        Vals{idxPosTrChMask}     = 'Fixed';
        Vals{idxNumPhCH}         = '1'; 
        Vals{idxSlotFormat}      = '14';
        Vals{idxDpchCode}        = '15';        
       
    case '384 Kbps'

        Vals{idxTrBlkSetSize}    = '[3840 100]';
        Vals{idxTrBlkSize}       = '[3840 100]';
        Vals{idxTti}             = '[10 40]';
        Vals{idxCrcSize}         = '[16 12]';
        Vals{idxErrorCorr}       = '[3 2]';
        Vals{idxRMAttribute}     = '[256 256]';
        Vals{idxPosTrChMask}     = 'Fixed';
        Vals{idxNumPhCH}         = '1'; 
        Vals{idxSlotFormat}      = '15';
        Vals{idxDpchCode}        = '7';
            
    case 'User Defined'     
        % -- Update the Mask Parameters
        [En{idxEn}]  = deal('on');
            
    end
    set_param(block,'MaskValues',Vals,'MaskVisibilities', Vis, 'MaskEnables', En);
    

%*********************************************************************
% Function Name:     cbShowAntenna
% Description:       
%********************************************************************    
case 'cbShowAntenna'
    
    % -- Get variables from mask
    En   = get_param(block, 'MaskEnables');
    Vis  = get_param(block, 'MaskVisibilities');
    Vals = get_param(block, 'MaskValues');
    
    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
    
    % -- Set Visibilities
    switch(Vals{idxShowAntenna})
        
    case 'on'
        idxOn = [idxDpchCode idxScrCode idxNumTapsRRC idxNumTapsChEst idxOverSampling];
        [En{idxOn}, Vis{idxOn}]  = deal('on');
        
    case 'off'
        idxOff = [idxDpchCode idxScrCode idxNumTapsRRC idxNumTapsChEst idxOverSampling];
        [En{idxOff}, Vis{idxOff}]  = deal('off');        
    end
    
    % --- Update parameters
    set_param(block,'MaskVisibilities', Vis, 'MaskEnables', En);
        
%*********************************************************************
% Function Name:     cbShowChModel
% Description:       
%********************************************************************    
case 'cbShowChModel'
    
    % -- Get variables from mask
    En   = get_param(block, 'MaskEnables');
    Vis  = get_param(block, 'MaskVisibilities');
    Vals = get_param(block, 'MaskValues');
    
    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
    
    % -- Set Visibilities
    switch(Vals{idxShowChModel})
        
    case 'on'
        
        if(strcmp(Vals{idxPropConditions},'No Channel')) 
            % All options are visible but disable
            idx = [idxFingerPhases idxFingerPowers idxFingerEnables idxSpeed idxSnrdB];
            [Vis{[idx idxPropConditions]}, En{idxPropConditions}]  = deal('on');
            [En{idx}]  = deal('off');

        elseif(strcmp(Vals{idxPropConditions},'User Defined')) 
            % All options are visible and enable
            idxOn = [idxPropConditions idxFingerPhases idxFingerPowers idxFingerEnables idxSpeed idxSnrdB];
            [En{idxOn}, Vis{idxOn}]  = deal('on');
        else
            % All options are visible but only idxPropConditions and snrdB is enable
            idx = [idxFingerPhases idxFingerPowers idxFingerEnables idxSpeed];
            [En{[idxPropConditions idxSnrdB]}, Vis{[idxPropConditions idxSnrdB idx]}]  = deal('on');
            [En{idx}]  = deal('off');
        end
        
    case 'off'
        idxOff = [idxPropConditions idxFingerPhases idxFingerPowers idxFingerEnables idxSpeed idxSnrdB];
        [En{idxOff}, Vis{idxOff}]  = deal('off');        
    end
    
    % --- Update parameters
    set_param(block,'MaskVisibilities', Vis, 'MaskEnables', En);
        
%************************************************************************
% Function Name:     cbPropConditions
% Description:       Sets Multipath Profiles according to specifications
%************************************************************************    
case 'cbPropConditions'
    
    % -- Get variables from mask
    Vals = get_param(block, 'maskvalues');
    En   = get_param(block, 'MaskEnables');
    Vis  = get_param(block, 'MaskVisibilities');
    
    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
    
    % -- Set Visibilities
    idx = [idxFingerPhases idxFingerPowers idxFingerEnables idxSpeed];
    
    % -- Update the Mask Parameters
    [En{idx}]  = deal('off');
        
    nameBlk = find_system(gcs,'Regexp','on','Name','\<Channel Models\>');
    if(~isempty(nameBlk))
        if(strcmp(Vals{idxPropConditions},'No Channel'))   % No Channel
            set_param([gcs '/Wcdma Channel Models'],'BlockChoice','No Channel');
            
        elseif(strcmp(Vals{idxPropConditions},'Static - AWGN'))   % Static Case   
            set_param([gcs '/Wcdma Channel Models'],'BlockChoice','AWGN');
            
        else % Multipath Case
            set_param([gcs '/Wcdma Channel Models'],'BlockChoice','Multipath+AWGN');
        end
    end
    
    % -- Preload  Parameters
    switch(Vals{idxPropConditions})  
        
    case 'No Channel'
        Vals{idxFingerPhases}       = '0'; 
        Vals{idxFingerPowers}       = '0';
        Vals{idxFingerEnables}      = '1';
        Vals{idxSpeed}              = '0';
        Vals{idxSnrdB}              = 'Inf';
        
        % Disable Snr parameter
        [En{idxSnrdB}] = deal('off');
        
        
    case 'Static - AWGN'
        Vals{idxFingerPhases}       = '0'; 
        Vals{idxFingerPowers}       = '0';
        Vals{idxFingerEnables}      = '1';
        Vals{idxSpeed}              = '0';  
        if(strcmp(Vals{idxSnrdB},'Inf'))
            Vals{idxSnrdB} = '-1';
        end
        
        % Enable Snr parameter
        [En{idxSnrdB}] = deal('on');
        
    case 'Multipath Profile - Case 1'
        Vals{idxFingerPhases}       = '[0 976e-9]'; 
        Vals{idxFingerPowers}       = '[0 -10]';
        Vals{idxFingerEnables}      = '2';
        Vals{idxSpeed}              = '3';
        if(strcmp(Vals{idxSnrdB},'Inf'))
            Vals{idxSnrdB} = '9';
        end
        
        % Enable Snr parameter
        [En{idxSnrdB}] = deal('on');
        
    case 'Multipath Profile - Case 2'
        Vals{idxFingerPhases}       = '[0 976e-9 20000e-9]'; 
        Vals{idxFingerPowers}       = '[0 0 0]';
        Vals{idxFingerEnables}      = '3';
        Vals{idxSpeed}              = '3';
        if(strcmp(Vals{idxSnrdB},'Inf'))
            Vals{idxSnrdB} = '-3';
        end
        
        % Enable Snr parameter
        [En{idxSnrdB}] = deal('on');
        
    case 'Multipath Profile - Case 3'
        Vals{idxFingerPhases}       = '[0 260e-9 521e-9 781e-9]'; 
        Vals{idxFingerPowers}       = '[0 -3 -6 -9]';
        Vals{idxFingerEnables}      = '4';
        Vals{idxSpeed}              = '120';
        if(strcmp(Vals{idxSnrdB},'Inf'))
            Vals{idxSnrdB} = '-3';
        end
        
        % Enable Snr parameter
        [En{idxSnrdB}] = deal('on');
        
    case 'Multipath Profile - Case 4'
        Vals{idxFingerPhases}       = '[0 976e-9]'; 
        Vals{idxFingerPowers}       = '[0 0]';
        Vals{idxFingerEnables}      = '2';
        Vals{idxSpeed}              = '3';
        if(strcmp(Vals{idxSnrdB},'Inf'))
            Vals{idxSnrdB} = '-3';
        end
        
        % Enable Snr parameter
        [En{idxSnrdB}] = deal('on');
        
    case 'Multipath Profile - Case 5'
        Vals{idxFingerPhases}       = '[0 976e-9]'; 
        Vals{idxFingerPowers}       = '[0 -10]';
        Vals{idxFingerEnables}      = '2';
        Vals{idxSpeed}              = '50';
        if(strcmp(Vals{idxSnrdB},'Inf'))
            Vals{idxSnrdB} = '-3';
        end
        
        % Enable Snr parameter
        [En{idxSnrdB}] = deal('on');
        
    case 'Multipath Profile - Case 6'
        Vals{idxFingerPhases}       = '[0 260e-9 521e-9 781e-9]'; 
        Vals{idxFingerPowers}       = '[0 -3 -6 -9]';
        Vals{idxFingerEnables}      = '4';
        Vals{idxSpeed}              = '250';
        if(strcmp(Vals{idxSnrdB},'Inf'))
            Vals{idxSnrdB} = '-3';
        end
        
        % Enable Snr parameter
        [En{idxSnrdB}] = deal('on');
        
    case 'User Defined'     
        
        % -- Update the Mask Parameters
        [En{[idx idxSnrdB]}]  = deal('on');
             
    end    
    
    set_param(block,'MaskValues',Vals,'MaskVisibilities', Vis, 'MaskEnables', En);
    
 
%*********************************************************************
% Function Name:     default
% Description:       Define visiablity, enable and values of variables for default case.
%                       It also sets the callback functions for propSelect and measurChannel.
% Return Values:     None
%********************************************************************   
case 'default'
   
    % --- Field data
    Vals = get_param(block, 'MaskValues');
    Vis  = get_param(block, 'MaskVisibilities');
    En   = get_param(block, 'MaskEnables');
    
    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
     
    % -- Set Enable
    [En{[1:length(En)]}]  = deal('on');
       
    % --- Set Visibility 
    idxOn = [idxShowTrCh idxShowAntenna idxShowChModel idxPowerVector];
    
    [Vis{[1:length(Vis)]}]  = deal('off');
    [Vis{idxOn}]  = deal('on');
    
    % --- Set Callback functions
    
    [Cb{[1:length(En)]}]        = deal('');
    Cb{idxShowTrCh} 		    = [s '(gcb,''cbShowTrCh'');'];
    Cb{idxShowAntenna} 		    = [s '(gcb,''cbShowAntenna'');'];
    Cb{idxShowChModel} 		    = [s '(gcb,''cbShowChModel'');'];
    Cb{idxMeasurChannel} 		= [s '(gcb,''cbMeasurChannel'');'];
    Cb{idxPropConditions} 		= [s '(gcb,''cbPropConditions'');'];
        
    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);
    
    % --- Set the startup values.  '' Indicates that the default saved will be used
    Vals{idxShowTrCh}           = 'off';
    Vals{idxShowAntenna}        = 'off'; 
    Vals{idxShowChModel}        = 'off'; 
    Vals{idxMeasurChannel}      = '12.2 Kbps';
    Vals{idxPropConditions}     = 'Static - AWGN';
    Vals{idxSnrdB}         		= '-1';
    Vals{idxTrBlkSetSize}  	    = '[244*1 100*1]';
    Vals{idxTrBlkSize}   	  	= '[244 100]';
    Vals{idxTti}           		= '[20 40]';
    Vals{idxCrcSize}       		= '[16 12]';
    Vals{idxErrorCorr}     		= '[2 2]';
    Vals{idxRMAttribute}    	= '[256 256]';
    Vals{idxPosTrChMask}    	= 'Fixed';
    Vals{idxNumPhCH}      	    = '1';
    Vals{idxSlotFormat}     	= '11';   
    Vals{idxDpchCode} 		    = '123';
    Vals{idxScrCode}       	    = '[63 0]';
    Vals{idxPowerVector}		= '[-16.6 -10 -15 -12 -12]';
    Vals{idxNumTapsRRC}		    = '96';
    Vals{idxNumTapsChEst}       = '21';
    Vals{idxOverSampling}  		= '8';
    Vals{idxFingerEnables}	    = '1';
    Vals{idxFingerPhases}  		= '[0 0 0 0]';
    Vals{idxFingerPowers}       = '0';
    Vals{idxSpeed}              = '0';
    
    % --- Update the Vals field with the actual values
    MN = get_param(block,'MaskNames');
    for n=1:length(Vals)
        set_param(block,MN{n},Vals{n});        
    end;
    
    % --- Ensure that the block operates correctly from a library
    set_param(block,'MaskSelfModifiable','on');
    
    % --- Set Init Values
    eStr = setInitValues(block)
    
    % --- Return parameters
    varargout{1} = eStr;
      
    
%*********************************************************************
% Function Name:     show all
% Description:       Show all of the widgets.
% Notes:             This function is for development use only and allows
%                       All fields to be displayed
%********************************************************************  
case 'showall'
    
    Vis = get_param(block, 'maskvisibilities');
    En  = get_param(block, 'maskenables');
    
    for n=1:length(Vis)
        Vis{n} = 'on';
        En{n} = 'on';
    end
    
    % --- Initialize output parameters, exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';

    varargout{1} = eStr;
        
    set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
    
end
%*********************************************************************
% Function Name:     setInitValues
% Description:       This function gets all the variables from the mask, 
%                       computes intermediated variables and finally 
%                       assigns them to the base Workspace
%********************************************************************  
function eStr = setInitValues(block)
	
	% Reset variables
	msg='';
	msg_warn='';
        
	% Get Mask values    
	Vals = get_param(block, 'maskvalues');
	setfieldindexnumbers(block);
	
	%--- Get Variables from mask
	trBlkSetSize = str2num(Vals{idxTrBlkSetSize});
	trBlkSize = str2num(Vals{idxTrBlkSize});
	tti = str2num(Vals{idxTti});
	crcSize = str2num(Vals{idxCrcSize});
	errorCorr = str2num(Vals{idxErrorCorr});
	RMAttribute = str2num(Vals{idxRMAttribute});
	posTrChMask = Vals{idxPosTrChMask};
	numPhCH = str2num(Vals{idxNumPhCH}); 
	slotFormat = str2num(Vals{idxSlotFormat});
	dpchCode = str2num(Vals{idxDpchCode});
	scrCode = str2num(Vals{idxScrCode});
	powerVector = str2num(Vals{idxPowerVector});
	fingerPhases = str2num(Vals{idxFingerPhases});
	fingerPowers = str2num(Vals{idxFingerPowers});
	fingerEnables = str2num(Vals{idxFingerEnables});
	numTapsRRC = str2num(Vals{idxNumTapsRRC});
	numTapsChEst = str2num(Vals{idxNumTapsChEst});
	overSampling = str2num(Vals{idxOverSampling});
	snrdB = str2num(Vals{idxSnrdB});
	speed = str2num(Vals{idxSpeed});
	
	%--- Turbo Coding is not currently supported
	errorCorrMask = errorCorr;
	errorCorr = (errorCorr>2)*2 + (errorCorr<3).*errorCorr;
	
	%--- Modify Variable Mask
	if(posTrChMask == 'Fixed')
        posTrCh = 0;
	else
        posTrCh = 1;
	end
	
	%--- Compute Intermediate variables
	numTrBlks = trBlkSetSize./trBlkSize;
	[numBitsTrCh, numPadBits, numCodeWords, numBitsCodeWord] = wcdma_concseg(trBlkSetSize,trBlkSize,crcSize, errorCorr);
	codeRate = errorCorr+1 - (errorCorr == 3);
	tailBits = 8 *(errorCorr ~=0);
	numBitsRM = codeRate.*(numBitsCodeWord+tailBits).*numCodeWords;
	
	deltaNimax = wcdma_ratematchinginit(numBitsRM, tti, RMAttribute, posTrCh, slotFormat, numPhCH);
	numBitsFirstInt = numBitsRM + deltaNimax;
	
	numBitsRF = numBitsFirstInt./(tti/10);
	totalBitsDelay = 2.*trBlkSetSize + 2.*trBlkSetSize.*(numCodeWords>1).*(tti~=10) + 2.*(tti==10 & numCodeWords>1).*trBlkSetSize;
	
	%--- Set Channel model variables
	fingerEnables = [ones(1,fingerEnables) zeros(1,4-fingerEnables)];
	dopplerFreq = (speed*1e3/3600)*2.1e9/3e8;
	if(strcmp(Vals{idxPropConditions},'Static - AWGN'))
        enableMultipath = 0;
	else
        enableMultipath = 1;
	end
        
	
	%--- Compute Total Received Delay
	if slotFormat < 2
        numChipsOut = 512;
	else
        numChipsOut = 256;
	end
	
	load wcdma_slotformattable;
	% Second Column of slotformattable corresponds to SF
	sprdFactor = slotformattable(slotFormat+1,2);
	% Third Column of slotformattable corresponds to NumBits
	numBits = slotformattable(slotFormat+1,3);
	% Eigth Column of slotformattable corresponds to TPC Bits
	numPilotBits = slotformattable(slotFormat+1,8);
	
	% Compute Total Received Delay
	latestPath = max(fingerPhases);
	filtDelayChEst = (numTapsChEst-1)/2;
	rxDelayinFrames = ceil(((numTapsRRC/overSampling)+latestPath)/numChipsOut) + filtDelayChEst;
	rxDelay = rxDelayinFrames * (numChipsOut/sprdFactor);
	rxSlotsDelay = ceil(rxDelay*2/numBits);
	
	% TPC Bits
	pilotBits = wcdma_pilotbitgenerator(numPilotBits);
	
	% --- Assigin Variables to workspace
	assignin('base','trBlkSize',trBlkSize);
	assignin('base','trBlkSetSize',trBlkSetSize);
	assignin('base','numTrBlks',numTrBlks);
	assignin('base','tti',tti);
	assignin('base','crcSize',crcSize);
	assignin('base','errorCorr',errorCorr);
	assignin('base','errorCorrMask',errorCorrMask);
	assignin('base','RMAttribute',RMAttribute);
	assignin('base','posTrCh',posTrCh);
	assignin('base','numPhCH',numPhCH);
	assignin('base','slotFormat',slotFormat);
	assignin('base','numBitsRF',numBitsRF);
    assignin('base','numBitsRM',numBitsRM);
	
	% Antenna Settings
	assignin('base','sprdFactor',sprdFactor);
	assignin('base','dpchCode',dpchCode);
	assignin('base','scrCode',scrCode);
	assignin('base','powerVector',powerVector);
	assignin('base','numTapsRRC',numTapsRRC);
	assignin('base','overSampling',overSampling);
	assignin('base','fingerEnables',fingerEnables);
	assignin('base','numTapsChEst',numTapsChEst);
	assignin('base','pilotBits',pilotBits);
	
	% Channel Settings
    assignin('base','snrdB', snrdB);
    assignin('base','enableMultipath', enableMultipath);
    assignin('base','propConditions', Vals{idxPropConditions}); 
    assignin('base','fingerPhases',fingerPhases);
    assignin('base','fingerPowers',fingerPowers);
    assignin('base','dopplerFreq',dopplerFreq);
    
	
	% Ber Settings
	assignin('base','totalBitsDelay',totalBitsDelay);
	
	% Check parameters
	wcdma_checkparamsphlayer;
	eStr.emsg  = msg;
	eStr.emsg_w = msg_warn;
	
	% end of wcdma_initmaskphlayer.m