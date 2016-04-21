function slprofreport(iProfileHandle, iOutputDir, iModelName)
%SLPROFREPORT Simulink Profiler Report Generator.
% This function is called internally by the Simulink and TLC
% profilers to generate the HTML profiler report.

%   $Revision: 1.1.6.2 $  
%   Copyright 1984-2004 The MathWorks, Inc.

[structArray,clockPrec,clockSpeed,pname] = ParseInputs(iProfileHandle);

structArray = ComputeTimes(structArray);

structArray = ParseFunctionNames(pname, structArray, iModelName);

% If the iOutputDir is empty, then use tempname as the 
% base of all the html files created.  Otherwise, use model name.
if isempty(iOutputDir)
  fname = tempname;
else
  fname = fullfile(iOutputDir, iModelName);
end
[path,name,ext,ver] = fileparts(fname); %#ok
if (isempty(path))
  path = pwd;
end
frameName = [name '.html'];
contentsName = [name '_contents' '.html'];
summaryName = [name '_summary' '.html'];
detailsName = [name '_details' '.html'];
helpName = [name '_help' '.html'];

PrintHTMLFrames(path, frameName, contentsName, summaryName, pname);
PrintHTMLContentsFrame(path, iModelName, contentsName, summaryName, ...
                       detailsName, helpName, pname);
PrintHTMLSummaryFrame(path, summaryName, detailsName, ...
                      structArray, clockPrec, clockSpeed, pname);
PrintHTMLFunctionsFrame(path, detailsName, structArray, clockPrec, pname);

% The help frame is not needed for TLC
if strcmp(pname, 'Simulink')
  PrintHTMLHelpFrame(path, helpName, pname);
end

htmlFile = fullfile(path,frameName);

% For testing, if get_param(iModelName,'ProfileOutputDir')
% is nonempty, then do not open the browser.
if isempty(get_param(iModelName,'ProfileOutputDir'))
  if usejava('mwt') == 1
    if strcmp(pname, 'Simulink')
      % Send the output to the web command.  This will create a new
      % browser window with a toolbar and without an address box.
      web(htmlFile, '-new', '-noaddressbox');
    else
      web(htmlFile, '-browser');
    end
    status = 0;
  else
    if strcmp(pname, 'Simulink')
      disp(['Unable to open profile report in the MATLAB Web Browser. ' ...
            'Hyper-links to Simulink models will only work in the MATLAB ' ...
            'Web Browser.']);
    end
    status = web(htmlFile, '-browser');
  end
  
  switch status
   case 0
    % no action required
   case 1
    warning('Simulink:slprofreport:BrowserNotFound', ...
            'Report saved, but could not find web browser');
   case 2
    warning('Simulink:slprofreport:BrowserNotLaunched', ...
            'Report saved, but could not launch web browser');
   otherwise
    % unknown status code from web
  end
end

%%%
%%% PrintHTMLFrames
%%%
function PrintHTMLFrames(path, frameName, contentsName, summaryName, pname)
% Prints the top-level HTML document, which contains the frameset tags.

fid = fopen(fullfile(path,frameName),'wt');
if (fid < 0)
  error('Error opening report file for writing');
end
fprintf(fid, '<html> \n');

fprintf(fid, '<script language="JavaScript">\n');
fprintf(fid, '        setTimeout ("forceToTop()", 0);\n');
fprintf(fid, '        function forceToTop() {\n');
fprintf(fid, '                if (self != top) {\n');
fprintf(fid, '                     top.location = document.location;\n');
fprintf(fid, '                }\n');
fprintf(fid, '        }\n');
fprintf(fid, '</script>\n');

fprintf(fid, '<head> \n');
fprintf(fid, '<title>%s Profiler Report</title>\n', pname);
fprintf(fid, '</head>\n');

fprintf(fid, '<frameset rows="50,*">\n');
fprintf(fid, '   <frame name="Frame 1" src="%s" scrolling="auto"> \n', ...
        contentsName);
fprintf(fid, '   <frame name="Frame 2" src="%s" scrolling="auto"> \n', ...
        summaryName);

