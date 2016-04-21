function varargout=ver(arg)
%VER MATLAB, Simulink and toolbox version information.
%   VER displays the current MATLAB, Simulink and toolbox version information.
%   VER(TOOLBOX_DIR) displays the current version information for the
%   toolbox specified by the string TOOLBOX_DIR.
%   A = VER displays the general MATLAB version header and return in A the
%   sorted struct array of version information on all toolboxes on the
%   MATLAB path.
%   The definition of struct A is:
%           A.Name      : toolbox name
%           A.Version   : toolbox version number
%           A.Release   : toolbox release string
%           A.Date      : toolbox release date
%   For example,
%      ver control
%     displays the version info for the Control System Toolbox, sorted 
%     alphabetically.
%      A = ver('control');
%     returns in A the version information for the Control System Toolbox, 
%     sorted alphabetically.
%
%   For tips on how to get VER to display version information about
%   your toolbox, type at the MATLAB prompt
%       more on
%       type ver.m
%   and then type 'more off' when the display of ver.m has finished.
%
%   See also VERSION, HOSTID, LICENSE, INFO, WHATSNEW.

% Tips on how to get your toolbox to work with VER:
%
%   VER TOOLBOX_DIR looks for lines of the form
%
%     % Toolbox Description
%     % Version xxx dd-mmm-yyyy
%
%   as the first two lines of the Contents.m in the directory specified.  
%   The date cannot have any spaces in it and must use a 2 char day (that
%   is, use 02-Mar-1997 instead of 2-Mar-1997). 
%
%   To produce the display, VER combines the description and version
%   information into a single line, separating the date so that all the
%   dates line up.  Look at the Contents.m in any MathWorks toolbox, other
%   than the MATLAB Toolbox, for an example.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.44.4.3 $  $Date: 2004/04/19 01:13:48 $
%--------------------------------------------------------------------------
% handle number of outputs
if nargout>0
   isArgout=logical(1);
else
   isArgout=logical(0);
end

nameLen = 38;  % field width for toolbox name string
verLen = 15;   % field width for toolbox version string

LinesGrouping = 0;
Separator = '\n';
Toolboxes = '';
verStruct=struct('Name',{},'Version',{},'Release',{},'Date',{});

% parse MATLAB path into cell array of strings
p = strread(matlabpath,'%s','delimiter',[pathsep '\n']);

% Display general MATLAB information if no output arguments exists
if ~isArgout
   disp(repmat('-',1,85))
   LocDisplayMatlabInformation
   disp(repmat('-',1,85))
end

if nargin > 0
   % Display information on a particular toolbox in the MATLAB path 
   p = remove_unwanted_entries(p); 
   [verStruct] = disp_single_toolbox(arg,p,isArgout,verStruct,nameLen,verLen);
   
else
   % Display information on all toolboxes in the MATLAB path
   
   % Remove the toolbox/matlab directory entries from the path list
   p = remove_unwanted_entries(p);   

   % For each directory, pre-print the version information to a string array to
   % enable alphabetic sorting
   [Toolboxes,verStruct] = sort_toolbox_list(p,isArgout,verStruct,nameLen,verLen);
   
   % display toolbox version information on screen
   if ~isArgout
      display_toolbox_list(Toolboxes,LinesGrouping,Separator);
   end
   
end

if isArgout
   varargout{1}=verStruct;
end

return
%--------------------------------------------------------------------------
function newarg = fixarg (p, arg)
%FIXARG Fix the argument for special cases
%   FIXARG (PATH, ARG) returns a modified argument
%   for the special cases below.
%   Toolboxes lmi, mpc, or mutools are not conforming.

switch arg
case 'lmi'
   dir = 'lmictrl';
case 'mpc'
   dir = 'mpccmds';
case 'mutools'
   dir = 'commands';
otherwise
   dir = '';
end
if ~isempty(dir)
   targ = fliplr([filesep arg]);
   larg = length(targ);
   found = 0;
   for i=1:length(p)
      if strncmp(targ,p{i},larg)
         found = 1;
         break;
      end
   end
   if ~found
      newarg = [ arg filesep dir ];
   else
      newarg = arg;
   end
else
   newarg = arg;
end
% switch newarg
% case 'Simulink'
%    if strncmp(computer,'MAC',3)
%       newarg = [newarg filesep newarg];
%    end
% end

return
%--------------------------------------------------------------------------
function [structInfo,dispString]=LocParseContentsFile(fName,nameLen,verLen);
% LocParseContentsFile  Extract toolbox information from Contents.m file
% [structInfo,dispString]=LocParseContentsFile(fName,nameLen,verLen)
% Input:
%     fName:  string vector containing full path to Contents.m file
%     nameLen: scalar double defining field width of toolbox name string
%     verLen: scalr double defining field width of toolbox version string
% Return:
%     structInfo: scalar struct defining toolbox information
%     dispString: string vector defining toolbox information display string

