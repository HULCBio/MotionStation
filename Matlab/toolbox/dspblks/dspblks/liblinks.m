function ret_paths = liblinks(varargin)
%LIBLINKS Display and return library link information.
%   The full path to each library block found in a model is
%   displayed below the block, suppressing the original block
%   name until the link display is turned off.  The search
%   descends down to all levels of the model.
%
%   A summary report indicating the number of blocks linked to
%   each library is displayed in the MATLAB command window when
%   the link display is turned on.
%
%   Attempts to save or run the model while the link display is
%   turned on will automatically turn off the link display.
%
%   liblinks(SYS) toggles the display of block links in system
%   SYS.  LIBLINKS(SYS,MODE) directly sets the link display state
%   by setting MODE to 'on', 'off', or 'toggle'.  By default, SYS
%   is the current system (gcs) and MODE is set to 'toggle'.
%
%   LIBLINKS(SYS,MODE,LIB) specifies that only links to library
%   LIB should be displayed.  For example, setting LIB to 'mylib'
%   will display library paths for blocks which are linked to the
%   library 'mylib'.  By default, LIB is set to '', indicating
%   that all library links are to be displayed, regardless of the
%   library to which they are linked.
%
%   Multiple libraries may be specified by passing a cell-array of
%   strings.  For example, LIB={'lib1','lib2'} will display block
%   links for blocks which are linked to libraries 'lib1' and 'lib2'.
%
%   Several "macro" names are additionally supported for LIB, and
%   map directly to preset collections of library names which
%   are contained within the corresponding blockset products.
%
%     Macro     Product
%    ---------  ------------------------------------
%    'comm15'   Communications Blockset Version 1.5
%    'comm25'   Communications Blockset Version 2.5 (obsoleted libraries only)
%    'comm3'    Communications Blockset Version 3.0
%    'dsp2'     Signal Processing Blockset Version 2
%    'dsp3'     Signal Processing Blockset Version 3
%    'dsp4'     Signal Processing Blockset Version 4
%    'fp2'      Fixed Point Blockset Version 2
%    'sl2'      Simulink Version 2
%    'sl3'      Simulink Version 3
%
%   Macros may be combined together or with additional library names.
%   For example, setting LIB to {'dsp2','mylib'} will display block
%   path information for all blocks which are linked to any library
%   in Signal Processing Blockset Version 2, and to the user-defined 
%   library named 'mylib'.
%
%   LIBLINKS(SYS,MODE,LIB,CLRS) specifies colors used to highlight
%   blocks corresponding to each library specified by LIB.  Either
%   exactly one color must be specified, or one color for each entry
%   in LIB.  Colors must be strings such as 'red', 'blue', and 'black'.
%   By default, all blocks are highlighted in red.
%
%   BLKS=LIBLINKS(...) returns a structure containing the full path
%   to each reported link.  The structure has one field named after
%   each library entry specified in the LIB argument.  For example,
%   if LIB is {'dsp2','mylib'}, BLKS will have two fields, .dsp2 and
%   .mylib.  The content of each field is a cell-array of path names,
%   one path per linked block found to be linked to the corresponding
%   library.


% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.14.4.4 $ $Date: 2004/04/12 23:05:23 $

% ----------------------------------------------------

% Process arguments:
%
[sys, mode, exp_libs, exp_clrs, exp_idx, ...
      libs, clrs] = process_args(varargin{:});

if isempty(sys),
   % There are no open Simulink models
   if nargout>0, ret_paths={}; end
   return
end

gsys     = sys;   %system in which links need to be displayed
sys      = bdroot(sys);
isLocked = syslocked(sys);
isDirty  = get_param(sys,'dirty');

[blk_paths, mode] = UpdateBlockLinkDisplay(sys, gsys, mode, ...
   exp_libs, exp_clrs, exp_idx, libs, isLocked);

if ~isLocked,
   set_param(sys,'dirty',isDirty);  % Reset dirty status
end

if strcmp(mode,'on'),
   % Only display if mode is 'on'
   % NOTE: 'toggle' gets remapped to 'on' by UpdateBlockLinkDisplay
   %       (but only if at least one block is in the model!)
   DisplaySummary(blk_paths, sys, mode, libs, clrs, isLocked);