fprintf(fid, '</frameset> \n');

fprintf(fid, '<body> \n');
fprintf(fid, '</body> \n');
fprintf(fid, '</html> \n');
fclose(fid);

%endfunction PrintHTMLFrames

%%%
%%% PrintHTMLContentsFrame
%%%
function PrintHTMLContentsFrame(path, iModelName, contentsName, summaryName, ...
                                detailsName, helpName, pname)
% Prints the navigation frame.

fid = fopen(fullfile(path,contentsName),'wt');
if (fid < 0)
  error('Error opening report file for writing');
end
fprintf(fid, '<html> \n');
fprintf(fid, '<head> \n');
fprintf(fid, '</head>\n');

fprintf(fid, '<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');
fprintf(fid, '<a href="%s" target="Frame 2">Summary</a>\n', summaryName);
fprintf(fid, '&nbsp;|&nbsp; <a href="%s" target="Frame 2">Function Details</a>\n', ...
        detailsName);
if  strcmp(pname,'Simulink')
  fprintf(fid, '&nbsp;|&nbsp; <a href="%s" target="Frame 2">Simulink Profiler Help</a>\n', ...
          helpName);
  fprintf(fid, ['&nbsp;|&nbsp; <a href="matlab: slprofile_unhilite_system' ...
                ' %s"> Clear Highlighted Blocks </a>\n'], iModelName);
end
fprintf(fid, '</body>\n');
fprintf(fid, '</html> \n');
fclose(fid);

%endfunction PrintHTMLContentsFrame

%%%
%%% PrintHTMLSummaryFrame
%%%
function PrintHTMLSummaryFrame(path, summaryName, detailsName, ...
                               structArray, clockPrec, clockSpeed, pname)
% Prints the summary frame

fid = fopen(fullfile(path, summaryName), 'wt');
if (fid < 0)
  error('Could not open report file for writing.');
end

fprintf(fid, '<html>\n');
fprintf(fid, '<head>\n');
fprintf(fid, '</head>\n');
fprintf(fid, '<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');
fprintf(fid, '<h1>%s Profile Report:  Summary</h1>\n', pname);

fprintf(fid, '<p><em> Report generated %s </em></p>\n', datestr(now));

totalTime = sum([structArray.SelfTime]);
[counts,typenames] = CountFuncs(structArray);

fprintf(fid, '<table>\n');
fprintf(fid, '<tr> <td> Total recorded time: </td>\n');
fprintf(fid, '<td align="right"> %6.2f&nbsp;s </td> </tr>\n', totalTime);

for k = 1:length(counts)
  if(counts(k) > 0)
    fprintf(fid, '<tr> <td> Number of %ss: </td>\n', typenames{k});
    fprintf(fid, '<td align="right"> %d </td> </tr>\n', counts(k));
  end
end

fprintf(fid, '<tr> <td> Clock precision: </td>\n');

digits = ceil(-log10(clockPrec));

fprintf(fid, '<td align="right"> %s&nbsp;s </td></tr>\n', FormatTime(clockPrec, digits));

if(clockSpeed ~= 0)
  fprintf(fid, '<tr> <td> Clock Speed: </td>\n');
  fprintf(fid, '<td align="right"> %5.0f&nbsp;Mhz </td></tr>\n', clockSpeed);
end

fprintf(fid, '</table>\n\n');

PrintHTMLFunctionList(pname, fid, detailsName, structArray, clockPrec);


fprintf(fid, '</body>\n');
fprintf(fid, '</html>\n');

fclose(fid);

%endfunction PrintHTMLSummaryFrame

%%%
%%% PrintHTMLHelpFrame
%%%
function PrintHTMLHelpFrame(path, helpName, pname)
% Prints the simulink help frame

fid = fopen(fullfile(path, helpName), 'wt');
if (fid < 0)
  error('Could not open report file for writing.');
end

