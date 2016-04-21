function javarmpath(varargin);
%JAVARMPATH Remove directory from dynamic java path.
%   JAVARMPATH DIRNAME  removes the specified directory from the
%   dynamic java path.
%
%   JAVARMPATH DIR1 DIR2 DIR3  removes all the specified directories
%   from the dynamic java path.
%
%   Use the functional form of JAVARMPATH, such as
%   JAVARMPATH('dir1','dir2',...), when the directory specification
%   is stored in a string.
%
%   Examples
%       javarmpath c:\matlab\work
%       javarmpath /home/user/matlab
%
%   See also JAVAADDPATH, JAVACLASSPATH.

%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/05/25 13:31:46 $

casesen = isunix;
dynamicPath = javaclasspath;

m=';';

% Create a char array from cell array
for i=1:length(dynamicPath)
    m = strcat(m, [char(dynamicPath(i)) ';']);
end

for i=1:length(varargin)
  next = varargin{i};
  if ~isempty(deblank(next))
    if ~isstr(next), error('Arguments must be strings.'); end
    if ~casesen next = lower(next); end
    %if strncmp(computer,'PC',2) next = strrep(next,'/','\'); end
  
    % Remove leading and trailing blanks.
    k = find(next ~= ' ');
    next = next(min(k):max(k)); 

    % Be robust to a trailing file separator: Check both with and
    % without the trailing filesep.
    if next(end)==filesep,
      next1 = next;
      next2 = next(1:end-1);
    else
      next1 = [next filesep];
      next2 = next;
    end

    if length(m) > length(next2)
      % Check with the trailing filesep.
      len=length(next1);
      if casesen,
        k1 = findstr([';' next1 ';'],m);
      else
        k1 = findstr([';' next1 ';'],lower(m));
      end
      for r=fliplr(k1),
        m(r:r+len) = [];
      end

      % Check without the trailing filesep.
      len=length(next2);
      if casesen,
        k2 = findstr([';' next2 ';'],m);
      else
        k2 = findstr([';' next2 ';'],lower(m));
      end
      for r=fliplr(k2),
        m(r:r+len) = [];
      end

      if isempty(k1) & isempty(k2), 
        warning('"%s" not found in path.',next);
      end
    else
      warning('"%s" not found in path.',next);
    end
  end
end

if(m == ';')
    javaclasspath({}) 
else
    m = strrep(m, ';', ''',''');
    m = eval(['strvcat(' m(3:end-2) ')']);
    %convert back to cellarray
    m = cellstr(m);
    javaclasspath(m)    
end