end

if nargout>0,
   % Return paths to linked blocks:
   ret_paths = blk_paths;
end

return

% ----------------------------------------------------
% Local Functions
% ----------------------------------------------------

% ----------------------------------------------------
function y = isLinkDisplayOn(sys)

% The model has the liblinks display turned on if
% the Tag property contains a pipe-delimited string
% with the string 'liblinks' as the first entry:

tag = get_param(sys,'Tag');

% Get 1st pipe-delimited string entry.
% Do not generate an error if the Tag is not
% a pipe-delimited string (returns empty in that case).
firstPipe = get_pipestr(tag,1,1);
y = strcmp(firstPipe, 'liblinks');

return


% ----------------------------------------------------
function [blk_paths,mode] = UpdateBlockLinkDisplay(sys, gsys, mode, ...
   exp_libs, exp_clrs, exp_idx, libs, isLocked)

%   UpdateBlockLinkDisplay(BLKS,MODE) turns the link display
%   on or off for each linked block found in the cell-array of
%   strings in BLKS.  MODE may be 'on', 'off', or 'toggle'.
%
%   BLKS=UpdateBlockLinkDisplay(BLKS,MODE) returns a structure
%   containing the full path to each block in the model which has a link.
%   The structure has the fields "dspv2", "dspv3", and "other".  The
%   content of each field is a cell-array of path strings, one string per
%   block found to be linked to Signal Processing Blockset verion 2, 
%   version 3, or linked to a blockset other than Signal Processing 
%   Blockset.

% SYS: System name
% MODE: 'on', 'off', or 'toggle'
% EXP_LIBS: Expanded library list
% EXP_CLRS: Expanded color list
% EXP_IDX: Index into LIBS list for each entry in EXP_LIBS
%          Since LIBS may contain "macros", multiple entries in EXP_LIBS
%          may reference the same (macro) entry in LIBS
% LIBS:    List of libraries, possibly including macro names
% ISLOCKED: True is SYS is locked

% NOTE:
%   This function changes the UserData and several other parameters of each
%   linked block.  The function caches away any PREVIOUS parameter values
%   and restores them when the display is turned off.

%Store warning status and temporarily switch off warnings
%This is to avoid simulink warning since we will be modifying
%the blocks under library links also
s = warning('off', 'all');

% Preset fields of structure to the (macro) library names
% Each field will contain a cell-array of block paths.
% If libs is empty, we directly return a cell-array, and
%   no structure is created.
blk_paths = {};
for i=1:length(libs),
   blk_paths = setfield(blk_paths,libs{i},{});
end

% Find all blocks in system:
all_blks = find_system(gsys,'LookUnderMasks','all','FollowLinks','on','type','block');

% Have *any* links been found yet?
any_links = 0;

% Has the link display been turned on?
modelHasLinkFcns = isLinkDisplayOn(sys);

% If mode is 'toggle', set it to 'on' or 'off' as appropriate:
if strcmp(mode,'toggle'),
   if modelHasLinkFcns,
      mode='off';
   else
      mode='on';
   end
end
wantToShowLinks = strcmp(mode,'on');

% If modelHasLinkFcns, and we're attempting to turn
% display back on, then turn off display fully ... first.
%
% This is in case the "criterion" has changed, such as
% that the user previously turned on the display for dspv2,
% but now wants it for dspv3.
if modelHasLinkFcns & strcmp(mode,'on'),
   liblinks(sys,'off');
end