fprintf(fid, '<html>\n');
fprintf(fid, '<head>\n');
fprintf(fid, '</head>\n');
fprintf(fid, '<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');
fprintf(fid, '<h1>%s Profile Report:  Simulink Profiler Help</h1>\n', pname);

fprintf(fid, '<h2> Summary Legend: </h2>\n');
fprintf(fid, '<dl> \n');
fprintf(fid, ['<dt> Total recorded time: <dd> Total time for simulating' ...
              ' the model.\n']);
fprintf(fid, ['<dt> Number of Block Methods: <dd> Total number of' ...
              ' methods called by individual blocks in the model.\n']);
fprintf(fid, ['<dt> Number of Internal Methods: <dd> Total number' ...
              ' of internal Simulink methods called by the model.\n']);
fprintf(fid, ['<dt> Number of Nonvirtual Subsystem Methods: <dd>' ...
              ' Number of methods called by the model and any' ...
              ' nonvirtual subystems in the model.\n']);
fprintf(fid, ['<dt> Clock precision: <dd> Precision of the profiler\''s' ...
              ' time measurement.\n']);
fprintf(fid, '</dl>\n');
fprintf(fid, '<h2> Function List Legend: </h2>\n');
fprintf(fid, '<dl>\n');
fprintf(fid, ['<dt> Time: <dd> Time spent in this function, including' ...
              ' all child functions called.\n']);
fprintf(fid, ['<dt> Calls: <dd> Number of times this function was' ...
              ' called.\n']);
fprintf(fid, '<dt> Time/call: <dd> Time spent per call.\n');
fprintf(fid, ['<dt> Self time: <dd> Total time spent in this function, ' ...
              'not including any calls to child functions.\n']);
fprintf(fid, ['<dt> Location: <dd> Link to the location of the block' ...
              ' in your model.  Use the link "Clear Hilited Blocks"' ...
              'at the top of the page to unhilite all blocks.' ...
              ' (Note: you must use the MATLAB Help' ...
              ' browser to use these hyperlinks).\n']);
fprintf(fid, '</dl> \n');
fprintf(fid, ['Note: In accelerated mode, individual blocks will not' ...
              ' show up in the profiler, unless they are executed internally' ...
              ' in Simulink (e.g. a scope runs in Simulink instead' ...
              ' of the generated code).  Rerun in normal mode to' ...
              ' get a more detailed analysis of the simulation.\n']);

fprintf(fid, '<h2> Model execution pseudocode: </h2>\n');
fprintf(fid, '<ul>\n');
fprintf(fid, '<li>Sim()\n');
fprintf(fid, '<ul>\n');
fprintf(fid, '<li>ModelInitialize() - Set up the model for simulation.\n');
fprintf(fid, ['<li>ModelExecute() - Advance in time from '...
              't = Tstart to Tfinal.\n']);
fprintf(fid, '<ul>\n');
fprintf(fid, ['<li>Output() - Execute the output methods of blocks' ...
              ' in the model at time t.\n']);
fprintf(fid, ['<li>Update() - Execute the update methods of blocks' ...
              ' in the model at time t.\n']);
fprintf(fid, '<li>Integrate states from t to tnew (minor time steps).\n');
fprintf(fid, '<ul>\n');
fprintf(fid, ['<li> Compute states from derivs using repeated calls' ...
              ' to:\n']);
fprintf(fid, '<ul>\n');
fprintf(fid, '<li>MinorOutput()\n');
fprintf(fid, '<li>MinorDeriv()\n');
fprintf(fid, '</ul>\n');
fprintf(fid, ['<li>Locate any zero crossings; reset t and the' ...
              ' states accordingly using repeated calls to:\n']);
fprintf(fid, '<ul>\n');
fprintf(fid, '<li>MinorOutput()\n');
fprintf(fid, '<li>MinorZeroCrossings()\n');
fprintf(fid, '</ul>\n');
fprintf(fid, '</ul>\n');
fprintf(fid, '<li>EndIntegrate\n');
fprintf(fid, '<li>Set time t = tnew.\n');
fprintf(fid, '</ul>\n');
fprintf(fid, '<li>EndModelExecute\n');
fprintf(fid, '<li>ModelTerminate\n');
fprintf(fid, '</ul>\n');
fprintf(fid, '<li>EndSim\n');
fprintf(fid, '</ul>\n');

