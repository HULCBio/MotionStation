%FIND_SYSTEM Find Simulink systems with specified parameter values.
%   Systems=FIND_SYSTEM searches all open systems and returns a cell array
%   containing the full path names in hierarchical order of all systems,
%   subsystems, and blocks.
%
%   Note that library links and masked blocks are treated as individual blocks 
%   and by default the search will not descend beneath them.  Options, which
%   are described below, are available to override this behavior.
%
%   Systems=FIND_SYSTEM('PARAMETER_NAME1',VALUE1,'PARAMETER_NAME2',VALUE2,...)
%   searches all open systems and returns a cell array containing the full
%   path names in hierarchical order of all systems, subsystems, and blocks,
%   whose specified parameters have the specified values. To search over
%   all parameters in block dialogs, use 'BlockDialogParams' as the
%   parameter name.
%
%   Notes:
%   a) Case is ignored for parameter names.
%   b) Value strings are case sensitive.
%   c) Parameters that correspond to dialog box entries have string values.
%   d) Commonly searched block parameters include 'BlockType', 'Name',
%      'Position' and 'Parent'.
%
%   System=FIND_SYSTEM('CONSTRAINT1',CVALUE1,... ,'PARAMETER_NAME1',VALUE1,...)
%   constrains the search of FIND_SYSTEM to the specified constraint/value
%   pairs, followed by the specified parameter/value pairs.  The following 
%   table describes the available constraint/value pairs:
%
%     SearchDepth    DEPTH             An integer that constrains the search to
%                                      a specific depth.
%
%     FindAll        ['on' | {'off'}]  FindAll needs to be 'on' in order to include
%                                      annotations, lines, and ports in the search.
%                                      If set to 'off', only block diagrams and blocks
%                                      are found.  Note that when FindAll is 'on',
%                                      the result from FIND_SYSTEM is always a
%                                      vector of handles.
%
%     FollowLinks    ['on' | {'off'}]  Specify whether to follow library links.
%
%     LookUnderMasks                   Constrains the search from looking into
%                                      different types of masked blocks.
%                    'none'            : No masked blocks
%                    {'graphical'}     : Masks with no workspace and
%                                        no dialog
%                    'functional'      : Masks with no dialog 
%                    'all'             : All masked blocks 
%
%     CaseSensitive  [{'on'} | 'off']  Specify whether to consider case
%                                      when matching search strings.
%
%     RegExp         ['on' | {'off'}]  Specify whether to treat the search 
%                                      string as a regular expression.
%     The following regular expressions are recognized in the search string:
%               ^        matches start of string
%               $        matches end of string
%               .        matches any character
%               \        quotes next character
%               *        matches zero or more of preceding character
%               +        matches one or more of preceding character
%               []       matches any of bracketed characters
%               \w       matches word [a-z_A-Z0-9]
%               \W       matches non-word [^a-z_A-Z0-9]
%               \d       matches digit [0-9]
%               \D       matches non-digit [^0-9]
%               \s       matches white space [ \t\r\n\f]
%               \S       matches non-white-space [^ \t\r\n\f]
%               \<WORD\> exact word match for WORD
%
%   FIND_SYSTEM('SearchDepth',DEPTH,'PARAMETER_NAME1',VALUE1,...) restricts the
%   search to a specified DEPTH from the top-level system.  A value of 0
%   searches only the top-level systems. A value of 1, looks at all top-level
%   systems and the blocks on the top level of each system.
%
%   FIND_SYSTEM('SYS',...), where 'SYS' is a system or block path name, starts
%   the search in the specified system.
%
%   FIND_SYSTEM(NAMES,...), where NAMES is a cell array of system or block path
%   names, starts the search at the objects listed in NAMES.
%
%   Examples:
%
%   find_system                          % returns the names of all open
%                                        % systems and blocks within them.
%
%   find_system('type','block_diagram')  % returns the names of all open
%                                        % block diagrams.
%
%   clutch
%   find_system('clutch/Unlocked',...    % search the subsystem clutch/Unlocked
%               'SearchDepth',1,...      % and only blocks within it for all
%               'BlockType','Goto')      % Goto blocks.
%
%   vdp
%   gb = find_system('vdp',...           % search vdp for all Gain blocks,
%                    'BlockType','Gain') % placing the results in variable 'gb'
%   find_system(gb,'Gain','1')           % and subsequently searching for those
%                                        % blocks whose Gain value is '1'.
%
%   find_system('vdp',...                % search vdp for all blocks whose
%               'Regexp', 'on',...       % name starts the character "x".
%               'Name','^x')             
%
%   See also SET_PARAM, GET_PARAM, HASMASK, HASMASKDLG, HASMASKICON

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.22 $
%   Built-in function.
