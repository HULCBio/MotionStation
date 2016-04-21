function fileName = generateHTML_TItarget(S,P,profileTime)
% Generate custom HTML for this profile report and export to a file in the
% tempdir.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:07:54 $
% Copyright 2001-2004 The MathWorks, Inc.

title = 'Profile Report';

% Populate text buffer with lines 
% (to be written out later, all at once)
TXT{1}     = '<!doctype html public "-//w3c//dtd html 4.0 transitional//en">';
TXT{end+1} = '<html>';
TXT{end+1} = '<head>';
TXT{end+1} = '   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">';
TXT{end+1} =['   <title>' title ' </title>'];
TXT{end+1} = '</head>';
TXT{end+1} = '<body text="#000000" bgcolor="#FFFFFF" link="#0000EE" vlink="#551A8B" alink="#FF0000">';
TXT{end+1} = '<center><b><font size=+3>';
TXT{end+1} = title;
TXT{end+1} = '<br></font></b>';
TXT{end+1} = '<br><font><b>';
if S.containsSimulinkSystems,
    TXT{end+1} = ['Simulink model: ' ...
            '<A href = "matlab:try,open_system(''' S.modelName ''')' ...
            ',end">' S.modelName '.mdl</A><br>'];
    TXT{end+1} = ['Target: <b>' S.OrigBoardType '</b><br>'];
end
TXT{end+1} = '<br></b></font>';
%TXT{end+1} = 'MATLAB Link for Code Composer Studio(R) Development Tools<br>';
TXT{end+1} = 'Report of profile data from Texas Instruments (tm) Code Composer Studio<br>';
TXT{end+1} = [datestr(profileTime) '<br>'];
TXT{end+1} = '</center>';

if S.validData & S.containsSimulinkSystems,
    
    % Overall scheduling data 
    TXT{end+1} = '<br><hr><br>';
    TXT{end+1} = '<center><b><font size=+1>';
    TXT{end+1} = 'Timing constants <br><br>';
    TXT{end+1} = '</font></b>';
    TXT{end+1} = '<table BORDER CELLPADDING=2>';
    TXT{end+1} = '<tr>';
    TXT{end+1} = '<td><b>Base sample time</b></td>';
    TXT{end+1} = ['<td>' timeFmt(S.timeBetweenInterrupts) '</td>'];
    TXT{end+1} = '</tr>';
    TXT{end+1} = '<tr>';
    TXT{end+1} = '<td><b>CPU Clock speed</b><sup>1</sup></td>';
    TXT{end+1} = ['<td>' num2str(S.CpuClkSpeed/1e6) ' MHz</td>'];
    TXT{end+1} = '</tr>';
    TXT{end+1} = '</table></center>';
    TXT{end+1} = '<br>';
    if ~S.isMultiTasking
        % Overall CPU Stats
        TXT{end+1} = '<br><hr><br>';
        TXT{end+1} = '<center><b><font size=+1>';
        TXT{end+1} = 'Overall CPU Statistics <br><br>';
        TXT{end+1} = '</font></b>';
        TXT{end+1} = '<table BORDER CELLPADDING=2>';
        %TXT{end+1} = '<tr>';
        %TXT{end+1} = '<td><b>Overrun</b></td>';
        %if S.overrun,
        %    TXT{end+1} = ['<td>yes</td>'];
        %else
        %    TXT{end+1} = ['<td>no</td>'];
        %end
        %TXT{end+1} = '</tr>';
        TXT{end+1} = '<tr>';
        TXT{end+1} = '<td><b>Critical headroom</b><sup>3</sup></td>';
        %if S.overrun,
        %    TXT{end+1} = ['<td>n/a</td>'];
        %else
            TXT{end+1} = ['<td>' timeFmt(S.criticalHeadroom) '</td>'];
        %end
        TXT{end+1} = '</tr>';
        %TXT{end+1} = '<tr>';
        %TXT{end+1} = '<td><b>Number of SWIs counted</b></td>';
        %TXT{end+1} = ['<td>' num2str(S.swi_count) '</td>'];
        %TXT{end+1} = '</tr>';
        TXT{end+1} = '</table></center>';
        TXT{end+1} = '<br>';
    end

end
% CPU Load is usually reported as zero... 
% user should view CPU Load Graph to get average over time.  
% TXT{end+1} = '<tr>';
% TXT{end+1} = '<td><b>CPU Load</b></td>';
% cpuLoadStr = percentFmt(P.cpuload);
% TXT{end+1} = ['<td>' cpuLoadStr '</td>'];
% TXT{end+1} = '</tr>';

invalidDataMsg = ['<br>Your application has not executed properly for ' ...
        'measurement of profile statistics.  No further results ' ...
        'can be reported.  Please execute a DSP/BIOS application ' ...
        'for a period of time before attempting to obtain profile ' ...
        'statistics. <br><br>'];

if ~S.validData,
    TXT{end+1} = invalidDataMsg;
else
    
    if S.containsSimulinkSystems,    
        
        srtOrder = sortSystemsByTime(S);
%         TXT{end+1} = '<br><hr><br>';
%        
%         TXT{end+1} = '<center><b><font size=+1>';
%         TXT{end+1} = 'Summary of Subsystem Profiling <br><br>';
%         TXT{end+1} = '</font></b>';
%         
%         TXT{end+1} = '<table BORDER CELLPADDING=2>';
%         TXT{end+1} = '<tr>';
%         TXT{end+1} = '<td><b>System Name</b></td>';
%         TXT{end+1} = '<td><b>Max time</b></td>';
%         TXT{end+1} = '<td><b>Max %</b></td>';
%         TXT{end+1} = '</tr>';
%         for k = 1:length(S.sys)
%             TXT{end+1} = '<tr>';
%             TXT{end+1} = '<td>';
%             TXT{end+1} = openSystemHyperlink(S.modelName, ...
%                 S.sys(srtOrder(k)).name, S.sys(srtOrder(k)).simName);
%             TXT{end+1} = '</td>';
%             TXT{end+1} = ['<td>' ...
%                     timeFmt(S.sys(srtOrder(k)).maxTime) '</td>'];
%             TXT{end+1} = ['<td>' ...
%                     percentFmt(S.sys(srtOrder(k)).maxPercentOfInterruptTime) ...
%                     '</td>'];
%             TXT{end+1} = '</tr>';
%         end
%         TXT{end+1} = '</table></center>';
%         TXT{end+1} = '<br><br>';
        
        TXT{end+1} = '<hr><br><center>';
        TXT{end+1} = '<b><font size=+1>';
        if length(S.sys)>1,  
            TXT{end+1} = 'Profiled Simulink Subsystems';
        else
            TXT{end+1} = 'Profiled Simulink Subsystem';
        end 
        TXT{end+1} = '<br><br></font></b>';
        
        for k = 1:length(S.sys)
            
            % Display the subsystem name with hyperlinks
            TXT{end+1} = '<table BORDER CELLPADDING=2 COLS=2 WIDTH="550">';
            TXT{end+1} = '<tr>';
            TXT{end+1} = '<td WIDTH="43%"><b><font size=+1>System name</font></b></td>';
            TXT{end+1} = '<td>';
            TXT{end+1} =  openSystemHyperlink( ...
                S.modelName, ...
                S.sys(srtOrder(k)).name,S.sys(srtOrder(k)).simName);
            TXT{end+1} = '</td>';
            TXT{end+1} = '</tr>';
            if S.sys(srtOrder(k)).OutputUpdateCombined,
                TXT{end+1} = '<tr>';
                TXT{end+1} = '<td><b>STS object</b></td>';
                TXT{end+1} = ['<td>' ...
                        P.obj(S.sys(srtOrder(k)).stsObj(1).P_index).name ...
                        '</td>'];
                TXT{end+1} = '</tr>';
            else
                TXT{end+1} = '<tr>';
                TXT{end+1} = '<td><b>STS objects</b></td>';
                TXT{end+1} = ['<td>' ...
                        P.obj(S.sys(srtOrder(k)).stsObj(1).P_index).name ...
                        ', ' ...
                        P.obj(S.sys(srtOrder(k)).stsObj(2).P_index).name ...
                        '</td>'];
                TXT{end+1} = '</tr>';
            end
            
            if S.sys(srtOrder(k)).validData,
                
                TXT{end+1} = '<tr>';
                TXT{end+1} = ['<td><b>Max time spent in this subsystem' ...
                        '<br>per interrupt</b></td>'];
                TXT{end+1} = ['<td>' ...
                        timeFmt(S.sys(srtOrder(k)).maxTime) '</td>'];
                    TXT{end+1} = '</tr>';
                    TXT{end+1} = '<tr>';
                    TXT{end+1} = ['<td><b>Max percent of base interval</b></td>'];
                    TXT{end+1} = ['<td>' ...
                            percentFmt(S.sys(srtOrder(k)).maxPercentOfInterruptTime) ...
                            '</td>'];
                    TXT{end+1} = '</tr>';
                    TXT{end+1} = '<tr>';
                    TXT{end+1} = ['<td><b>Number of iterations counted</b></td>'];
                    TXT{end+1} = ['<td>' ...
                            num2str(P.obj(S.sys(srtOrder(k)).stsObj(1).P_index).count) ...
                            '</td>'];
                    TXT{end+1} = '</tr>';
                else  % not valid data
                    TXT{end+1} = ['<tr><td>This system has not reported valid profile ' ...
                            'statistics.</td></tr>'];
                end
                TXT{end+1} = '</table><br><br>';
                
        end    % for k = 1:length(S.sys)
        
    end  % If S.containsSimulinkSubsystems

    TXT{end+1} = '</center>';
    
end  % S.validData

% Display raw STS data even if it is not "valid" (in which case the 
% raw data may clarify to the user why we said it's invalid)
TXT{end+1} = '<hr><br><center><b><font size=+1>';
TXT{end+1} = 'STS Objects<br>';
TXT{end+1} = '</b></font>';
TXT{end+1} = 'Raw profile data reported by Code Composer Studio<br><br>';
TXT{end+1} = '<br></center>';
TXT{end+1} = '<center>';
TXT{end+1} = '<table BORDER CELLPADDING=3>';
TXT{end+1} = '<tr>';
TXT{end+1} = '<td><b>STS Object Name</b></td>';
TXT{end+1} = '<td><b>count</b><br>(measurements)</td>';
TXT{end+1} = '<td><b>total</b></td>';
TXT{end+1} = '<td><b>max</b></td>';
TXT{end+1} = '<td><b>average</b></td>';
TXT{end+1} = '</tr>';
for k = 1:length(P.obj),
    TXT{end+1} = '<tr>';
    TXT{end+1} = ['<td>' P.obj(k).name '</td>'];
    TXT{end+1} = ['<td>' num2str(P.obj(k).count) '</td>'];
    TXT{end+1} = ['<td>' num2str(P.obj(k).total) '</td>'];
    TXT{end+1} = ['<td>' num2str(P.obj(k).max) '</td>'];
    TXT{end+1} = ['<td>' num2str(P.obj(k).avg) '</td>'];
    TXT{end+1} = '</tr>';
end
TXT{end+1} = '</table></center>';
TXT{end+1} = '<br><br>';

% Footnotes section
n = 0;
if S.containsSimulinkSystems,    
    TXT{end+1} = '<br><br><hr>';
    TXT{end+1} = '<center><b><font size=+1>Notes</b></font></center>';
    TXT{end+1} = '<br>';
    TXT{end+1} = '<font>';
    
    %  CPU Clock speed note
    n = n+1;  ns = num2str(n);
    if strcmp(S.BoardType,'C6701EVM'),
        TXT{end+1} = [ns '.  The CPU Clock Speed is assumed to be ' ...
                num2str(S.CpuClkSpeed/1e6) ' MHz.  On the C6701 EVM, ' ...
                'the clock speed is configurable but not detectable.  ' ...
                'If you have configured the C6701 EVM to have a different ' ...
                'clock speed or you have a different board with a different clock ' ...
                'speed, then you must specify the new speed in RTW Options.<br>'];
    else  % DSKs
        TXT{end+1} = ['1.  The CPU clock is set to ' ...
            num2str(S.CpuClkSpeed/1e6) ' MHz on the ' S.BoardType '.<br>'];
    end
    TXT{end+1} = '<br>';
    
    %  Explanation of timer clicks vs. cpu cycles
    n = n+1;  ns = num2str(n);
    if strcmp(S.BoardType,'C6416DSK'),
        clkFactor = '8';
    else
        clkFactor = '4';
    end
    TXT{end+1} = [ns '.  STS timing objects associated with subsystem profiling ' ...
            'are configured for a host-side ' ...
            'operation of ' clkFactor '*x, reflecting the numerical relationship between ' ...
            'CPU clock cycles and high-resolution timer clicks. Therefore, ' ...
            'STS Max, Total, and Average measurements are correctly reported in ' ...
            'units of "instructions" or "CPU clock cycles".<br>'];
    TXT{end+1} = '<br>';
    
    %   Definition of Critical Headroom
    if S.isSingleRate,
        segment1 = ['when the code consumes the maximum measured ' ...
                'clock cycles.  '];
    else
        segment1 = ['when sample times coincide in one ' ...
                'interrupt and consume the maximum measured clock cycles.  '];
    end
    if ~S.isMultiTasking
        n = n+1;  ns = num2str(n);
        TXT{end+1} = [ns '.  "Critical headroom" ' ...
            'is the amount of time spent idle during the worst-case ' ...
            'situation, i.e., ' segment1 ...
            'When this headroom approaches zero, there is danger ' ...
            'of an overrun.  ' ...
            'Critical headroom is computed by measuring ' ...
            'the maximum duration of the software interrupt (SWI) ' ...
            'and subtracting that time from the interrupt interval.  ' ...
            'When there is an overrun, the headroom is zero.<br>'];
        TXT{end+1} = '<br>';
    end

    % 4.  Multitasking note
    if S.isMultiTasking,
        n = n+1;  ns = num2str(n);
        TXT{end+1} = [ns '.  The model is in multi-tasking mode; ' ...
                'only systems executing at the base rate ' ...
                'have been profiled.  Systems executing at ' ...
                'slower rates are not profiled, because they ' ...
                'can be preempted.<br>'];
    end
    TXT{end+1} = '<br>';
    
    % 5. Help browser note
    n = n+1;  ns = num2str(n);
    TXT{end+1} = [ns '.  This page is best viewed with the MATLAB Help Browser, ' ...
            'which allows the system names to link to the corresponding ' ...
            'subsystems in the Simulink model.<br>'];
    TXT{end+1} = '<br></font>';
    TXT{end+1} = '<center><A href = "matlab:' ;
    TXT{end+1} = ['helpview([docroot ''/toolbox/tic6000/tic6000.map''], ' ... 
            '''profiling_code'')'];
    TXT{end+1} = ['"><b>HELP</b> on Profiling with Embedded Target for ' ...
        'TI C6000(R)</A></center>'];
    TXT{end+1} = '<br>';
    TXT{end+1} = '<hr>';
    