fprintf(fid, '</body>\n');
fprintf(fid, '</html>\n');

fclose(fid);

%endfunction PrintHTMLHelpFrame

%%%
%%% Anchor
%%%
function out = Anchor(str,name)
% Turns a string into an HTML named anchor.

out = sprintf('<a name="%s"> %s </a>', name, str);

%endfunction Anchor

%%%
%%% PrintHTMLFunctionList
%%%
function PrintHTMLFunctionList(pname, fid, detailsName, structArray, clockPrec)
% Print the list of functions in a table.

digits1 = ceil(-log10(clockPrec));
digits2 = digits1 + ceil(log10(max([structArray.NumCalls])));

[junk,sortedIdx] = sort([structArray.TotalTime]); %#ok
sortedIdx = sortedIdx(end:-1:1);

totalTime = sum([structArray.SelfTime]);
if (totalTime == 0)
  totalTime = eps;
end

fprintf(fid, '<h2> %s </h2> \n\n', Anchor('Function List', 'Function List'));

fprintf(fid, '<table border=1>\n');
fprintf(fid, '<th align=left> <small> Name </small> </th>\n');
fprintf(fid, '<th align=left colspan=2> <small> Time </small> </th>\n');
fprintf(fid, '<th align=left> <small> Calls </small> </th>\n');
fprintf(fid, '<th align=left> <small> Time/call </small> </th>\n');
fprintf(fid, '<th align=left colspan=2> <small> Self time </small> </th>\n');

loc = 'Location';
if strcmp(pname,'Simulink')
  loc = [loc, ' (must use MATLAB Help browser to view)'];
end
fprintf(fid, ['<th align=left> <small> ', loc, ' </small> </th>\n']);

fprintf(fid, '</tr>\n');

for k = 1:length(structArray)
  thisStruct = structArray(sortedIdx(k));

  href = sprintf('%s#Fcn_%d', detailsName, sortedIdx(k));

  fprintf(fid, '<tr>\n');

  fprintf(fid, '<td>%s</td> \n', ...
          Link(FormatName(thisStruct.FunctionName),href));
  fprintf(fid, '<td align="right"> <small> %s </small> </td>\n', ...
          FormatTime(thisStruct.TotalTime, digits1));
  fprintf(fid, '<td align="right"> <small> %5.1f%% </small> </td>\n', ...
          rmnegzero(thisStruct.TotalTime * 100 / totalTime));
  fprintf(fid, '<td align="right"> <small> %d </small> </td>\n', ...
          thisStruct.NumCalls);
  fprintf(fid, '<td align="right"> <small> %s </small> </td>\n', ...
          FormatTime(thisStruct.TotalTime / thisStruct.NumCalls, digits2));
  fprintf(fid, '<td align="right"> <small> %s </small> </td>\n', ...
          FormatTime(thisStruct.SelfTime, digits1));
  fprintf(fid, '<td align="right"> <small> %5.1f%% </small> </td>\n', ...
          rmnegzero(thisStruct.SelfTime * 100 / totalTime));
  if (~isempty(thisStruct.FileName))
    fprintf(fid, '<td> %s </td>\n', FormatPath(pname,thisStruct.FileName));
  else
    fprintf(fid, '<td> <small> <em> %s </em> </small> </td>\n', ...
            thisStruct.Type);
  end

  fprintf(fid, '</tr>\n');
end

fprintf(fid, '</table>\n');

%endfunction PrintHTMLFunctionList

%%
%% ParseFunctionName
%%
function oParsedArray = ParseFunctionNames(pName, iStructArray, iModelName)

oParsedArray = iStructArray;

