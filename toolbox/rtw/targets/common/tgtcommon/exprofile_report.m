function exprofile_report(profData)
%EXPROFILE_REPORT execution profiling function that displays an HTML report
%   EXPROFILE_REPORT(PROFDATA) takes execution profile data in the form provided
%   by EXECPROF_UNPACK and displays it as an HTML report.
%
%   See also EXPROFILE_UNPACK

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  

% Extract task timing data
  taskTimes = [];
  taskNameList = profData.taskNameList;
  taskTs = profData.taskTs;
  for i=1:length(taskNameList)
    [tMax, tMaxAt, tAv, eMax, eMaxAt, eAv, tSampleAv] = ...
        i_task_times(profData.taskActivity(:,i), taskTs);
    taskTimes = [taskTimes; tMax, tMaxAt, tAv, eMax, eMaxAt, eAv, tSampleAv];
  end
  
  % Format data as html table rows
  taskTimesHtml = i_taskTimesToHtml(taskTimes, taskNameList);
  maxTurnaroundTimesHtml = i_turnaroundTimesToHtml(profData.tMax, taskNameList);
  maxOverrunsHtml = i_overrunTimesToHtml(profData.oRunMax,taskNameList);
  dataLoggingDuration = num2str(( taskTs(end) - taskTs(1)) ); 
  timePerTickStr = sprintf('%0.5g',profData.timePerTick);
  timerRangeStr = sprintf('%0.5g', profData.timePerTick * 2 ^ (profData.wsize * 8) );
  
  % Write the results to an report
  output_file = fullfile(tempdir, ['ex_profile_' regexprep(num2str(fix(clock)),'\s+','_') '.html']);
  i_html_insert(output_file, ...
                '====task timing analysis table====', taskTimesHtml, ...
                '====maximum overruns table====', maxOverrunsHtml, ...
                '====Insert duration of data logging====',dataLoggingDuration,...
                '====timer resolution====',timePerTickStr,...
                '====timer range====',timerRangeStr,...
                '====maximum turnaround times====', maxTurnaroundTimesHtml);
  
  % Display report in the help browser
  web(['file:///' output_file]);


function  tableRows = i_taskTimesToHtml(times, taskNameList)
  
tableRows = [...
    '<TR><TD><b>Task</b>'...
    '<TD><b>Maximum turnaround time</b>'...
    '<TD><b>Average turnaround time</b>'...
    '<TD><b>Maximum execution time</b>'...
    '<TD><b>Average execution time</b>'...
    '<TD><b>Average sample time</b>'...
    '</TR>'];

for i=1:length(times(:,1))
  name = taskNameList{i};
  row = [...
    '<TR><TD><b>' name '</b>'...
    '<TD>' sprintf('%0.3g',(times(i,1))) ' at ' sprintf('%0.3g',(times(i,2))) ...
    '<TD>' sprintf('%0.3g',(times(i,3)))                            ...
    '<TD>' sprintf('%0.3g',(times(i,4))) ' at ' sprintf('%0.3g',(times(i,5))) ...
    '<TD>' sprintf('%0.3g',(times(i,6))) ...
    '<TD>' num2str(times(i,7)) ...
    '</TR>'];
  tableRows = sprintf('%s\n%s', tableRows, row);
end
  
% I_TURNAROUNDTIMESTOHTML formats maximum turnaround times as HTML
function  tableRows = i_turnaroundTimesToHtml(times, taskNameList)
  
tableRows = [...
    '<TR><TD><b>Task</b>'...
    '<TD><b>Maximum turnaround time</b>'...
    '</TR>'];

for i=1:length(times(:,1))
  name = taskNameList{i};
  row = [...
    '<TR><TD><b>' name '</b>'...
    '<TD>' sprintf('%0.3g',(times(i))) ...
    '</TR>'];
  tableRows = sprintf('%s\n%s', tableRows, row);
end
  

% I_OVERRUNTIMESTOHTML formats maximum overruns as HTML
function  tableRows = i_overrunTimesToHtml(overruns, taskNameList)
  
tableRows = [...
    '<TR><TD><b>Task</b>'...
    '<TD><b>Maximum number of task overruns</b>'...
    '</TR>'];

for i=1:length(overruns)
  name =  taskNameList{i};
  row = [...
    '<TR><TD><b>' name '</b>'...
    '<TD>' num2str(overruns(i)) ...
    '</TR>'];
  tableRows = sprintf('%s\n%s', tableRows, row);
end
  

%
function [tMax, tMaxAt, tAv, eMax, eMaxAt, eAv, tSampleAv] = ...
      i_task_times(taskEvents, taskTs);

% Discard all points where task state hasn't changed
  eventDiff = diff(double(taskEvents));
  changedIdx = [1; [find(eventDiff~=0)+1]];
  taskEvents = taskEvents(changedIdx); 
  taskTs = taskTs(changedIdx);
  
  % Identify all the task idle events
  idleIdx = find(taskEvents=='i');
  
  % All task start events
  startIdx = idleIdx(1:end-1)+1;
  
  % All task end events
  endIdx = idleIdx(2:end);
  
  % Number of complete task invocations
  nSamples = length(idleIdx) - 1;
  
  % Pre-allocate arrays
  tTurnaround = zeros(nSamples, 1);
  tExecution = zeros(nSamples, 1);
  
  for i=1:nSamples
    eIdx = endIdx(i);
    sIdx = startIdx(i);
    tTurnaround(i) = taskTs(eIdx) - taskTs(sIdx);
    tExecution(i) = sum(taskTs(eIdx:(-2):(sIdx+1))) ...
        - sum(taskTs(sIdx:2:(eIdx-1)));
  end

  % Maximum turnaround time
  tMax = max(tTurnaround);
  
  % Time at which sample with maximum turnaround time started
  tMaxAt = taskTs(startIdx(min(find(tTurnaround==tMax))));
  
  % Average turnaround time
  tAv = sum(tTurnaround)/length(tTurnaround);
  
  % Maximum execution time
  eMax = max(tExecution);
  
  % Time at which sample with maximum execution time started
  eMaxAt = taskTs(startIdx(min(find(tExecution==eMax))));
  
  % Average execution time
  eAv = sum(tExecution)/length(tExecution);
  
  if (nSamples>=2)
    firstSampleStart = idleIdx(1)+1;
    lastSampleStart = idleIdx(end-1)+1;
    tSampleAv = (taskTs(lastSampleStart) - taskTs(firstSampleStart) ) / (nSamples-1);
  else
    tSampleAv = Inf;
  end
    
  
% I_HTML_INSERT opens the template html report and inserts data from the analysis
%    I_HTML_INSERT(OUTFILE, OLDSTR1, NEWSTR1, OLDSTR2, NEWSTR2, ...) opens the
%    template html report and replaces each of OLDSTR with NEWSTR. The modified
%    file contents are written to OUTFILE.
function i_html_insert(outfile, varargin)
  
% Load the template file from the same directory as this mfile
  myDir = fileparts(which(mfilename));
  fid = fopen(fullfile(myDir, '..', 'profile', 'execution','exec_profile.html'));
  buf = fread(fid, Inf, 'uchar');
  buf = char(buf');
  fclose(fid);
  
  % replace each of newstr with oldstr
  for i=1:2:length(varargin)
    oldstr = varargin{i};
    newstr = varargin{i+1};
    bufout = strrep(buf, oldstr, newstr);
    buf = bufout;
  end
  
  % write out the new file
  fid = fopen(outfile, 'w');
  fwrite(fid, bufout, 'uchar');
  fclose(fid);