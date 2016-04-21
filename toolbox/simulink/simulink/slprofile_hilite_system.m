function slprofile_hilite_system(varargin)
%SLPROFILE_HILITE_SYSTEM Locate a block in a profiled Simulink model.
%   SLPROFILE_HILITE_SYSTEM('path/block') will open the Simulink window
%   corresponding to the specified block. If a model is specified, it will be
%   opened.
%
%   SLPROFILE_HILITE_SYSTEM('encoded-path','path/block') first translates the
%   following character sequences before processing 'path/block':
%        sequence  converted value
%        --------  ---------------
%        '\\'      '\'
%        '\s'      ' '
%        '\t'      TAB
%        '\n'      new-line
%        '\T'      '''' (single tick)
%        '\Q'      '"'  (double quote)
%
%   The 'encoded-path' handling is used by the Simulink Profiler.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.2.2 $
  
  
  %-------------%
  % Check usage %
  %-------------%
  if nargin == 1 && ischar(varargin{1})
    decodePath = 0;
    sysStr     = varargin{1};
  elseif nargin == 2 && ...
        strcmp(varargin{1},'encoded-path') && ...
        ischar(varargin{1})
    decodePath = 1;
    sysStr     = varargin{2};
  else
    error('Usage: slprofile_hilite_system([''encoded-path'',] ''block-name'')');
  end

  
  %-----------------------%
  % Decode path if needed %
  %-----------------------%
  if decodePath

    encodedPathStr    = sysStr;
    encodedPathStrLen = length(encodedPathStr);
    sysStr            = '';

    newline           = sprintf('\n');
    tab               = sprintf('\t');

    i = 1;
    j = 1;
    while i <= encodedPathStrLen
      if encodedPathStr(i) == '\'
        i = i+1;
        switch encodedPathStr(i)
         case '\'
          sysStr(j) = '\';
         case 's'
          sysStr(j) = ' ';
         case 't'
          sysStr(j) = tab;
         case 'n'
          sysStr(j) = newline;
         case 'T'
          sysStr(j) = '''';
         case 'Q'
          sysStr(j) = '"';
         case 'q'
          sysStr(j) = '?';
         otherwise
          error('unexpected encoded path');
        end
      else
        sysStr(j) = encodedPathStr(i);
      end
      j = j+1;
      i = i+1;
    end
  end
  
  %----------------------------------------%
  % Locate block owner (if not model only) %
  %----------------------------------------%

  slashes = findstr('/',sysStr);
  
  % Doubled slashes indicate slashes in the block name. These are
  % not path separators and we must remove them.

  slashesLen = length(slashes);
  rmSlashes  = [];
  
  i = 1;
  while i < slashesLen
    if slashes(i) == slashes(i+1) - 1
      rmSlashes(end+1:end+2) = [i,i+1];
      i = i + 2;
    else
      i = i + 1;
    end
  end

  slashes(rmSlashes) = [];

  if ~isempty(slashes)
    model     = sysStr(1:slashes(1)-1);
    block     = sysStr;
  else
    model     = sysStr;
    block     = [];
  end
  
  %-------------------------%
  % show the located system %
  %-------------------------%  
  openModels = find_system('SearchDepth', 0, 'Name', model);
  if isempty(openModels),
    open_system(model);
  end

  %--------------------------------------%
  % Mark the specified block as hilited  %
  % Unhilite all hilited blocks first    %
  %--------------------------------------%
  slprofile_unhilite_system(model);
    
  if ~isempty(block) 
    hilite_system(block);
  else
    open_system(model);
  end
    
%endfunction slprofile_hilite_system