%% Currently the MATLAB profiler will parse the FunctionName for 
%% characters like ">", but it leaves the CompleteName alone.  So
%% copy CompleteName into the FunctionName and parse out the FileName.
if strcmp(pName, 'Simulink')
  
  for i = 1:length(iStructArray)
    
    iStruct = iStructArray(i);
    iStruct.FunctionName = iStruct.CompleteName;
    oParsedArray(i).FunctionName = iStruct.CompleteName;
    switch(iStruct.Type)
      
     case 'Internal Method'
      oParsedArray(i).FileName = iModelName;
      
     case {'Nonvirtual Subsystem Method', 'Block Method'}
      % We know the FunctionName always ends with " (Method)"
      % so search for the last "(".  FileName == BPATH(block)
      openParens = strfind(iStruct.FunctionName,'(');
      oParsedArray(i).FileName = iStruct.FunctionName(1:openParens(end)-2);
            
    end
  end
else
  %% pName should be TLC
  
  for i = 1:length(iStructArray)

    iStruct = iStructArray(i);
    iStruct.FunctionName = iStruct.CompleteName;
    oParsedArray(i).FunctionName = iStruct.CompleteName;
    switch(iStruct.Type)
      
     case {'Normal Function', 'Output Function', 'Void Function', ...
           'Script', 'Generate Script'}
      openParens = strfind(iStruct.FunctionName,'(');
      oParsedArray(i).FileName = iStruct.FunctionName(openParens(end)+1:end-1);
      oParsedArray(i).FunctionName = iStruct.FunctionName(1:openParens(end)-1);
    
    end
  end
end
%endfunction ParseFunctionName

%%%
%%% Link
%%%
function out = Link(in,href)
% Turn a string into a cross-reference.

out = sprintf('<a href="%s">%s</a>', href, in);

%%%
%%% FormatName
%%%
function out = FormatName(name)
% Format a function name with the right color and font.

out = sprintf('<font color="#0000FF"><tt><b>%s</b></tt></font>', ...
              name);

%%%
%%% Eliminate negative zeros and very small numbers.
%%%
function v = rmnegzero(v)
% remove all -0.0 from report (just a cosmetic fix)
if(abs(v) < sqrt(eps))
  v = 0.0;
end

%%%
%%% FormatTime
%%%
function out = FormatTime(seconds, digits)
% Format a time string with the right number of decimal places.
formatStr = sprintf('%%.%df', digits);
out = sprintf(formatStr, rmnegzero(seconds));

%%%
%%% FormatPath
%%%
function out = FormatPath(pname,pathStr)
% Format a path string as a file URL.