dispString='';
structInfo=struct('Name',{},'Version',{},'Release',{},'Date',{});

if exist(fName)
   if ispc
      fp = fopen(fName,'rb');
   else
      fp = fopen(fName,'r');
   end
   
   if fp>0
      s = fgetl(fp);
      if ~isstr(s)
         s = '';
      else
         s  = [s '  '];
         s(1:2) = [];
      end
      
      s1 = fgetl(fp);
      if ~isstr(s1)
         s1 = '';
      else
         s1 = [s1 '  '];
         s1(1:2) = [];
      end
      fclose(fp);
   else
      s='';
      s1='';
   end
   
   if ~isempty(findstr(fName, ['toolbox' filesep 'matlab' filesep 'general']))
      % Look for Version
      k = findstr('Version',s1);
      s = s1(1:k-1);
      s1 = s1(k:end);
   end
   
   s = deblank(s);
   % Remove any trailing period.
   if ~isempty(s) & s(end)=='.'
      s(end)=[];
   end
   
   % Force the name to fit within the specified number of characters
   productName=s;
   if length(s) > nameLen
      s = [s(1:nameLen-3) '...'];
   end
   
   %remove trailing spaces
   s1 = deblank(s1);
   if ~isempty(s1)
      verLoc=findstr(lower(s1),'version ');
      if ~isempty(verLoc)
         s1=s1(verLoc+length('version '):end);
         %remove leading spaces
         s1= fliplr(deblank(fliplr(s1)));
         blankLoc=findstr(s1,' ');
         
         if length(blankLoc)>0
            %Version is everything from beginning to first space
            verNum=s1(1:blankLoc(1)-1);
            
            %Date is everything from last space to end
            dateString=s1(blankLoc(end)+1:end);
            dateString=LocCleanDate(dateString);

            %Release number is everything from first to last space
            releaseNum=s1(blankLoc(1):blankLoc(end));
            %remove leading and trailing blanks from releaseNum
            releaseNum=deblank(releaseNum);
            releaseNum=fliplr(deblank(fliplr(releaseNum)));
            
            structInfo=struct('Name',productName,...
               'Version',verNum,...
               'Release',releaseNum,...
               'Date',dateString);
            
            dispString=...
               sprintf('%-*.*s    %-*s    %-s',...
               nameLen,nameLen,s,verLen,['Version ' verNum],releaseNum);
         end
      end
   end
   
else
   % Skip this directory since there's no Contents.m
end

return
%--------------------------------------------------------------------------
function LocDisplayMatlabInformation
% LocDisplayMatlabInformation  Display general MATLAB installation
% information as a header to the toolbox information section.

% find platform OS
if ispc
   platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
else
   platform = system_dependent('getos');
end
   
% display platform type
disp([prepender('MATLAB Version '),version])

% display Matlab license number
disp(['MATLAB License Number: ',license]);

% display operating system
disp(['Operating System: ',  platform])

% display first line of Java VM version info
disp(['Java VM Version: ',...
   char(strread(version('-java'),'%s',1,'delimiter',',\n'))]);

return
%--------------------------------------------------------------------------
function [Toolboxes,verStruct] = ...
      sort_toolbox_list(pathlist,isArgout,verStruct0,nameLen,verLen)
% SORT_TOOLBOX_LIST  Sort toolbox information alphabetically
% [Toolboxes,verStruct] = 
%       sort_toolbox_list(pathlist,isArgout,verStruct0,nameLen,verLen)
%  Input:
%     pathlist: cell string array containing toolbox information
%     isArgout: scalar logical defining whether output arguments exist
%     verStruct0: scalar struct initializing toolbox information structure
%     nameLen: scalar double defining field width of toolbox name string
%     verLen: scalar double defining field width of toolbox version string
%  Return:
%     Toolboxes: string array of toolbox information, sorted.
%     verStruct: struct array of toolbox information.

% sort toolbox version information list
MatlabSimulink = '';
Toolboxes = '';
verStruct=verStruct0;

for i=1:length(pathlist)
   [structInfo,dispString]=...
      LocParseContentsFile(fullfile(pathlist{i},'Contents.m'),nameLen,verLen);
   if ~isArgout & ~isempty(dispString)
      if ~isempty(strmatch(lower(sscanf(dispString(1:nameLen),'%s')), ...
            'matlab','exact'))
         MatlabSimulink = sprintf('%s',dispString);
      elseif ~isempty(strmatch(lower(sscanf(dispString(1:nameLen),'%s')), ...
            'simulink','exact'))
         MatlabSimulink = ...
            strvcat(MatlabSimulink,sprintf('%s',dispString));
      else
         Toolboxes = strvcat(Toolboxes,sprintf('%s',dispString));
      end
   elseif isArgout & ~isempty(structInfo)
      verStruct(end+1)=structInfo;
   end
