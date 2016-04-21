function [trace_list, builtins, matlab_classes, prob_files, prob_symbols,  ...
		eval_strings, called_from, opaque_classes] = depfun(varargin)
%DEPFUN  Locate dependent functions of an M/P-file.
%    TRACE_LIST = DEPFUN(FUN) returns a cell array of files of the dependent
%    functions of FUN.  To be analyzed, FUN must be on the MATLABPATH as
%    determined by the WHICH command. FUN is directly dependent on the functions
%    that it calls; FUN is indirectly dependent on the functions called by
%    the functions called by FUN, and so on. The files are analyzed and the
%    transitive closure done based on the information in the dispatcher.
%    The TRACE_LIST produced usually includes 'extra' files that would
%    never be called if FUN were actually evaluated. The files are listed
%    by the original arguments following by a sorted list of additional
%    dependent files. Any duplicate argument files are dropped from the final
%    list. Script M-files can be included but analysis is incomplete.
%
%    If the MATLABPATH contains 'relative' directories then any file in those
%    directories will have a 'relative' path.
%
%    [TRACE_LIST, BUILTINS, MATLAB_CLASSES] = DEPFUN(FUN) also returns a 
%    cell array of all builtin function names and MATLAB class names called
%    by FUN and its dependent functions.
%
%    The syntax for DEPFUN with all possible outputs is:
%    [TRACE_LIST, BUILTINS, MATLAB_CLASSES, PROB_FILES, PROB_SYMBOLS,...
%                EVAL_STRINGS, CALLED_FROM, OPAQUE_CLASSES] = DEPFUN(FUN)
%    where:
%
%    PROB_FILES is a structure array of M/P-files that DEPFUN could not parse,
%      locate, or access.  Parsing problems can arise from MATLAB syntax errors.
%      The fields of the structure are:
%
%          .name       - path to the file
%          .listindex  - trace_list index
%          .errmsg     - error message string
%
%    PROB_SYMBOLS [NOT IMPLEMENTED] is a structure array that indicates which
%      symbol names DEPFUN could not resolve as functions or variables. The
%      fields of the structure are:
%
%          .name       - name of the symbol
%          .fcn_id     - double array of trace_list indices
%
%    EVAL_STRINGS [NOT IMPLEMENTED] is a structure array that indicates where
%      functions in TRACE_LIST call eval, evalc, evalin, or feval. The strings
%      that eval and similar functions evaluate might use functions that are
%      not in TRACE_LIST. The fields of the structure are:
%
%          .fcn_name   - path to the file.
%          .lineno     - double array of line numbers in the file.
%
%    CALLED_FROM is a cell array where each element is a double array and
%      indicates who calls whom.  CALLED_FROM is arranged so that
%      TRACE_LIST(CALLED_FROM{i}) lists all functions in FUN that call
%      TRACE_LIST{i}.  CALLED_FROM and TRACE_LIST have the same length. An 
%      empty double array indicates either the trace_list file is an
%      unreferenced argument file or an unreferenced 'special' file
%      added for closure.
%
%    OPAQUE_CLASSES is a cell array of 'opaque' class names that includes
%      Java and COM class names used by one or more of the files in
%      TRACE_LIST.
%
%    [...] = DEPFUN(FILE1,FILE2,...) processes each file in turn. FILEN
%      can also be a cell array of files.
%
%    [...] = DEPFUN(FIG_FILE) looks for dependent functions among the
%    callback strings of any GUI elements defined in the .FIG file FIG_FILE.
%
%    DEPFUN has optional control input strings.
%
%    '-toponly' 	will override the default recursive search for dependent
% 			files and will return lists of builtins, M/P/MEX-files,
%			and classes used only in the functions listed as inputs
%			to DEPFUN.
%    '-verbose'		outputs additional internal messages.
%    '-quiet'           do not print the summary output. Only print error and
%                       warning messages. By default a summary report is
%                       written to the command window.
%    '-print','file'    prints a full report to file.
%    '-all'             computes all possible left hand side arguments and
%                       displays the results in the report(s). But returns
%                       just the specified arguments.
%    '-notrace'		do not return any trace results other than the
%			original arguments. Always find callbacks for .fig
%                       files if on the the path.
%    '-expand'		specifies full paths along with the indices in the
%			called or call list.
%    '-calltree'	return the call list in place of the called from
%			list. This is derived from the called from list
%			as an extra step.
%
%    Output:
%
%      Summary: (Always generated at the command prompt unless the '-quiet'
%		 option is used.)
%
%        ==========================================================
%        depfun report summary:
%
%          or
%
%        depfun report summary: (top only)
%        ----------------------------------------------------------
%        -> trace list:       ### files  (total)
%			      ### files  (total arguments)
%                             ### files  (arguments off MATLABPATH)
%                             ### files  (argument duplicates on MATLABPATH)
%                             ### files  (argument duplicates off MATLABPATH)
%        -> builtin list:     ### names
%        -> MATLAB classes:   ### names  (builtin, MATLAB OOPS)
%        -> problem list:     ### files  (argument)
%                             ### files  (other)
%        -> problem symbols:  NOT IMPLEMENTED
%        -> eval strings:     NOT IMPLEMENTED
%        -> called from list: ### files  (argument unreferenced)
%                             ### files  (argument referenced)
%                             ### files  (other referenced)
%			      ### files  (other unreferenced)
%
%           OR if -calltree is passed
%
%        -> call list:        ### files  (argument with no calls)
%                             ### files  (argument with calls)
%                             ### files  (other with calls)
%			      ### files  (other with no calls)
%        -> opaque classes:   ### names  (Java, etc.)
%        ----------------------------------------------------------
%        Note: 1. Use argument  '-quiet' to not print this summary.
%	       2. Use arguments '-print','file' to produce a full
%                 report in file.
%              3. Use argument  '-all' to display all possible
%                 left hand side arguments in the report(s).
%        ==========================================================
%  
%      Full: (Only generated if the '-print' option is used.)
%
%        depfun report:
%  
%           or
%
%        depfun report: (top only)
%
%        -> trace list:   
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%
%           OR if called from list is generated then:
%
%           For complete list: See -> called from:
%
%           Files not on MATLABPATH:
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%
%           HG factory callback names:
%           ----------------------------------------------------------
%           ...
%           ----------------------------------------------------------
%  
%        -> builtin list:
%           ----------------------------------------------------------
%           1: <name>
%           ...
%           ----------------------------------------------------------
%  
%        -> MATLAB classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem list:
%           ----------------------------------------------------------
%           #: <file>
%              <message>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem symbols: NOT IMPLEMENTED
%  
%        -> eval strings:    NOT IMPLEMENTED
%  
%        -> called from list: (by trace list)
%
%           OR if -calltree is passed
%
%        -> call list: (by trace list)
%           ----------------------------------------------------------
%           1: <file>
%              <called from (or call) array>
%
%              OR if -expand is passed
%               
%              <called from (or call) array with actual path>
%
%           2: <file>
%              <called from (or call) array>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%  
%        -> opaque classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%
%    See also DEPDIR, CKDEPFUN