end
TXT{end+1} = '</body>';
TXT{end+1} = '</html>';


% - - -  - - -  - - -  - - -  - - -  - - -  - - - 
% Write TXT to file
fileName = fullfile(tempdir,'profileReport.html');
if exist(fileName,'file')
    try
        delete(fileName);
    end
end
fid = fopen(fileName,'wt');
if (fid < 0)
    error('Error opening report file for writing');
end
formatStr = '%s\n';
for k = 1:length(TXT),
    fprintf(fid,formatStr,TXT{k});
end
fclose(fid);


% ------------------------------------------------
function str = timeFmt(num)
numDigits = 4;
htmlMu = '&#181;';

if (num >= 1),
    num2 = num;
    prefixStr = '';
elseif (num < 1) && (num >= 0.001),
    % milliseconds
    num2 = num*1000;
    prefixStr = 'm';
elseif (num < 0.001) && (num >= 1e-6),
    % microseconds
    num2 = num*1e6;
    prefixStr = htmlMu;
elseif (num < 1e-6) && (num >= 1e-9),
    % nanoseconds
    num2 = num*1e9;
    prefixStr = 'n';
elseif (num < 1e-9) && (num >= 1e-12),
    % picoseconds
    num2 = num*1e12;
    prefixStr = 'p';