end

% sort toolbox version information list
if isArgout
   % sort struct array of version information
   [tmp,idx] = sortrows(strvcat(verStruct(:).Name));
   verStruct = verStruct(idx);

else
   % sort display list
   Toolboxes = strvcat(MatlabSimulink,sortrows(Toolboxes));
end

return
%--------------------------------------------------------------------------
function display_toolbox_list(Toolboxes,LinesGrouping,Separator)
% DISPLAY_TOOLBOX_LIST  Display toolbox information on screen
%  Input:
%       Toolboxes: string array containing toolbox information
%       LinesGrouing: scalar double defining grouping of display lines
%       Separator: string vector defining the separator character between
%       groups of toolbox information

% display list of toolbox version information

for i = 1: size(Toolboxes,1)
   dispString = Toolboxes(i,:);
   if ~isempty(dispString)
      disp(dispString);
      
      % Print empty line between every grouping of toolboxes in the listing.
      if ~mod(i,LinesGrouping)
         fprintf(Separator)
      end
   end
end

return
%--------------------------------------------------------------------------
function [p] = remove_unwanted_entries(p)
% REMOVE_UNWANTED_ENTRIES  Remove unwanted Contents.m entries in path list
% [p] = remove_unwanted_entries(p)
%  Input:
%        p = cell string array containing MATLAB path list
%  Return:
%        p = cell string array containing pruned MATLAB path list

% Construct the path to the MATLAB general toolbox.

tmg = {[matlabroot filesep 'toolbox' filesep 'matlab' filesep 'general']};

% Construct the regular expression search pattern for unwanted path entries.
if ispc
   pat = [strrep(['toolbox(' filesep 'matlab|' filesep 'local)'], '\', '\\')...
        '\>'];
else
   pat = ['toolbox(' filesep 'matlab|' filesep 'local)\>'];
end

% Remove the toolbox/matlab and toolbox/local directory entries from the path
% list.

p(~cellfun('isempty', regexp(p, pat,'ignorecase'))) = [];
 
% Add the MATLAB general toolbox to the top of the path list.
p = [tmg;p];
return
%--------------------------------------------------------------------------
function [verStruct] = ...
      disp_single_toolbox(arg,p,isArgout,verStruct,nameLen,verLen)
% DISP_SINGLE_TOOLBOX  Display version information on a specified toolbox
% [verStruct] = ...
%       disp_single_toolbox(arg,p,isArgout,verStruct,nameLen,verLen)
%  Input:
%     arg: string vector defining toolbox directory name
%     isArgout: scalar logical defining whether output arguments exist
%     verStruct: scalar struct initializing toolbox version information
%     nameLen: scalar double defining field width of toolbox name string
%     verLen: scalar double defining field width of toolbox version string
%  Return:
%        verStruct: scalar struct defining a specific toolbox's 
%                   version information

% Reverse the path strings for easy searching later
for i=1:length(p),
   p{i} = fliplr(p{i});
end
if strcmp(lower(deblank(arg)),'matlab')
   arg = fullfile('toolbox','matlab','general');
   larg = length(arg);
end
arg = fixarg(p,arg);
% if strncmp(computer,'MAC',3)
%    arg = [arg filesep];
% end
targ = fliplr([filesep arg]);
larg = length(targ);
argShared = fliplr([filesep, 'toolbox',filesep,'shared', filesep]);
for i=1:length(p),
   if strncmpi(targ,p{i},larg);
      fName = fullfile(fliplr(p{i}),'Contents.m');
      [structInfo,dispString]=LocParseContentsFile(fName,nameLen,verLen);
      if ~isArgout
         if ~isempty(dispString)
            disp(dispString);
		 elseif isempty(strfind(p{i},argShared))
            disp(['No properly formatted Contents.m file for ' fliplr(p{i})])
         end
      elseif isArgout & ~isempty(structInfo)
         verStruct(end+1)=structInfo;
      end
   end
end

return
%--------------------------------------------------------------------------
function cleanDate=LocCleanDate(dirtyDate);
%LocCleanDate forces a date to be in the format of DD-Mmm-YYYY

slashLoc=findstr(dirtyDate,'-');
if length(slashLoc)>1
   dayStr=dirtyDate(1:slashLoc(1)-1);
   monthStr=dirtyDate(slashLoc(1)+1:slashLoc(2)-1);
   yearStr=dirtyDate(slashLoc(2)+1:end);
   
   if length(dayStr)==1
      dayStr=['0' dayStr];
   end
   
   if length(monthStr)>2
      monthStr=[upper(monthStr(1)),lower(monthStr(2:3))];
   end
   
   cleanDate=[dayStr '-' monthStr '-' yearStr];
   
else
   cleanDate=dirtyDate;
end
%--------------------------------------------------------------------------