%    DEPFUN has additional undocumented optional control input strings.
%
%    '-savetmp' 	saves any temporary M-files in the current
%                       directory.
%    '-nosort'		does not sort the dependency files found.
%
%    Copyright 1984-2004 The MathWorks, Inc. 
%    $Revision: 1.52.4.5 $ $Date: 2004/03/12 18:07:29 $
%-----------------------------------------------------------------------------
% main:
%
try
  [in,work,out] = setup(nargout,varargin{:});
catch
  rethrow(lasterror);
end

% This should take two iterations but only one call to
% analyze_trace.
%
iterations = 0;
while true 
  iterations = iterations + 1;

  % Look for any dependencies not covered by newdepfun.
  % In particular, analyze .fig files.
  %
  try
    [out.trace_list,work] = prepare_trace(out.trace_list,in,work);
  catch
    cleanup(work);
    rethrow(lasterror);
  end

  if ~work.trace_changed
    break
  end

  % If notrace then replace any temporaries by the real files
  % before calling analyze_trace
  %
  if in.notrace
    for i=1:length(work.tmp_files_ix)
      out.trace_list(work.tmp_files_ix(i)) = work.orig_files(i);
    end
  end
  
  try
    new_trace_list = analyze_trace(in,out.trace_list);
  catch
    cleanup(work);
    rethrow(lasterror);
  end
  
  if iterations == 1

    % After the first call to analyze_trace check the output
    % corresponding to the input and eliminate any duplicates.
    % After that there should not be any duplicates.
    %
    [work,out] = ...
		 fix_first_trace_results(new_trace_list,in,work,out);

    % If out.trace_list hasn't changed in length then break since there
    % were no files on the MATLABPATH to trace.
    %
    if length(out.trace_list) <= work.narg_files
      break;
    end
  else
    out.trace_list = new_trace_list;
  end
end

% Sort the list except for the original set of arguments
%
if ~in.nosort
  nargs = work.narg_files - work.narg_duplicate_files;
  out.trace_list = [out.trace_list(1:nargs); sort(out.trace_list(nargs+1:end))];
end

if length(out.trace_list) > work.narg_files

  % Call newdepfun with all the required arguments.
  %
  out = analyze_trace_all(in,work,out);
end

% Fix the output.
%
[out,work] = fix_output_data(in,out,work);

% Output the results
%
if in.report
  try
    output_report(work.noutput,in.report_file,in,out,work);
  catch
    cleanup(work);
    rethrow(lasterror);
  end
  if ~in.quiet
    format = ['==========================================================\n'...
              'depfun report file:    %s\n' ...
             ];
    fprintf(format,in.report_file);
  end
end

if ~in.quiet
  output_summary(work.noutput,in,out,work);
end

% Return the arguments
%
for i=1:nargout
  switch i
    case 1
      trace_list = out.trace_list;
    case 2
      builtins = out.builtins;
    case 3
      matlab_classes = out.matlab_classes;
    case 4
      prob_files = out.prob_files;
    case 5
      prob_symbols = out.prob_symbols;
    case 6
      eval_strings = out.eval_strings;
    case 7
      if ~in.calltree
        called_from = out.called_from;
      else
	called_from = out.call;
      end
    case 8
      opaque_classes = out.opaque_classes;
    otherwise
      error('Internal error.');
  end
end

cleanup(work);

return;
%---------------------------------------------------------------------------
% subfunctions:
% 
% analyze_fig_file	    - examines the HG structure in a .fig file.
% analyze_trace 	    - calls newdepfun with only one output argument.
% analyze_trace_all	    - calls newdepfun with the final list of files
%   			      and the final output list.
% cleanup		    - cleanup before exiting.
% create_callback_M_file    - creates a M-file function.
% create_call_list	    - creates the call list from the called_from list
% create_hg_cbnames 	    - generates and returns the factory HG callback
%			      names.
% create_tmpdir 	    - creates a temporary directory.
% find_fig_callback_strings - find callback strings in figure structure.
% fix_first_trace_results   - special fixup after the first call to
%			      newdepfun.
% fix_output_data	    - modifies data generated by newdepfun.
% next_arg_file		    - examines the next argument file.
% output_call_list	    - outputs the called from/call section of
%			      the full report.
% output_report		    - outputs the full report to a file.
% output_summary	    - outputs the summary report to the screen.
% prepare_trace 	    - scans the trace files with indices.
% setup 		    - initializes data structures and parses all
%                             the input.
% stdpath		    - convert file into a standard path.
%---------------------------------------------------------------------------
function [fig_cbnames,fig_cbstrings,work] = ...
					analyze_fig_file(figfile,in,work)
%ANALYZE_FIG_FILE	examines the HG structure in .fig file FIGFILE
%   and returns the list of callback names FIG_CBNAMES and callback strings
%   FIG_CBSTRINGS. Before the first .fig file generate the Handle Graphics
%   callback names to be used in analyzing the .fig files.

% Get HG figure structure. It must have only one item.
%
data = load('-mat',figfile);
fn = fieldnames(data);
if length(fn) > 1
  warning('MATLAB:DEPFUN:BadHGStructure','%s %s %s', '.fig file', ...
		 figfile, 'has more than one item.');
  return
end
hg_struct = data.(fn{1});

% Generate the Handle Graphics callback names before the first
% .fig file is analyzed.
%
if isempty(work.orig_files)
  if ~in.quiet
    format = '-> Generating Handle Graphics callback names to analyze .fig files . . .\n';
    fprintf(format);
  end
  work.hg_cbnames = create_hg_cbnames;
  if ~in.quiet
    format = '-> Done\n';
    fprintf(format);
  end
end

% Locate callback strings within HG structure
%
[fig_cbnames,fig_cbstrings] = find_fig_callback_strings(hg_struct,work.hg_cbnames);
%-----------------------------------------------------------------------------
function new_trace_list = analyze_trace(in,trace_list)
%ANALYZE_TRACE	calls newdepfun with only one output argument.

if in.toponly && ~in.verbose
  new_trace_list = newdepfun(trace_list,'-toponly');
elseif in.toponly && in.verbose
  new_trace_list = newdepfun(trace_list,'-toponly','-verbose');
elseif ~in.toponly && ~in.verbose
  new_trace_list = newdepfun(trace_list);
else
  new_trace_list = newdepfun(trace_list,'-verbose');
end
%---------------------------------------------------------------------------
function out = analyze_trace_all(in,work,out)
%ANALYZE_TRACE_ALL	calls newdepfun with the final list of files and
%   the final output list.

arglist = cell(1,work.newdepfun_nlhs);
if in.toponly && ~in.verbose
  [arglist{:}] = newdepfun(out.trace_list,'-toponly');
elseif in.toponly && in.verbose
  [arglist{:}] = newdepfun(out.trace_list,'-toponly','-verbose');
elseif ~in.toponly && ~in.verbose
  [arglist{:}] = newdepfun(out.trace_list);
