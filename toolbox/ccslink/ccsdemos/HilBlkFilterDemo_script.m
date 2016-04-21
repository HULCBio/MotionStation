function HilBlkFilterDemo_script(action)
% Implements gui actions for HIL Block Filter Demo.
% action can be 'loadProg' or 'viewResults'.
% The user must click the button in the model to do loadProg,
% but the model's StopFcn property specifies that the 
% viewResults action will be performed automatically at the
% end of the simulation.

% $Revision: 1.1.6.1 $ $Date: 2004/04/08 20:45:31 $
% Copyright 2001-2003 The MathWorks, Inc.

sys = gcs;

switch action
    
    case 'loadProg',
        
        % loads the appropriate '.out' file for the Hardware-In-The-Loop Block demo.
        % It first queries the Hardware-In-The-Loop(HIL) block to find the target
        % processor selected. It then verifies that this board is set up in Code Composer Studio,
        % and then creates a link to Code Composer Studio for the specified target.
        
        info1 = ccsboardinfo;
        
        % Query HIL block for target processor
        hil_blks = find_system(sys,'BlockType','S-Function','MaskType','Hardware-in-the-Loop Function Call');
        found = 0;
        
        % Try to find a match for selected target and configured boards
        for i=1:length(hil_blks)
            hil_info = get_param(hil_blks{i},'UserData');
            % For each board set up in each HIL block, check if CCS is configured for that board
            for j=1:length(info1)
                if(strcmp(info1(j).name,hil_info.boardName)==1)
                    disp('Creating CCS Link object ...')
                    cc = ccsdsp('boardnum',info1(j).number,'procnum',info1(j).proc.number);
                    found = 1;
                    break;
                end
            end
        end
        
        cc.visible(1);
        
        % If no match is found
        if (found==0)
            errordlg(sprintf(['Unable to find the board specified in the HIL Block.\n',...
                    'Please make sure the HIL Block is configured for the correct board and that the ' ...
                    'selected board is configured in Code Composer Studio(R) Setup.']),...
                'Board not found','modal');
            return;
        end
        
        % Load '.out' file depending on the target processor selected
        ccinfo = cc.info;
        if ccinfo.family~=320,
            errordlg('Cannot run demo on this processor. Processor is not supported.','Processor not supported','modal');
            return;
        end
        
        projdir = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','hilblkfilter');
        if ccinfo.isbigendian,
            endianSuffix = 'e';
        else
            endianSuffix = '';
        end
        if ccinfo.subfamily == 100 
            projdir = fullfile(projdir,['c64xx' endianSuffix]);
        elseif ccinfo.subfamily >= 96 && ccinfo.subfamily < 112 
            projdir = fullfile(projdir,['c62xx' endianSuffix]);
        elseif ccinfo.subfamily == 84
            projdir = fullfile(projdir,'c54xx');
        elseif ccinfo.subfamily == 40
            projdir = fullfile(projdir,'c28xx');
        else
            errordlg('Cannot run demo on this processor. Processor is not supported.','Processor not supported','modal');
            return;
        end
        
        % Open project file and corresponding program file
        disp('Loading project and COFF file ...')
        cc.cd(projdir);
        try 
            open(cc,'FilterFFT.pjt','project',30);
        end
        load(cc,'FilterFFT.out',30);
        disp('Ready to simulate model.')
        
    case 'viewResults',
        
        persistent FigureHandle;
        if ~isempty(FigureHandle) && ishandle(FigureHandle),
            close(FigureHandle);
        end
        FigureHandle = figure;
        
        try
            filterInput = evalin('base','filterInput');
            filterOutput = evalin('base','filterOutput');
            filterOutputSim = evalin('base','filterOutputSim');
        catch 
            errordlg('Results not available');    
            return;   
        end 
        
        % Convert signal to non-fixed-point   
        filterInput_double = double(filterInput(66:end))/(2^15);   
        % Plot input signal
        t = (0:127)'/8000; 
        set(FigureHandle,'position',[200 150 550 500])  
        subplot(2,1,1);  
        plot(t,filterInput_double,'r');
        axis([0 t(128) -1 1]); 
        plotTitle = ['Input signal']; 
        title(plotTitle);
        grid on;  
        
        % Convert filter output to non-fixed-point   
        filterOutput_double = double(filterOutput)/(2^15);  
        % Plot filter output
        subplot(2,1,2);  
        plot(t,filterOutput_double,'ro'); hold on;
        plot(t,filterOutputSim,'b.'); hold off;
        axis([0 t(128) -1 1]); 
        plotTitle = ['Filter output computed by DSP(red), MATLAB(blue)']; 
        title(plotTitle);
        grid on;  
        
        
end

% EOF