else
    % Zero. 
    % Or really, really, really, really small:
    % sprintf will produce scientific notation here
    num2 = num;
    prefixStr = '';
end

str = [sprintf(['%0.' num2str(numDigits) 'g'],num2) ' ' prefixStr 's'];

% ------------------------------------------------
function str = percentFmt(num)
numDigits = 3;

pct = 100*num;
if (pct >= 50),
    str = [num2str(floor(pct)) '%'];
else
    str = [sprintf(['%0.' num2str(numDigits) 'g'],pct) '%'];
end



% ------------------------------------------------
function str = openSystemHyperlink(modelName, sysName, linkText)

% Replace newlines with '\n' in system name for matlab command
sysName2 = strrep(sysName,sprintf('\n'),'\n');
% Replace newlines with '' in link text
linkText2 = strrep(linkText,sprintf('\n'),'');
% Generate hyperlink
if strcmp(sysName,'<Root>'),
    str = ['<A href = "matlab:' ...
            'open_system(''' modelName '''), ' ...
            '">' linkText2 '</A>'];
else
    str = ['<A href = "matlab:' ...
            'load_system(''' modelName '''), ' ...
            'pause(.1), ' ...         
            'open_system(sprintf(''' sysName2 ''')), ' ...
            '">' linkText2 '</A>'];
end


% ------------------------------------------------
function srtOrder = sortSystemsByTime(S);

for k = 1:length(S.sys),
    t = S.sys(k).maxTime;
    if isempty(t),
        t = -1;
    end
    times(k) = t;
end
[y,srtOrderIncr] = sort(times);
srtOrder = fliplr(srtOrderIncr);
    
% EOF  generateHTML_TItarget.m