else
  [arglist{:}] = newdepfun(out.trace_list,'-verbose');
end

for i=1:work.newdepfun_nlhs
  switch i
    case 1
      out.trace_list = arglist{1};
    case 2
      out.builtins = arglist{2};
    case 3
      out.matlab_classes = arglist{3};
    case 4
      out.prob_files = arglist{4};
    case 5
      out.called_from = arglist{5};
    case 6
      out.opaque_classes = arglist{6};
    otherwise
      error('Internal error.');
  end
end
%---------------------------------------------------------------------------
function cleanup(work)
%CLEANUP	cleanup before exiting.
%
% If the temporary directory name exists in WORK then remove it from the
% matlabpath and the temporary directory.

if ~isempty(work.tmp_dir)
  rmpath(work.tmp_dir);
  rmdir(work.tmp_dir,'s');
end
%---------------------------------------------------------------------------
function [file,work] = create_callback_M_file(fig_cbnames,fig_cbstrings,in,work)
%CREATE_CALLBACK_M_FILE	creates a M-file function of the form:
%
%   function  name
%   %
%   fig_cbstrings{1};	# fig_cbnames{1}
%   ...
%   fig_cbstrings{end};  # fig_cbnames{end}
%
%   where name is the filename without the '.m' extension of the
%   temporary file. The temporary name is:
%
%   tp<length(tmp_files_ix)>
%
%   Create a temporary directory and add it to the matlabpath if the
%   temporary filename count is one.

if length(work.tmp_files_ix) == 1
  work.tmp_dir = create_tmpdir;
end
filename = ['tp' num2str(length(work.tmp_files_ix))];
file = fullfile(work.tmp_dir, [filename '.m']);
fid = fopen(file,'wt');