for i=1:length(all_blks),
   blk  = all_blks{i};
   link = get_param(blk,'LinkStatus');
   
   % If block is NOT linked or implicit, skip it:
   if ~strcmp(link,'none') & ~strcmp(link,'implicit')
      % Cannot show link unless library is found in user's list:
      canShowLink = 0;
      
      % See if we turned on link display previously:
      curUser = get_param(blk,'UserData');
      
      % Check if block link display is currently on
      % blkIsShowingLink = modelHasLinkFcns;
      blkIsShowingLink=0;
      if iscell(curUser),
         c = curUser{1};
         if strcmp(c,'liblinks'),
            blkIsShowingLink=1;
         end
      end
      
      % Get link path:
      if  strcmp(link,'inactive'),
          ref=get_param(blk,'AncestorBlock');
      elseif strcmp(link,'resolved'),
         ref=get_param(blk,'ReferenceBlock');
      else
         ref=get_param(blk,'SourceBlock');
      end
      
      % Determine if block is in a target library:
      if isempty(exp_libs),
         % All:
         blk_paths{end+1} = blk;
         fg = exp_clrs{1};
         canShowLink = 1;
         any_links = 1;
         
      else
         % Check for match to specific library:
         
         % Determine to which library the link points:
         reflib = ref;
         i=find(reflib=='/');
         if ~isempty(reflib),
            reflib = reflib(1:i(1)-1);
         end
      
         idx = strmatch(reflib, exp_libs, 'exact');
         
         if ~isempty(idx),
            % Map idx from "exp_libs" list into (macro) "libs" list
            
            % NOTE: idx is generally a scalar, meaning that the given block (blk)
            %       matches to a single library that the user has specified.
            %       However, the user list could have redundancy, possibly due to
            %       an expanded macro.  In any case, idx could match multiple
            %       times to redundant libraries, and thus be a vector...
            for k=1:length(idx),
               next_idx = idx(k);
               
               fld = libs{exp_idx(next_idx)};
            
               tmp = getfield(blk_paths, fld);
               tmp{end+1} = blk;
               blk_paths = setfield(blk_paths, fld, tmp);
               
               %endp1 = {length(getfield(blk_paths, fld)) + 1};
               %blk_paths = setfield(blk_paths, fld, endp1, blk);
               
               fg = exp_clrs{next_idx};
               canShowLink = 1;
               any_links = 1;
            end
         end
      end
      
      if ~isLocked & canShowLink,
         % Only update block if model is unlocked
         % Otherwise, we are merely accumulating block paths
         % for the summary and possibly to return to the caller.
         
         if wantToShowLinks & ~blkIsShowingLink,
            % Turn on link display:
            
            % Store old tag, and replace with new one:
            curFmt  =  get_param(blk,'AttributesFormatString');
            curClr  =  get_param(blk,'foregroundcolor');
            curShow =  get_param(blk,'ShowName');
            newUser = {'liblinks',curUser,curFmt,curClr,curShow};
            set_param(blk,'UserData',newUser);
            if isempty(fg), fg=curClr; end
            
            % Turn off block name, and show link as attribute:
            set_param(blk,'AttributesFormatString',ref, 'ShowName','off', ...
               'foregroundcolor',fg);
            
         elseif ~wantToShowLinks & blkIsShowingLink,
            % Turn off link display:
            
            prevUser = curUser{2};
            prevFmt  = curUser{3};
            prevClr  = curUser{4};
            prevShow = curUser{5};
            set_param(blk, 'AttributesFormatString',prevFmt, ...
               'UserData',prevUser, 'showname',prevShow, ...
               'foregroundcolor',prevClr);
         end
      end
      
   end
end

% If any changes were made to the model (e.g., if any links
% are displayed), we need to revert all changes prior to
% saving or running the model.
%
% The UserData field (among others params) for each block has
% been changed, and this could be critical.  Also, users do
% not want to permanently record our changes into the model.
%
% Method: set up the Start/Save functions so that any attempts
% to start/save the model will first revert the link display.
% Also, the "Show sample times" parameter will affect the block
% coloration, so that needs to be toggled as well.

