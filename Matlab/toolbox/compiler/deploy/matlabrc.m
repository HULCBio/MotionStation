function matlabrc
%MATLABRC MCR version of the master startup M-file.
%   This version of MATLABRC is specific to applications deployed using the
%   MATLAB Compiler and the MCR. It is a copy of MATLAB's MATLABRC with three
%   important changes:
%
%     * This file must be a function rather than a script, as the MATLAB
%       Compiler cannot handle scripts.
%
%     * This file must not modify the path in any way, since the path is
%       set on MCR startup by the application startup code.
%
%     * There is no need to print the "helpful hints," since an MCR-based
%       application has no command line.
%
%   MATLABRC also invokes a STARTUP command if the file 'startup.m'
%   exists on the MATLAB path.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/05/10 21:41:37 $

% Turn off warnings about .bi files being in the wrong place. They're where 
% they belong.
warning off MATLAB:dispatcher:misPlacedBiFile

% Turn off warnings about .BI files not being visible.
warning off MATLAB:predictorNoBiVisible

% Disable support for SSE2 instructions for now.
feature allowsse2 off;

% Set default warning level to WARNING BACKTRACE.  See help warning.
warning backtrace

% The RecursionLimit forces MATLAB to throw an error when the specified
% function call depth is hit.  This protects you from blowing your stack
% frame (which can cause MATLAB and/or your computer to crash).  Set the
% value to inf if you don't want this protection.
cname = computer;
if strncmp(cname,'GLNX',4)
  set(0,'RecursionLimit',100)
elseif strncmp(cname,'ALPHA',5)
  set(0,'RecursionLimit',200)
else
  set(0,'RecursionLimit',500)
end

%% Initialize handle Graphics.
hgrc

%% If neither of the above lines are uncommented then guess
%% which papertype and paperunits to use based on ISO 3166 country code.
% Try/catch so that we can tell if there's a search path issue, since
% USEJAVA is not a builtin.

try
  if usejava('jvm') && ~exist('defaultpaper','var')
    if any(strncmpi(char(java.util.Locale.getDefault.getCountry), ...
		  {'gb', 'uk', 'fr', 'de', 'es', 'ch', 'nl', 'it', 'ru',...
		   'jp', 'kr', 'tw', 'cn', 'cz', 'sk', 'au', 'dk', 'fi',...
           'gr', 'hu', 'ie', 'il', 'in', 'no', 'pl', 'pt',...
           'ru', 'se', 'tr', 'za'},2))
      defaultpaper = 'A4';
      defaultunits = 'centimeters';
    end
  end
catch
    warning('MATLAB:matlabrc:SuspectedPathProblem', ...
        ['MATLAB did not appear to successfully set the search path. To avoid this\n' ...
         'warning the next time you start MATLAB, use\n' ...
         'http://www.mathworks.com/access/helpdesk/help/techdoc/ref/pathdef.shtml\n' ...
         'to help troubleshoot the "pathdef.m" file. To recover for this session\n' ...
         'of MATLAB, type "restoredefaultpath;matlabrc".']);
   RESTOREDEFAULTPATH_REHASHFCN = @rehash;
   cd([matlabroot '/toolbox/local/']);
end

%% Set the default if requested
if exist('defaultpaper','var') && exist('defaultunits','var')
  % Simulink defaults
  set_param(0,'PaperType',defaultpaper);
  set_param(0,'PaperUnits',defaultunits);
end

%% For the 'edit' command, to use an editor defined in the $EDITOR
%% environment variable, the following line should be uncommented
%% (UNIX only)
%system_dependent('builtinEditor','off')

if usejava('mwt')
  % Do not initialize the desktop or the preferences panels for deployed 
  % applications, which have no desktop.
  % initprefs %% init java prefs system if java is present
  % initdesktoputils  %% init desktop setup code if java is present
end

%% Text-based preferences
NumericFormat = system_dependent('getpref','GeneralNumFormat');
if ~isempty(NumericFormat)
  eval(['format ' NumericFormat(2:end)]);
end
NumericDisplay = system_dependent('getpref','GeneralNumDisplay');
if ~isempty(NumericDisplay)
  format(NumericDisplay(2:end));
end
MaxTab = system_dependent('getpref','CommandWindowMaxCompletions');
if ~isempty(MaxTab) && MaxTab(1) == 'I'
  EnableTab = system_dependent('getpref','CommandWindowTabCompletion');
  TabSetting = strcmpi(EnableTab,'BTrue') * str2double(MaxTab(2:end));
  system_dependent('TabCompletion', TabSetting);
end
if (strcmpi(system_dependent('getpref','GeneralEightyColumns'),'BTrue'))
  feature('EightyColumns',1);
end

% Clean up workspace.
clear

% Enable/Disable selected warnings by default
warning off MATLAB:nonScalarConditional
warning on  MATLAB:namelengthmaxExceeded
warning off MATLAB:sum:doubleAccumulationOnSinglesObsolete
warning off MATLAB:sum:doubleAccumulationOnIntegersObsolete
warning off MATLAB:max:mixedSingleDoubleInputs
warning off MATLAB:max:mixedIntegerScalarDoubleInputs
warning off MATLAB:min:mixedSingleDoubleInputs
warning off MATLAB:min:mixedIntegerScalarDoubleInputs
warning off MATLAB:mir_warning_unrecognized_pragma

% New non double warnings ...
warning off MATLAB:intConvertNonIntVal
warning off MATLAB:intConvertNaN
warning off MATLAB:intConvertOverflow
warning off MATLAB:intMathOverflow

% to replace these old ones when the source code stops issuing them ...
warning off MATLAB:integerConversionNowRoundsInsteadOfTruncating
warning off MATLAB:integerConversionNaNDetected
warning off MATLAB:integerConversionOverflowDetected
warning off MATLAB:integerArithmeticOverflowDetected


% Turn UsingLongNames warning to detect aliasing problems with legacy
% MATLAB code.  It will warn when any name longer than 31 characters
% is used.
%
warning off MATLAB:UsingLongNames  

% Execute startup M-file, if it exists.
if (exist('startup','file') == 2) ||...
   (exist('startup','file') == 6)
  startup
end

% Defer echo until startup is complete
if strcmpi(system_dependent('getpref','GeneralEchoOn'),'BTrue')
  echo on
end