% Generate the file
%
fprintf(fid,'%s\n',['function ' filename]);
fprintf(fid,'%s\n','%');
len = length(fig_cbstrings);
out = [repmat('  ',len,1) char(fig_cbstrings') ...
       repmat(';    % ', len,1) char(fig_cbnames')];
for i=1:len
  fprintf(fid,'%s\n',deblank(out(i,:)));
end

fclose(fid);

% [undocumented]: Save copy in current directory if savetmp flag is true.
%
if in.savetmp
  if ~in.quiet
    format = ['-> Callback strings from file: %s\n' ...
              '   Saved to: %s\n' ...
             ];
    fprintf(format,work.orig_files{end},[filename '.m']);
  end
  copyfile(file,[filename '.m']);
end
%---------------------------------------------------------------------------
function call = create_call_list(called_from)
%CREATE_CALL_LIST	takes the CALLED_FROM list and create the
%   inverse CALL list.
%
%   CALLED_FROM is a cell array of double arrays. CALL is also
%   is a cell array of double arrays.

len = length(called_from);
call = cell(len,1);
lenv = zeros(len,1);
lenv_inv = lenv;

% Determine the length of each called_from set
% the total number of nonzero entries
% 
sum = 0;
for i=1:len
   l = length(called_from{i});
   lenv(i) = l;
   sum = sum + l;
end

col1 = zeros(sum,1);
col2 = zeros(sum,2);

% Create a column of called_from indices (col1)
% and a column of corresponding call indices (col2)
%
sum = 0;
for i=1:len
  l = lenv(i);
  col1(sum+1:sum+l) = i;
  col2(sum+1:sum+l) = called_from{i};
  sum = sum + l;
end

% Sort the call indices and permute the called_from
% indices
%
[unusedTempVar,ix_sort] = sort(col2);
col1 = col1(ix_sort);

% Determine the length of each call set
%
for i=1:sum
  ix = col2(i);
  lenv_inv(ix) = lenv_inv(ix) + 1; 
end

% Create the call sets
%
sum = 0;
for i=1:len
  l = lenv_inv(i);
  call{i} = sort(col1(sum+1:sum+l));
  sum = sum + l;
end
%---------------------------------------------------------------------------
function hg_cbnames = create_hg_cbnames
%CREATE_HG_CBNAMES	generates and returns the factory HG callback names,
%   HG_CBNAMES.

% start with factory default list default
%
def = fieldnames(get(0,'factory'));

% derive a list of HG classes (start with known object)
%
hgcls = {'root'};
for i=1:length(def)
    ind = find(def{i} >= 'A'  &  def{i} <= 'Z');
    constr = lower(def{i}(ind(1):(ind(2)-1)));
    if ~strcmp(hgcls,constr)
        hgcls{end+1} = constr;
    end
end
hgcls = [{'root'}, sort(hgcls(2:end))];

%<<<<<<<<<<<<<<<<<<<<<<
%disp(hgcls)
%<<<<<<<<<<<<<<<<<<<<<<

% build complete list of properties
%
hg_cbnames = {};
for i=1:length(hgcls)

% create HG object
    
% Turn off figure visibility while creating figures- this
% prevents flashing.
%
  figVis = get(0,'defaultfigurevis');
  set(0,'defaultfigurevis','off');

  if i == 1, obj = 0; else obj = feval(hgcls{i}); end

% Set figure visibility to the original state.
%
  set(0,'defaultfigurevis',figVis);
    
% get and set property lists
%
  pg = fieldnames(get(obj));
  ps = fieldnames(set(obj));

  if i > 1, delete(obj); end

% remove duplicate get and set properties
%
  p = unique([pg; ps]);

% Cover factory settings only on the first iteration
%
  if i == 1, p = [def; p]; end

% Get the callbacks names. Look thru list of properties and
% extract callback names
%
  cb = {'callback'};
  for j=1:length(p)
    if strcmp(p{j}(end-2:end),'Fcn'), cb{end+1} = lower(p{j}); end
  end
  for j=1:length(p)

    % Work around front end bug - 207334 (27feb2004)
    % Currently cannot use:
    %   if length(p{j}) >= 8  &&  strcmp(p{j}(end-7:end),'Callback')
    %
    if length(p{j}) >= 8 
      tmp = p{j}(end-7:end);
      if strcmp(tmp,'Callback')
        cb{end+1} = lower(p{j});
      end
    end
  end
  hg_cbnames = [hg_cbnames; unique(cb')];
end
hg_cbnames = unique(hg_cbnames);
%---------------------------------------------------------------------------
function d = create_tmpdir
%CREATE_TMPDIR	creates a temporary directory. Will use 'tempname' function
%   to create the name. Loop until you find an unused name. Add it to the
%   matlabpath.

while true
  d = tempname;
  if ~exist(d,'dir') && ~exist(d,'file')
    mkdir(d);
    addpath(d);
    return;
  end
end
%---------------------------------------------------------------------------
function [cbnames,cbstrings] = find_fig_callback_strings(figstruct,hg_cbnames)
%FIND_FIG_CALLBACK_STRINGS	find and return callback strings CBSTRINGS in
%   figure structure, FIGSTRUCT, that use callback names, CBNAMES.	
%
%   Note: When you match a callback you can have:
%         1. function call with no arguments
%            ex: uimenu
%         2. function call without '('
%            ex: toolsmenufcn ToolsPost
%         3. function call with '('
%            ex: desktopmenufcn(gcbo, 'DesktopMenuCreate')
%
%   For a callback take the whole string.

cbnames = {};
cbstrings = {};

structnames  = fieldnames(figstruct);
lstructnames = lower(structnames);
nfield = length(structnames);

% Run thru all elements of input structure array.
%
for i=1:length(figstruct)

  % Run thru each field of structure
  %
  for j=1:nfield
    fi = figstruct(i).(structnames{j});
    if any(strcmp(hg_cbnames,lstructnames{j}))
      if ischar(fi)
        cbnames{end+1} = lstructnames{j};
        cbstrings{end+1} = fi;
      else
        warning('MATLAB:DEPFUN:NotAStringForCallback','%s %s %s', ...
		'Callback for name ', lstructnames{j}, 'not a string');
      end
    elseif isstruct(fi)
      [new_cbnames,new_cbstrings] = find_fig_callback_strings(fi,hg_cbnames); 
      cbnames = [cbnames new_cbnames];
      cbstrings = [cbstrings new_cbstrings];
    end
  end
end
if ~isempty(cbnames)
  s = cell(1,length(cbnames)); [s{:}] = deal(' ');
  [unusedTempVar,i] = unique(strcat(cbnames,s,cbstrings));
  cbnames = cbnames(i);
  cbstrings = cbstrings(i);
end
%---------------------------------------------------------------------------
function [work,out] = fix_first_trace_results(new_trace_list, ...
							 in,work,out)
%FIX_FIRST_TRACE_RESULTS	is called after the first call to newdepfun.
%   If there are duplicates in the original argument list then change:
%
%   narg_duplicate_files - set to the number of argument duplicates.
%   narg_duplicate_off   - set to the number of argument duplicates off
%                          MATLABPATH.
%   off_path             - adjust the indices.
%   tmp_files_ix         - adjust the indices.
%   trace_last_checked   - subtract off the number of duplicates.
%   trace_list           - remove duplicates keeping all other entries in
%                          order.
%
%   Also strip the trace_list down to just the list of the arguments that
%   not duplicates if all the arguments are off the MATLABPATH.

ixd = ismember(new_trace_list(1:work.narg_files),'')';
ix = ~ixd;
cs = cumsum(ix);
iyd = find(ixd == 1);
iy = find(ixd == 0);
if ~isempty(iyd)
  work.narg_duplicate_files = length(iyd);
  off_path = cs(setdiff(work.off_path,iyd));
  work.narg_duplicate_off = length(work.off_path) - length(off_path);
  work.off_path = off_path;
  work.tmp_files_ix = cs(setdiff(work.tmp_files_ix,iyd));
  work.trace_last_checked = work.trace_last_checked - work.narg_duplicate_files;
  if work.narg_files > length(work.off_path) + work.narg_duplicate_files
    if ~in.notrace
      out.trace_list = [new_trace_list(iy); new_trace_list(work.narg_files+1:end)];
    else
      out.trace_list = new_trace_list(iy);
    end
  elseif work.narg_files == work.narg_duplicate_files

    % Internal 'newdepfun' error. All arguments cannot be empty.
    %
    fprintf('Following arguments should not return empty . . .\n');
    for i=1:work.narg_duplicate_files
       fprintf('%5d: %s\n',i,out.trace_list{i});
    end
    warning('MATLAB:DEPFUN:NewdepfunInternalError','Internal ''newdepfun'' error');
    work.narg_duplicate_files = 0;
  else
    if ~in.quiet
      warning('MATLAB:DEPFUN:AllFilesOffMATLABPATH','All files off the MATLABPATH. No trace done.');
    end
    out.trace_list = new_trace_list(iy);
    out.called_from = cell(length(iy),1);
  end
else
  if work.narg_files > length(work.off_path)
    if ~in.notrace
      out.trace_list = new_trace_list;
    else
      out.trace_list = new_trace_list(1:work.narg_files);
    end  
  else
    if ~in.quiet
      warning('MATLAB:DEPFUN:AllFilesOffMATLABPATH','All files off the MATLABPATH. No trace done.');
    end
    out.trace_list = new_trace_list(1:work.narg_files);
    out.called_from = cell(work.narg_files,1);
  end
end
%---------------------------------------------------------------------------
function [out,work] = fix_output_data(in,out,work)
%FIX_OUTPUT_DATA	modifies data generated by newdepfun. The data
%   modified are:
%
%   out.trace_list	- replace any temporaries by the real files.
%   out.builtins	- save the original list in work.all_builtins
%			  and generate just the unique names.
%   out.called_from	- Clean out any leading zero from each cell array
%                         entry.
%   work.narg_referenced_files - determine its value.
%
%   If the -calltree argument is passed it creates out.call from
%   out out.called_from

% trace_list: Replace the temporary files
%
for i=1:length(work.tmp_files_ix)
  out.trace_list(work.tmp_files_ix(i)) = work.orig_files(i);
end

% builtins: Determine the names
%
if ~isempty(out.builtins)
  work.all_builtins = out.builtins;
  names = cell(length(out.builtins),1);
  for i=1:length(out.builtins)
    [unusedTempVar,names{i}] = fileparts(out.builtins{i});
  end
  out.builtins = unique(names);
end

% called_from: Clean out any zeros.
% 
if ~isempty(out.called_from)
  for i=1:length(out.called_from)
    ix = find(out.called_from{i} == 0);
    out.called_from{i}(ix) = [];
  end
end

% call: Create it from the called_from list if
%       -calltree option was passed
if in.calltree
   out.call = create_call_list(out.called_from);
end

% narg_referenced_files: Determine the number if called_from 
% 			 is determined.
%
if ~isempty(out.called_from)
  work.narg_referenced_files = ...
	sum(~cellfun('isempty',out.called_from(1:(work.narg_files-work.narg_duplicate_files))));
end
%---------------------------------------------------------------------------
function [trace_file,work] = next_arg_file(arg_file,narg_file,work)
%NEXT_ARG_FILE	examines the potential ARG_FILE file with index NARG_fILE
%   and returns a canonical version if required. It checks and records
%   whether the file is off the MATLABPATH.
%
%   Rule: If path is in the output of 'which' it is on the MATLABPATH.
%
%   Algorithm:
%     1. (out = which(arg_file)) == arg_file -> return [arg_file]
%     2. exist(arg_file,'dir') -> error
%     3. Handle which exceptions
%        [d,f,e] = arg_file
%        0. f is empty.
%           a. isempty(e) || e == '.'
%              error -> path is not a file
%           b. e is more than '.'
%              Note: A '.' file is never on the path.
%              out = stdpath(arg_file)
%              exist(out,'file'), (off the path) -> return [out]
%	       else -> Cannot locate file
%        1. e is empty
%           Note: Path needs to end in a '.' to get anything.
%           list = which('-all',[f '.']);
%           a. [d is empty]
%              [d,f,e] = out && length(e) > 1  -> return [arg_file]
%              [pwd file] in list -> return ([pwd arg_file])
%           b. [d is not empty] [partial or full]
%              file in list -> return [arg_file]
%	       [Works around gecko R14 198286 for partial paths]
%        2. e is '.'.
%           list = which('-all',[f e]);
%           a. [d is empty]
%              [pwd file] in list -> return ([pwd arg_file])
%           b. [d is not empty] [partial or full]
%              file in list -> return [arg_file]
%	       [Works around gecko R14 198073 for full paths]
%	       [Works around gecko R14 198286 for partial paths]
%        3. e is more than '.'
%           a. [d is empty]
%              ~isempty(out) -> return [arg_file]
%           b. [d is not empty] [partial or full]
%              list = which('-all',[f e]);
%              file in list -> return [arg_file]
%	       [Works around gecko R14 198286 for partial paths]
%     4. out = stdpath(arg_file)
%        exist(out) && in the file system using 'dir', (off the path),
%          return [out]
%     5. error: Cannot locate file
%
%   Which special cases:
%     1. 'x' exists ONLY in the filesystem:
%	 which('x.') -> [d x]
%     2. 'x.' exists (with 'x' or no 'x') in the filesystem:
%	 which('x.') -> [d x.]
%
%   Which inconsistencies: (bug)
%     ('x' and 'depfun.m' exist in the current directory)
%     1. which x.
%        /sandbox/martin/R14/projects/depfun/x
%        which /sandbox/martin/R14/projects/depfun/x
%        ... not found
%        which /sandbox/martin/R14/projects/depfun/x.<- gecko 198073
%        ... not found
%     2. which depfun
%        /sandbox/martin/R14/projects/depfun/depfun.m
%        which /sandbox/martin/R14/projects/depfun/depfun.m
%        /sandbox/martin/R14/projects/depfun/depfun.m
%
%   Relative paths on the MATLABPATH: (be careful there is a R14 bug)
%
%     Example: 1. >> addpath ..   (noncanonical partial path)
%	          >> which README.txt
%                 ../README.txt
%                 >> which ../README.txt
%            R13: same behavior
%	          ... not found.
%	       2. >> addpath test (canonical partial path) (bug)
%	          >> which README.txt
%		  test/README.txt
%                 >> which test/README.txt
%	          ... not found. <- gecko 198286
%            R13: test/README.txt

% Check as is.
%
fullname = which(arg_file);
if strcmp(fullname,arg_file)
  trace_file = arg_file;
  return
end

% Error if a directory
%
if exist(arg_file,'dir')
  error('MATLAB:DEPFUN:FileIsADirectory','''%s'' %s', ...
                     arg_file, 'argument is a directory. Must be a file');
end

% Handle the 'which' exceptions

[d,f,e] = fileparts(arg_file);
if isempty(f)
  if isempty(e) || strcmp(e,'.')
    error('MATLAB:DEPFUN:PathNotAFile','''%s'' %s', ...
                     arg_file, 'argument is not a file');
  else
    full_arg_file = stdpath(arg_file);
    if exist(full_arg_file,'file')
      work.off_path(end+1) = narg_file;
      trace_file = full_arg_file;
      return
    else
      error('MATLAB:DEPFUN:FileDoesNotExist','''%s'' %s', ...
                     arg_file, 'argument does not exist');
    end
  end
end
if isempty(e)
  list = which('-all',[f '.']);
  if isempty(d)		% simple name
    [unusedTempVar,unusedTempVar,e] = fileparts(fullname);
    if length(e) > 1
      trace_file = arg_file;
      return
    end
    full_arg_file = fullfile(pwd,arg_file);
    if ~isempty(strcmp(full_arg_file,list))
      trace_file = full_arg_file;
      return
    end
  else			% partial or full path
    if ~isempty(strcmp(arg_file,list))
      trace_file = arg_file;
      return
    end
  end
elseif strcmp(e,'.')
  list = which('-all',[f e]);
  if isempty(d)		% simple name
    full_arg_file = fullfile(pwd,arg_file);
    if ~isempty(strcmp(full_arg_file,list))
      trace_file = full_arg_file;
      return
    end
  else			% partial or full path
    if ~isempty(strcmp(arg_file,list))
      trace_file = arg_file;
      return
    end
  end
else
  if isempty(d)		% simple name
    if ~isempty(fullname)
      trace_file = fullname;
      return
    end
  else			% partial or full path
    list = which('-all',[f e]);
    if ~isempty(strcmp(arg_file,list))
      trace_file = arg_file;
      return
    end
  end
end

% File cannot be found by which. Try exist.
%
full_arg_file = stdpath(arg_file);
if exist(full_arg_file,'file')
  [d,f,e] = fileparts(full_arg_file);
  flist = dir(d);
  if ~isempty(strcmp([f e],{flist.name}))
    work.off_path(end+1) = narg_file;
    trace_file = full_arg_file;
    return
  end
end

error('MATLAB:DEPFUN:FileDoesNotExist','''%s'' %s', ...
      	arg_file, 'argument does not exist');
%---------------------------------------------------------------------------
function output_call_list(fid,trace_list,call_list,in,work)
%OUTPUT_CALL_LIST	outputs the called from/call section of the full
%   report.

nper_line = 10;
if length(call_list)
  ntmp = 0;
  for i=1:length(call_list)
    fprintf(fid,'   %5d: %s\n',i, ...
	    trace_list{i});
    n = length(call_list{i});
    if n > 0
      if ~in.expand
	fprintf(fid,'\n');
        for j=1:nper_line:n
	  fprintf(fid,'   %5s ',' ');
          if j+nper_line-1 <= n
	    fprintf(fid,' %5d',call_list{i}(j:j+nper_line-1));
	  else
	    fprintf(fid,' %5d',call_list{i}(j:end));
          end
	  fprintf(fid,'\n');
	end
	fprintf(fid,'\n');
      else
	fprintf(fid,'\n');
	for j = 1:n 
	  fprintf(fid,'   %5s ',' ');
	  ix = call_list{i}(j);
	  fprintf(fid,' %5d: %s\n',ix,trace_list{ix});
	end
	fprintf(fid,'\n');
      end
    else
      fprintf(fid,'\n');
      fprintf(fid,'   %5s  %s\n',' ', '[none]');
      fprintf(fid,'\n');
    end
  end
  if ~isempty(work.tmp_files_ix) && ...
    any(find(work.tmp_files_ix == i))
    ntmp = ntmp + 1;
    format = '          %s\n';
    fprintf(fid,format,['-> Generated M-file with callbacks: ' ...
	    work.tmp_files{ntmp}]);
    lines = textread(work.tmp_files{ntmp}, '%s', ...
		     'delimiter','\n','whitespace','');
    fprintf(fid,'             %s\n',lines{:});
    fprintf(fid,'\n');
  end
else
  fprintf(fid,'\n');
  format = '   [none]\n';
  fprintf(fid,format);
  fprintf(fid,'\n');
end
%---------------------------------------------------------------------------
function output_report(noutput,report_file,in,out,work)
%OUTPUT_DATA	outputs the full report to a file.

fid = fopen(report_file,'wt');
if fid < 0
  error('MATLAB:DEPFUN:CannotOpenFileForWrite','%s %s', ...
		'Cannot open file',report_file);
end

divider = '   ----------------------------------------------------------\n';

format = ['\n', ...
	  'depfun report:%s\n' ...
         ];
if in.toponly
  toponly_msg = ' (top only)';
else
  toponly_msg = '';
end 
fprintf(fid,format,toponly_msg);

% Output the arguments
%
for i=1:noutput
  switch i
    case 1		% trace list
      %----------------------------------------------------------
      %====================== trace list:
      format = ['\n', ...
		'-> trace list:\n' ...
	       ];
      fprintf(fid,format);
      if noutput < 7
        fprintf(fid,divider); 			% divider
        if isempty(work.tmp_files)
          for i=1:length(out.trace_list)
	    fprintf(fid,'   %5d: %s\n',i,out.trace_list{i});
          end
        else
          ntmp = 0;
          for i=1:length(out.trace_list)
	    fprintf(fid,'   %5d: %s\n',i,out.trace_list{i});
	    if any(find(work.tmp_files_ix == i))
	      ntmp = ntmp + 1;
              format = '          %s\n';
	      fprintf(fid,format,['-> Generated M-file with callbacks: ' ...
				   work.tmp_files{ntmp}]);
              lines = textread(work.tmp_files{ntmp}, '%s', ...
			   'delimiter','\n','whitespace','');
	      fprintf(fid,'             %s\n',lines{:});
            end
          end
        end
        fprintf(fid,divider);			% divider
      else
	if ~in.calltree
          format = ['\n', ...
		    '   For complete list: See -> called from:\n' ...
	           ];
        else
          format = ['\n', ...
		    '   For complete list: See -> call:\n' ...
	           ];
        end
        fprintf(fid,format);
      end
      %====================== Files not on MATLABPATH: 
      format = ['\n', ...
		'   Files not on MATLABPATH:\n' ...
	       ];
      fprintf(fid,format);
      fprintf(fid,divider);			% divider
      if length(work.off_path)
	for i=1:length(work.off_path)
	  fprintf(fid,'   %5d: %s\n',i,out.trace_list{work.off_path(i)});
        end 
      else
	format = '   [none]\n';
        fprintf(fid,format);
      end
      fprintf(fid,divider);			% divider
      %====================== HG factory callback names:
      if ~isempty(work.tmp_files)
        format = ['\n', ...
		'   HG factory callback names:\n' ...
	       ];
        fprintf(fid,format);
        fprintf(fid,divider);			% divider
	for i=1:length(work.hg_cbnames)
	  fprintf(fid,'   %5d: %s\n',i,work.hg_cbnames{i});
        end 
      end
      %----------------------------------------------------------
    case 2		% builtin list
      %----------------------------------------------------------
      format = ['\n', ...
		'-> builtin list:\n' ...
	       ];
      fprintf(fid,format);
      fprintf(fid,divider);			% divider
      if length(out.builtins)
	for i=1:length(out.builtins)
	  fprintf(fid,'   %5d: %s\n',i,out.builtins{i});
        end 
      else
	format = '   [none]\n';
        fprintf(fid,format);
      end
      fprintf(fid,divider);			% divider
      %----------------------------------------------------------
    case 3		% MATLAB classes
      %----------------------------------------------------------
      format = ['\n', ...
		'-> MATLAB classes:\n' ...
	       ];
      fprintf(fid,format);
      fprintf(fid,divider);			% divider
      if length(out.matlab_classes)
	for i=1:length(out.matlab_classes)
	  fprintf(fid,'   %5d: %s\n',i,out.matlab_classes{i});
        end 
      else
	format = '   [none]\n';
        fprintf(fid,format);
      end
      fprintf(fid,divider);			% divider
      %----------------------------------------------------------
    case 4		% problem list
      %----------------------------------------------------------
      format = ['\n', ...
		'-> problem list:\n' ...
	       ];
      fprintf(fid,format);
      fprintf(fid,divider);			% divider
      if length(out.prob_files)
	for i=1:length(out.prob_files)
	  fprintf(fid,'   %5d: %s\n',out.prob_files(i).listindex, ...
				out.prob_files(i).name);
	  fprintf(fid,'%s',out.prob_files(i).errmsg);
          fprintf(fid,'\n');
        end 
      else
	format = '   [none]\n';
        fprintf(fid,format);
      end
      fprintf(fid,divider);			% divider
      %----------------------------------------------------------
    case 5		% problem symbols: NOT IMPLEMENTED
      %----------------------------------------------------------
      format = ['\n', ...
		'-> problem symbols: NOT IMPLEMENTED\n' ...
	       ];
      fprintf(fid,format);
      %----------------------------------------------------------
    case 6		% eval strings:    NOT IMPLEMENTED
      %----------------------------------------------------------
      format = ['\n', ...
		'-> eval strings:    NOT IMPLEMENTED\n' ...
	       ];
      fprintf(fid,format);
      %----------------------------------------------------------
    case 7		% called from / call list
      if ~in.calltree
        %----------------------------------------------------------
        format = ['\n', ...
		'-> called from list: (by trace list)\n' ...
	       ];
        fprintf(fid,format);
        fprintf(fid,divider);			% divider
        output_call_list(fid,out.trace_list,out.called_from,in,work);
        fprintf(fid,divider);			% divider
        %----------------------------------------------------------
      else
        %----------------------------------------------------------
        format = ['\n', ...
		'-> call list: (by trace list)\n' ...
	       ];
        fprintf(fid,format);
        fprintf(fid,divider);			% divider
        output_call_list(fid,out.trace_list,out.call,in,work);
        fprintf(fid,divider);			% divider
        %----------------------------------------------------------
      end
    case 8		% opaque classes
      %----------------------------------------------------------
      format = ['\n', ...
		'-> opaque classes:\n' ...
	       ];
      fprintf(fid,format);
      fprintf(fid,divider);			% divider
      if length(out.opaque_classes)
	for i=1:length(out.opaque_classes)
	  fprintf(fid,'   %5d: %s\n',i,out.opaque_classes{i});
        end 
      else
	format = '   [none]\n';
        fprintf(fid,format);
      end
      fprintf(fid,divider);			% divider
      %----------------------------------------------------------
    otherwise
      error('Internal error.');
  end
end

format = '\n';
fprintf(fid,format);

fclose(fid);
%---------------------------------------------------------------------------
function output_summary(noutput,in,out,work)
%OUTPUT_SUMMARY	outputs the summary report to the screen.

fid = 1;
data = {
	1 [] '==========================================================\n'; ...
	1 [] 'depfun report summary:%s\n'; ...
	1 [] '----------------------------------------------------------\n'; ...
	1 [] '-> trace list:       %5d files  (total)\n'; ...
        1 [] '                     %5d files  (total arguments)\n'; ...
        1 [] '                     %5d files  (arguments off MATLABPATH)\n'; ...
        1 [] '                     %5d files  (argument duplicates on MATLABPATH)\n'; ...
        1 [] '                     %5d files  (argument duplicates off MATLABPATH)\n'; ...
	2 [] '-> builtin list:     %5d names\n'; ...
	3 [] '-> MATLAB classes:   %5d names  (builtin, MATLAB OOPS)\n'; ...
	4 [] '-> problem list:     %5d files  (argument)\n'; ...
	4 [] '                     %5d files  (other)\n'; ...
	5 [] '-> problem symbols:  NOT IMPLEMENTED\n'; ...
	6 [] '-> eval strings:     NOT IMPLEMENTED\n'
       };
if ~in.calltree
data = [data;
       {
        7 [] '-> called from list: %5d files  (argument unreferenced)\n'; ...
        7 [] '                     %5d files  (argument referenced)\n'; ...
        7 [] '                     %5d files  (other referenced)\n'; ...
        7 [] '                     %5d files  (other unreferenced)\n' ...
       }];
else
data = [data;
       {
        7 [] '-> call list:        %5d files  (argument no calls)\n'; ...
        7 [] '                     %5d files  (argument with calls)\n'; ...
        7 [] '                     %5d files  (other with calls)\n'; ...
        7 [] '                     %5d files  (other no calls)\n' ...
       }];
end
data = [data;
       {
	8 [] '-> opaque classes:   %5d names  (Java, etc.)\n'; ...
        1 [] '----------------------------------------------------------\n'; ...
        1 [] 'Notes: 1. Use argument  ''-quiet'' to not print this summary.\n'; ...
        1 [] '       2. Use arguments ''-print'',''file'' to produce a full\n'; ...
	1 [] '          report in file.\n'; ...
	1 [] '       3. Use argument  ''-all'' to display all possible\n'; ...
        1 [] '          left hand side arguments in the report(s).\n'; ...
	1 [] '==========================================================\n' ...
       }];
data_len = size(data,1);

n = 1;
for i=1:noutput
  switch i
    case 1
      len_trace_list = length(out.trace_list);
      data{n  ,2} = [];
      if in.toponly
        data{n+1,2} = ' (top only)';
      else
        data{n+1,2} = '';
      end 
      data{n+2,2} = [];
      data{n+3,2} = len_trace_list;
      data{n+4,2} = work.narg_files;
      data{n+5,2} = length(work.off_path);
      data{n+6,2} = work.narg_duplicate_files - work.narg_duplicate_off;
      data{n+7,2} = work.narg_duplicate_off;
      n = n+8;
    case 2
      data{n  ,2} = length(out.builtins);
      n = n+1;
    case 3
      data{n  ,2} = length(out.matlab_classes);
      n = n+1;
    case 4
      actual_narg_files = work.narg_files - ...
			  work.narg_duplicate_files;
      nprob_files = length(out.prob_files);
      prob_files_ix = [out.prob_files.listindex];
      narg_prob_files = sum(ismember(1:actual_narg_files, ...
			             prob_files_ix));
      data{n  ,2} = narg_prob_files;
      data{n+1,2} = nprob_files - narg_prob_files;
      n = n+2;
    case 5
      n = n+1;
    case 6
      n = n+1;
    case 7
      if ~in.calltree
        unreferenced_ix = find(cellfun('isempty',out.called_from) == 1);
      else
        unreferenced_ix = find(cellfun('isempty',out.call) == 1);
      end
      narg_unreferenced = sum(ismember(1:actual_narg_files, ...
			      unreferenced_ix));
      other_unreferenced = length(unreferenced_ix) - narg_unreferenced;
      data{n  ,2} = narg_unreferenced;
      data{n+1,2} = actual_narg_files - narg_unreferenced;
      data{n+2,2} = len_trace_list - actual_narg_files - ...
		    other_unreferenced;
      data{n+3,2} = other_unreferenced;
      n = n+4;
    case 8
      data{n  ,2} = length(out.opaque_classes);
    otherwise
      error('Internal error.');
  end
end

for i=1:data_len
  if data{i,1} <= noutput
    fprintf(fid,data{i,3},data{i,2});
  end
end
%---------------------------------------------------------------------------
function  [trace_list,work] = prepare_trace(trace_list,in,work)
%PREPARE_TRACE	scans the trace files with indices
%      (work.trace_last_checked+1:end)
%   looking for dependencies that are currently not handled by newdepfun
%
%   1. '.fig' files are looked for and analyzed.

ix = work.trace_last_checked+1:length(trace_list);
if isempty(ix)
  work.trace_changed = false;
  return
end
figlist = regexp(trace_list(ix),'.*(\.fig|\.FIG)$','match');
ix = ix(~cellfun('isempty',figlist));
iy = ix;
if ~isempty(ix)
  figlist = [figlist{:}];

  % Now all the .fig files will be full paths because they have an
  % extension.
  %
  % ufiglist = figlist(i)
  % figlist  = ufiglist(j)
  %
  [ufiglist,unusedTempVar,j] = unique(figlist);

  % To handle duplicates start with an empty work cell array the size
  % of ufiglist. Loop through the original figlist list and change any
  % .fig file to a temporary file if it has callbacks. Update the work
  % array. Keep track of just the first entries in the ix array that
  % use temporary files.
  %
  actual_figlist = cell(1,length(ufiglist));
  for k=1:length(figlist)

    % If already processed then use values already saved.
    %
    if ~isempty(actual_figlist{j(k)})
      figlist{k} = actual_figlist{j(k)};
    else

      % Analyze only if on the path
      %
      if isempty(find(work.off_path == ix(k),1))
        [fig_cbnames,fig_cbstrings,work] = ...
				analyze_fig_file(figlist{k},in,work);
        if ~isempty(fig_cbnames)

	  % Create a temporary M-file with calls to the callbacks and
          % returns the name. If the length of temp_files is one
          % then the temporary directory needs to be added to the path.
	  %
          work.tmp_files_ix = [work.tmp_files_ix ix(k)];
          work.orig_files = [work.orig_files {figlist{k}}];
	  [figlist{k},work] = create_callback_M_file(fig_cbnames,fig_cbstrings,in,work);
          work.tmp_files = [work.tmp_files {figlist{k}}];
        end
      end
      actual_figlist{j(k)} = figlist{k};
    end
  end
  work.trace_last_checked = length(trace_list);
  trace_list(iy) = figlist;
elseif work.trace_last_checked > 0
  work.trace_changed = false;
  work.trace_last_checked = length(trace_list);
else
  work.trace_last_checked = length(trace_list);
end
%---------------------------------------------------------------------------
function [in,work,out] = setup(nout,varargin)
%SETUP	initializes data structures and parses all the input
%   arguments.

out = struct('trace_list', [], ...
             'builtins', [], ...
             'matlab_classes', [], ...
             'prob_files', [], ...
             'prob_symbols', [], ...
             'eval_strings', [], ...
             'called_from', [], ...
	     'call', [], ...
             'opaque_classes', [] ...
            );
out.trace_list = cell(length(varargin),1);
out.prob_files = struct('name', {}, ...
		        'listindex', {}, ...
			'errmsg', {} ...
		       );
out.prob_symbols = struct('name', {}, ...
			  'fcn_id', {} ...
			 );
out.eval_strings = struct('fcn_name', {}, ...
			  'lineno', {} ...
			 );
out.called_from = {};
out.call = {};

work = struct('narg_files', 0, ...             % number of original args
	      'narg_referenced_files', 0, ...  % number of referenced args
	      'narg_duplicate_files', 0, ...   % number of duplicate args
              'narg_duplicate_off', 0, ...     % number of duplicate args off MATLABPATH
              'off_path', [], ...              % index set off path
              'trace_last_checked', 0, ...     % number checked so far
              'trace_changed', true, ...       % set to false when no trace changes
	      'tmp_dir', '', ...	       % temporary directory
	      'orig_files', [], ...	       % original files that were temped
	      'hg_cbnames', [], ...	       % Handle Graphics callback names
	      'tmp_files_ix', [], ...	       % index set of temporaries
	      'tmp_files', [], ...	       % filenames of the temporaries
	      'all_builtins', [], ...          % cell array of builtins
	      'newdepfun_nlhs', [], ...	       % number of newdepfun left hand sides
	      'noutput', [] ...		       % number of arguments to report
             );

in = struct('quiet', false, ...
            'report', false, ...               % set to true the -print option
            'report_file', '', ...             % set to the argument following -print
            'toponly', false, ...	       % set to true by the -toponly option
	    'verbose', false, ...	       % set to true by the -verbose option
	    'notrace', false, ...              % set to true by the -notrace option
	    'expand', false, ...	       % set to true by the -expand option
	    'calltree', false, ...	       % set to true by the -calltree option
	    'savetmp', false, ...	       % [undocumented] set to true by the
 			     ...	       % -notrace option
	    'nosort', false ...		       % [undocumented] set to true by the
			     ...	       % -nosort option
           );

maxnout = 8;
if nout == 0
  work.newdepfun_nlhs = 1;
elseif nout <= 4
  work.newdepfun_nlhs = nout;
elseif nout <= 6
  work.newdepfun_nlhs = 4;
elseif nout <= maxnout
  work.newdepfun_nlhs = nout - 2;
else
  error('MATLAB:DEPFUN:NumberOfOutputArguments',nargchk(0,maxnout,nout));
end
if nout == 0
  work.noutput = 1;
else
  work.noutput = nout;
end

% Parse the input arguments
%
nin = length(varargin);
narg_files = 0;
i = 1;
while i <= nin
  if isa(varargin{i},'char')
    switch varargin{i}
      case '-toponly'
	in.toponly = true;
      case '-nographics'
	warning('MATLAB:DEPFUN:Deprecated','-nographics argument no longer supported.');
      case '-alwayslog'
	warning('MATLAB:DEPFUN:Deprecated','-alwayslog argument no longer supported.');
      case '-verbose'
        in.verbose = true;
      case '-quiet'
	in.quiet = true;
      case '-all'
	work.newdepfun_nlhs = maxnout - 2;
	work.noutput = maxnout;
      case '-print'
	if i < nin
	  i = i + 1;
	  in.report = true;
	  in.report_file = varargin{i};
	else
          error('MATLAB:DEPFUN:NoPrintFile','No print file argument.');
        end
      case '-notrace'
        in.notrace = true;
      case '-expand'
	in.expand = true;
      case '-calltree'
	in.calltree = true;
      case '-savetmp'	% [undocumented]
        in.savetmp = true;
      case '-nosort'	% [undocumented]
	in.nosort = true;
      otherwise
        [out.trace_list{narg_files+1},work] = next_arg_file(varargin{i}, ...
						     narg_files+1,work);
        narg_files = narg_files + 1;
    end
  elseif isa(varargin{i},'cell')
    out.trace_list = [out.trace_list; cell(length(varargin{i}),1)];
    for j=1:length(varargin{i})
      if isa(varargin{i}{j},'char')
        [out.trace_list{narg_files+1},work] = next_arg_file(varargin{i}{j}, ...
						     narg_files+1,work);
        narg_files = narg_files + 1;
      else 
        error('MATLAB:DEPFUN:WrongClass','%s %d %s','Argument',i, ...
				         'is not a cell array of strings.');
      end
    end
  else
    error('MATLAB:DEPFUN:WrongClass','%s %d %s','Argument',i, ...
				     'is not a character or cell array.');
  end
  i = i + 1;
end

if narg_files == 0
  error('MATLAB:DEPFUN:NoTraceArguments','No arguments to trace.');
else
  out.trace_list = out.trace_list(1:narg_files);
  work.narg_files = narg_files;
end

%---------------------------------------------------------------------------
function fn = stdpath(file,root)
%STDPATHmake FILE into a standard path. It removes all .. or .
%   An error occurs if the path goes beyond the root directory or driver.
%
%   If file is relative, then root is used instead of pwd.

if nargin == 1, root = pwd; end
%
if ispc, file = strrep(file,'/','\'); end
if isempty(deblank(file))
  fn = '';
  return
else
  file = [file filesep];
end

[dirname,fname,fext] = fileparts(file);
if isempty(dirname)
  fn = fullfile(root,file);
  return
end

% If relative path add on root to the front
%
if (ispc && length(dirname) == 1) || ...
   (ispc && length(dirname) > 1 && ...
   ~strcmp(dirname(2:2),':') && ~strcmp(dirname(1:2),[filesep filesep])) || ...
   (isunix && ~strcmp(dirname(1:1), filesep))
  dirname = fullfile(root,dirname);
end

% Get the root (<letter>: or \\ on PC or / on UNIX/Linux/Mac)
%
if ispc
   root = dirname(1:2);
else
   root = dirname(1:1);
end

% At the root directory already
%
if strcmp(root,dirname)
  fn = fullfile(dirname,[fname fext]);
  return
end

% Peel off the root and add separators to front and back
%
if ispc 
   dirname2 = [filesep dirname(3:end) filesep];
else
   dirname2 = [filesep dirname(2:end) filesep];
end

k = find(dirname2==filesep);
ixdirs = find((diff(k)-1)~=0);
n = length(ixdirs);

% Run through all the directories handling '..' and '.'
%
dirs = cell(n,1);
ndirs = 0;
for i=1:n
  dir = dirname2(k(ixdirs(i))+1:k(ixdirs(i)+1)-1);
  if strcmp(dir,'.'), continue; end
  if strcmp(dir,'..')
    ndirs = ndirs - 1;
  else
    ndirs = ndirs + 1;
    dirs{ndirs} = dir;
  end
end
%
fn = fullfile(root,dirs{1:ndirs},[fname fext]);
if ndirs < 0
  error('MATLAB:DEPFUN:PathBeyondRoot','%s %s %s','File', ...
	 file,'goes beyond the root directory or drive.');
end
%---------------------------------------------------------------------------