if ~isLocked & any_links,
   
   if ~modelHasLinkFcns & strcmp(mode,'on'),
      % Setup InitFcn, SaveFcn, and SampleTimeColors:
      origTag      = get_param(sys,'Tag');
      origInitFcn  = get_param(sys,'InitFcn');
      origSaveFcn  = get_param(sys,'PreSaveFcn');
      origSTColors = get_param(sys,'SampleTimeColors');
      
      % Cache the data:
      newUser = {'liblinks', origInitFcn, origSaveFcn, origSTColors, origTag};
      newTag  = cellpipe(newUser);
      
      % Override the start and presave fcn of the system
      % with the liblinks 'exit' functionality which will
      % remove all changes made by liblinks:
      if strcmp(origSTColors,'on'),
         set_param(sys, 'SampleTimeColors','off', ...
            'SimulationCommand','update');
      end
      
      exitFcn = 'liblinks(gcs,''off'');';
      set_param(sys, ...
         'Tag', newTag, ...
         'InitFcn', exitFcn, ...
         'PreSaveFcn', exitFcn);
      
   elseif modelHasLinkFcns & strcmp(mode,'off'),
      % Reset InitFcn, SaveFcn, and SampleTimeColors
      
      % Get cached data:
      newTag  = get_param(sys,'Tag');
      newUser = cellpipe(newTag);
      
      % Grab original fcns:
      origInitFcn  = newUser{2};
      origSaveFcn  = newUser{3};
      origSTColors = newUser{4};
      origTag      = newUser{5};
      
      % Abort simulation if it is running, since we've
      %   potentially changed the InitFcn itself:
      %
      % simRunning = strcmp(get_param(sys,'simulationstatus'),'initializing');
      % if simRunning,
      %    set_param(sys,'simulationcommand','stop');
      % end
      
      % Restore original fcns:
      if strcmp(origSTColors,'on'),         
         set_param(sys, ...
            'SampleTimeColors', origSTColors, ...
            'SimulationCommand','update');
      end
      
      set_param(sys, ...
         'InitFcn', origInitFcn, ...
         'PreSaveFcn', origSaveFcn, ...
         'Tag', origTag);
   end
end

return

%restore the warning status
warning(s);

% -----------------------------------------------------------------
function DisplaySummary(blk_paths, sys, mode, libs, clrs, isLocked);
% DisplaySummary
%   Print link summary info

% If "all" libraries were displayed, blk_paths is not a struct.
if ~isstruct(blk_paths),
   flds = {'all'};
   libs = flds;
   cnt.all = length(blk_paths);
else
   flds = fieldnames(blk_paths);
   total_cnt = 0;
   cnt = [];
   for i=1:length(flds),
      len = length(getfield(blk_paths,flds{i}));
      cnt = setfield(cnt,flds{i},len);
   end
end

if isLocked,
   xmode='locked system';
else
   xmode=mode;
end

lines='-'; lines=lines(ones(40,1));

fprintf('\n%s\n',lines);
fprintf('Link summary for system: "%s"\n',sys);
fprintf('%s\n',lines);

for i=1:length(flds),
   ilib = libs{i};
   icnt = getfield(cnt,flds{i});
   iclr = ['(' clrs{i} ')'];
   fprintf('%s links: %d %s\n', ilib, icnt, iclr);
end

fprintf('%s\n\n',lines);

return


% -----------------------------------------------------------------
function [sys, mode, exp_lib_list, exp_clr_list, exp_idx, ...
   lib_list, clr_list] = process_args(sys, mode, libs, clrs)
% PROCESS_ARGS

if nargin<1, sys = gcs; end
if nargin<2, mode = 'toggle'; end
if nargin<3, libs = {}; end
if nargin<4, clrs = {}; end

mode = lower(mode);
clr_list = force_string_list(clrs);
lib_list = force_string_list(libs);

clr_list = expand_color_list(lib_list, clr_list);
[exp_lib_list, exp_clr_list, exp_idx] = expand_library_list(lib_list, clr_list);

return


% -----------------------------------------------------------------
function y = force_string_list(x)
% FORCE_STRING_LIST
%
% Verify that input is either:
%  - a string
%  - a vector cell-array of strings
%
% If input is a string, convert it to a cell-array.
% Force entries to be lowercase.

errmsg = 'Input must be a vector cell-array of strings.';

% Convert input to a list:
y = x;
if ~iscell(y), y = {y}; end

% Check that y is a vector:
if length(find(size(y)>1)) > 1,
   error(errmsg);
end

% Convert strings to lowercase
% This will also verify that each entry is a string,
%   since "lower" will error-out on non-string entries
try
   y = lower(y);
catch
   error(errmsg);
end

return


% -----------------------------------------------------------------
function clr_list = expand_color_list(libs,clrs)
% EXPAND_COLOR_LIST
%
% If clrs is empty, substitute default color (RED)
% If clrs is a scalar, expand to have same size as libs
% If clrs is non-scalar, verify that it has the same
%   size as libs.

clr_list=  clrs;
if isempty(clr_list),
   clr_list = {'red'};