if strcmp(pname,'Simulink')

  newline = sprintf('\n');
  tab     = sprintf('\t');

  encodedPath = '';
  for i=1:length(pathStr)
    switch(pathStr(i))
     case '\'
      encodedPath(end+1:end+2) = '\\';
     case ' '
      encodedPath(end+1:end+2) = '\s';
     case tab
      encodedPath(end+1:end+2) = '\t';
     case newline
      encodedPath(end+1:end+2) = '\n';
     case ''''
      encodedPath(end+1:end+2) = '\T';
     case '"'
      encodedPath(end+1:end+2) = '\Q';
     case '?'
      encodedPath(end+1:end+2) = '\q';
     otherwise
      encodedPath(end+1) = pathStr(i);
    end
  end

  href = ['matlab: slprofile_hilite_system(''encoded-path'',''',encodedPath,''');'];

else
  pathStr = strrep(pathStr, '\', '/');
  href = ['file:///' pathStr];
end
out = sprintf('<tt><a href="%s">%s</a></tt>', href, pathStr);

%endfunction FormatPath


%%%
%%% PrintHTMLFunctions
%%%
function PrintHTMLFunctionsFrame(path, detailsName, structArray, clockPrec, pname)
% Print the Function Details frame.

fid = fopen(fullfile(path,detailsName), 'wt');
if (fid < 0)
  error('Could not open report file for writing.');
end

wbHandle = waitbar(0,'Generating function details profile report ...');

fprintf(fid, '<html>\n');
fprintf(fid, '<head>\n');
fprintf(fid, '</head>\n');
fprintf(fid, '<body bgcolor="#FFF7DE" link="#247B2B" vlink="#247B2B" > \n\n');

[junk,sortedIdx] = sort([structArray.TotalTime]); %#ok
sortedIdx = sortedIdx(end:-1:1);

totalTime = sum([structArray.SelfTime]);

fprintf(fid, '<h1>%s Profile Report:  Function Details</h1>\n', pname);

fprintf(fid, '<dl>\n');
for k = 1:length(structArray)
  PrintHTMLFunctionDetails(fid, pname, structArray, ...
                           sortedIdx(k), totalTime, clockPrec);
  waitbar(k/length(structArray));
end
fprintf(fid, '</dl>\n');

fprintf(fid, '</body>\n');
fprintf(fid, '</html>\n');

fclose(fid);

close(wbHandle);

%endfunction PrintHTMLFunctionsFrame

%%%
%%% PrintHTMLFunctionDetails
%%%
function PrintHTMLFunctionDetails(fid, pname, structArray, p, ...
                                  totalTime, clockPrec)
% Print the detailed report for a given function.

funcStruct = structArray(p);
refStr = sprintf('Fcn_%d', p);
formattedName = FormatName(funcStruct.FunctionName);
digits1 = ceil(-log10(clockPrec));
digits2 = digits1 + ceil(log10(max([structArray.NumCalls])));

fprintf(fid, '<dt>\n');
fprintf(fid, '<hr size=5 noshade>\n');
if (isempty(funcStruct.FileName))
  fprintf(fid,'%s &nbsp;&nbsp;&nbsp;&nbsp;<em>%s</em><br>\n', ...
          Anchor(formattedName, refStr), funcStruct.Type);
else
  fprintf(fid,'%s &nbsp;&nbsp;&nbsp;&nbsp;%s<br>\n', ...
        Anchor(formattedName, refStr), ...
        FormatPath(pname,funcStruct.FileName));
end

fprintf(fid, 'Time: %s s &nbsp;&nbsp; (%4.1f%%)<br>\n', ...
        FormatTime(funcStruct.TotalTime, digits1), ...
        rmnegzero(100 * funcStruct.TotalTime / (max(totalTime, eps))));
fprintf(fid, 'Calls: %d <br>\n', funcStruct.NumCalls);
fprintf(fid, 'Self time: %s s &nbsp;&nbsp; (%4.1f%%)<br><br>\n', ...
        FormatTime(funcStruct.SelfTime, digits1), ...
        rmnegzero(100 * funcStruct.TotalTime / (max(totalTime, eps))));

fprintf(fid, '<dd>\n');
fprintf(fid, '<table border=1>\n');
fprintf(fid, '<th align=left> <small> Function: </small> </th>\n');
fprintf(fid, '<th align=left colspan=2> <small> Time </small> </th>\n');
fprintf(fid, '<th align=left> <small> Calls </small> </th>\n');
fprintf(fid, '<th align=left> <small> Time/call </small> </th>\n');
fprintf(fid, '</tr>\n');

fprintf(fid, '<tr>\n');
fprintf(fid, '<td> %s </td>\n', formattedName);
fprintf(fid, '<td align=right> <small> %s </small> </td>\n', ...
        FormatTime(funcStruct.TotalTime, digits1));
fprintf(fid, '<td> &nbsp; </td>\n');
fprintf(fid, '<td align=right> <small> %d </small>\n', funcStruct.NumCalls);
fprintf(fid, '<td align=right> <small> %s </small> </td>\n', ...
        FormatTime(funcStruct.TotalTime / funcStruct.NumCalls, digits2));
fprintf(fid, '</tr>\n');

fprintf(fid, '<tr> <td colspan=5> &nbsp; </tr>\n');

fprintf(fid, '<tr> <td colspan=5> <small> <b>Parent functions:</b> </small> </td> </tr>\n');
if (isempty(funcStruct.Parents))
  fprintf(fid, '<tr> <td colspan=5> <small> <em> none </em> </small> </td> </tr> \n');
else
  for k = 1:length(funcStruct.Parents)
    href = sprintf('#Fcn_%d', funcStruct.Parents(k).Index);
    parentName = FormatName(structArray(funcStruct.Parents(k).Index).FunctionName);
    fprintf(fid, '<tr>\n');
    fprintf(fid, '<td colspan=3> %s </td>\n', Link(parentName,href));
    fprintf(fid, '<td align=right> <small> %d </small> </td>\n', ...
            funcStruct.Parents(k).NumCalls);
    fprintf(fid, '<td> &nbsp; </td>\n');
    fprintf(fid, '<tr>\n');
  end
end

fprintf(fid, '<tr> <td colspan=5> &nbsp; </tr>\n');

fprintf(fid, '<tr> <td colspan=5> <small> <b>Child functions:</b> </small> </td> </tr>\n');
kids = funcStruct.Children;
if (isempty(kids))
  fprintf(fid, '<tr> <td colspan=5> <small> <em> none </em> </small> </td> </tr> \n');
else
  [junk,idx] = sort(-[kids.TotalTime]); %#ok
  kids = kids(idx);
  for k = 1:length(kids)
    href = sprintf('#Fcn_%d', kids(k).Index);
    childName = FormatName(structArray(kids(k).Index).FunctionName);
    fprintf(fid, '<tr>\n');
    fprintf(fid, '<td> %s </td>\n', Link(childName,href));
    fprintf(fid, '<td align=right> <small> %s </small> </td>\n', ...
            FormatTime(kids(k).TotalTime, digits1));
    fprintf(fid, '<td align=right> <small> %4.1f%% </small> </td>\n', ...
            100 * kids(k).TotalTime / max(funcStruct.TotalTime, eps));
    fprintf(fid, '<td align=right> <small> %d </small> </td>\n', ...
            kids(k).NumCalls);
    fprintf(fid, '<td align=right> <small> %s </small> </td>\n', ...
            FormatTime(kids(k).TotalTime / ...
                       kids(k).NumCalls, digits2));
    fprintf(fid, '<tr>\n');
  end
end
fprintf(fid, '</table><br><br>\n');

stats = LineStats(funcStruct);

if (~isempty(stats))
  totalLineTime = sum([stats{:,2}]);
  fprintf(fid, '%d%% of the total time in this function was spent on the following lines:<br><br>\n',...
          floor(100 * totalLineTime / max(funcStruct.TotalRecursiveTime,eps)));
  fprintf(fid, '<table border=0> \n');
  for k = 1:size(stats,1)
    lineNum = stats{k,1};
    lineTime = stats{k,2};
    lineString = stats{k,3};

    if ((k > 1) && (lineNum > (stats{k-1,1} + 1)))
      fprintf(fid, '<tr> <td> &nbsp; </td> </tr> \n');
    end

    fprintf(fid, '<tr> \n');

    if (lineTime > 0)
      fprintf(fid, '<td align=right> <code> %s </code> </td>\n', ...
              FormatTime(lineTime, digits1));
      fprintf(fid, '<td align=right> <code> %d%% </code> </td>\n', ...
              round(100 * lineTime / ...
                    max(funcStruct.TotalRecursiveTime, eps)));
    else
      fprintf(fid, '<td> &nbsp; </td>\n');
      fprintf(fid, '<td> &nbsp; </td>\n');
    end

    fprintf(fid, '<td align=right> <code> %d:&nbsp; </code> </td>\n', ...
            lineNum);
    % Replace tabs by 2 spaces, then replace spaces by
    % nonbreaking spaces.
    lineString = strrep(lineString,char(9),'  ');
    lineString = strrep(lineString,' ','&nbsp;');
    lineString = strrep(lineString,'<','&lt;');
    lineString = strrep(lineString,'>','&gt;');
    fprintf(fid, '<td> <code> <nobr> %s </nobr> </code> </td> \n', ...
            lineString);

    fprintf(fid, '</tr> \n');
  end
  fprintf(fid, '</table>\n');
end

%endfunction PrintHTMLFunctionDetails

function [counts,typenames] = CountFuncs(structArray)
% Count the number of functions of each type.

typenames = { structArray.Type };
typenames = unique(typenames);  % sort too?
numnames = length(typenames);
counts = zeros(numnames,1);

for k = 1:length(structArray)
  idx = strcmp(structArray(k).Type, typenames);
  counts(idx) = counts(idx) + 1;
end

%endfunction CountFuncs

function newArray = ComputeTimes(structArray)
% Compute self time and total recursive time.

newArray = structArray;

for k = 1:length(newArray)
  childTime = 0;
  for p = 1:length(newArray(k).Children)
    childTime = childTime + newArray(k).Children(p).TotalTime;
  end
  newArray(k).TotalChildrenTime = childTime;
  newArray(k).SelfTime = newArray(k).TotalRecursiveTime - ...
      childTime;
end

%endfunction ComputeTimes

%%%
%%% LineStats
%%%
function stats = LineStats(funcStruct)
% Return P-by-3 cell array.  First column is the line number.  Second column
% is the line time.  Third column is the line string.  P is the the number
% of lines accounting for 95% of the total time, or 10 lines, or the total
% number of lines in the file, whichever is smaller.

if (isempty(funcStruct.ExecutedLines))
  stats = cell(0,3);
else
  fid = fopen(funcStruct.FileName);
  if (fid < 0)
    stats = cell(0, 3);
  end

  if (fid >= 0)
    inMat = textread(funcStruct.FileName,'%s','delimiter','\n','whitespace','');
    inMat{length(inMat)+1} = '';
    fclose(fid);
    
    timePerLine(funcStruct.ExecutedLines(:,1)) = funcStruct.ExecutedLines(:,3);
    timePerLine = timePerLine(:);
    totalTime = max(sum(timePerLine),eps);
    numInputLines = length(timePerLine);
    
    [bb, mfileIdx] = sort(timePerLine);
    bb = flipud(bb);
    mfileIdx = flipud(mfileIdx);
    
    % Report on the lines accounting for 95% of the total time, or 10
    % lines, or the total number of lines in the file, whichever
    % is smaller.
    numBusyLines = min(min(length(find((cumsum(bb)/max(totalTime,eps))>.95)), ...
                           10), numInputLines);
    bb = bb(1:numBusyLines);
    mfileIdx = mfileIdx(1:numBusyLines);
    
    %---------------------------------------------------------
    % Find the context lines, storing them in mfileLines.
    
    if (~isempty(mfileIdx))
      % Get rid of lines with no sample hits.
      mfileIdx(bb==0) = [];
      bb(bb==0) = [];
      
      mfileLines = max(1, [mfileIdx-1 ; mfileIdx ; mfileIdx+1]);
      
      % Remove out of range lines
      mfileLines((mfileLines < 1) | (mfileLines > numInputLines)) = [];
      
      mfileLines = sort(mfileLines);
      d = find(abs(diff(mfileLines))==0);
      mfileLines(d) = [];
    else
      mfileLines = [];
    end
    
    stats = cell(length(mfileLines), 3);
    for m = 1:length(mfileLines)
      nextLine = inMat{mfileLines(m)};
      k = find(mfileIdx == mfileLines(m));
      if (isempty(k))
        lineTime = 0;
      else
        lineTime = bb(k);
      end
      stats{m,1} = mfileLines(m);
      stats{m,2} = lineTime;
      stats{m,3} = nextLine;
    end
  end
end
  
%endfunction LineStats

%
% ParseInputs
%
function [structArray,clockPrec,clockSpeed,name] = ParseInputs(iProfileHandle)

h = iProfileHandle;
callstats(h,'stop');
[ft,fh,cp,name,cs] = callstats(h,'stats'); %#ok
info.FunctionTable = ft;
info.ClockPrecision = cp;
info.ClockSpeed = cs;
info.Name = name;

structArray = info.FunctionTable;
clockPrec = info.ClockPrecision;
clockSpeed = info.ClockSpeed;
name = info.Name;

%endfunction ParseInputs