end

if prod(size(clr_list))==1,
   % Scalar list
   if ~isempty(libs),
      clr_list = clr_list(ones(size(libs)));
   end
else
   % Check sizes:
   if ~isempty(libs),
      if any(size(libs) ~= size(clr_list)),
         error('Number of entries in CLRS and LIBS do not correspond.');
      end
   else
      if prod(size(clr_list))>1,
         error('CLRS must contain one color entry if LIBS is empty.');
      end
   end
end

return


% -----------------------------------------------------------------
function [exp_lib_list, exp_clr_list, exp_idx] = ...
   expand_library_list(lib_list, clr_list)
% EXPAND_LIBRARY_LIST
%
%   Construct a list (cell-array of strings) containing the name
%   of each library for which we will display links.
%   Input must be a string list (cell-array of strings).
%   Expand macros into individual library names.
%
%   If exp_lib_list is returned empty, then ALL libraries are implied.
%
%   If library macros are expanded, a new color list must be made which
%   has new (repeated) entries for each expanded library name.

% NOTE:
%   Empty strings are ignored, and if it is the only string,
%   an empty list is returned.  (This implies "all libraries".)

if ~iscell(lib_list),
   error('Input must be a list.');
end

% If the user passed an empty cell-array, we will have an
% empty list here.  We return an empty list, which is the
% same condition as "all".

lib_macros   = library_macros;
macro_names  = fieldnames(lib_macros);
exp_lib_list = {};  % Preset to an empty list
exp_clr_list = {};
exp_idx      = [];

if isempty(lib_list),
   exp_clr_list = clr_list;
   return
end

% Generate expanded list of individual library names:
for i = 1:length(lib_list),
   next_entry = lib_list{i};  % Must be strings
   next_clr   = clr_list{i};
      
   % All macros are defined in lowercase - next_entry must be
   %   lowercase as well.
   % Generate a list containing either an explicit library
   % path, or the expansion of a macro into multiple paths:
   %
   if isempty(next_entry),
      % Remove empty entries from list:
      new_libs = {};
      new_clrs = {};
      new_idx  = [];
      
   elseif strmatch(next_entry, macro_names, 'exact'),
      % Expand macro to list of library names
      new_libs = getfield(lib_macros, next_entry);
      
      % Expand color entry:
      new_clrs = {next_clr};
      new_clrs = new_clrs(ones(size(new_libs)));
      new_idx  = i(ones(size(new_libs)));
      
   else
      % Entry is assumed to be a library name
      % Convert to a cell-array containing just this string:
      new_libs = {next_entry};
      new_clrs = {next_clr};
      new_idx  = i;
   end
   
   exp_lib_list = [exp_lib_list new_libs];
   exp_clr_list = [exp_clr_list new_clrs];
   exp_idx      = [exp_idx      new_idx];
end


% -----------------------------------------------------------------
function all_libs = library_macros
% LIBRARY_MACROS

% This database contains one field per LIB macro.
% Each field contains a list (cell-array of strings) of paths.
% NOTE: Do not define the "All" macro.
%       This is specially handled by expand_library_list().

persistent libs;
if isempty(libs),
   
   % Simulink Version 2:
   libs.sl2 = {'simulink'};
   
   % Simulink Version 3:
   libs.sl3 = {'simulink3'};
   
   % Merge in the library names for Signal Processing Blockset:
   libs = mergestruct(libs,dspliblist);
   
   % Merge in the library names for Video and Image Processing Blockset:
   if exist('vipliblist','file'),
      libs = mergestruct(libs,vipliblist);
   end

   % Merge in the library names for Comm Blockset:
   if exist('commliblist','file'),
      libs = mergestruct(libs,commliblist);
   end
   
   % Fixed Point Blockset Version 2:
   if exist('fixptlib','file'),
      libs.fp2 = {'fixptlib'};
   end
   
end

all_libs = libs;

return

% -----------------------------------------------------------------
function c = mergestruct(a,b)
% MERGESTRUCT
v = cat(1,struct2cell(a),struct2cell(b));
f = cat(1,fieldnames(a),fieldnames(b));
c = cell2struct(v,f,1);


% [EOF] liblinks.m
