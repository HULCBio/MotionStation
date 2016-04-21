function p = javaclasspath(a,b)
%JAVACLASSPATH Get and set java path.
%  The java path consists of a static portion and a dynamic portion:     
%  static   -Specified on startup in classpath.txt. The static 
%            java path cannot be modified during a MATLAB session. 
%            The static java path offers better java class loading 
%            performance than the dynamic java path. 
%  dynamic  -Specified through this function, java classes can 
%            be reloaded using CLEAR JAVA. 
%
%  MATLAB will always search the static path BEFORE the dynamic path.
%  Java classes on the static path should not have dependencies on 
%  classes on the dynamic path otherwise runtime errors will result. 
%
%  JAVACLASSPATH displays the static and dynamic java path.
%
%  P = JAVACLASSPATH returns the dynamic java path.
%
%  P = JAVACLASSPATH('-static') returns only the static java path.
%
%  P = JAVACLASSPATH('-all') returns both the static and
%  dynamic java path.
%
%  JAVACLASSPATH(P) changes the dynamic java path to P, P is a 
%  string or cell array of strings for multiple entries.
%
%  JAVACLASSPATH(P1,P2) changes the dynamic java path to the 
%  concatenation of the two paths P1 and P2. Input should
%  be a string or cell array of strings for multiple entries.
% 
%  JAVACLASSPATH('-v0') no class loading messages will be 
%  displayed (default).
%
%  JAVACLASSPATH('-v1') prints messages when loading files 
%  from the dynamic java path.
%
%  Examples:
%
%  javaclasspath('/home/javastuff/')
%
%  javaclasspath({'/home/javastuff/','/home/morestuff/jarfile.jar'})
%
%  javaclasspath('http://domain.com')
%
%  javaclasspath('http://some.domain.com/jarfile.jar')
%
%  See also JAVAADDPATH, JAVARMPATH, JAVA, CLEAR.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/16 22:06:54 $

errmsg = 'Invalid input';

% pretty-print
if nargin == 0  

    if nargout == 0
      local_javapath('-print')
    else 
      p = local_javapath('-dynamic');
    end

% javaclasspath(p)
elseif nargin == 1   
     
      if ~ischar(a) & ~iscell(a)
        error(errmsg)
      end   
      
      % p = javaclasspath(...)
      if nargout>0        
        if ischar(a) & a(1)=='-' % p = javaclasspath(['-both'|'-static'])
            p = local_javapath(a);
        else
          error(errmsg);
        end
      else
        % javaclasspath('-v0') | javaclasspath('...')
        if ischar(a) & a(1)=='-' % javaclasspath(['-v0'|'v1'|'v2'])
          local_set_verbose_level(a);
        else            
          if ischar(a)
            a = {a};
          end
          local_javapath('-setdynamic',a);
        end
      end
      
%javaclasspath(a,b)
elseif nargin == 2 
    
    if (~isstr(a) & ~iscell(a)) | (~iscell(b) & ~isstr(b))
      error(errmsg)
    end

    newpath = local_remove_pair_redundancies(a,b);
     
    % Update new path
    local_javapath('-setdynamic',newpath);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pathout] = local_javapath(varargin)
% Input args:
% -print, pretty print
% -dyanmic, return dyanmic java path
% -static, return static java path
% -set, set dynamic java path
    
jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    
arg1 = varargin{1};

% pretty print static and dynamic java path
if strcmp(arg1,'-print')
    
    % Emulate PATH command format
    disp(sprintf('\n\t\tSTATIC JAVA PATH\n'))
    sp = local_get_static_path;
    local_pretty_print_path(sp);
  
    disp(sprintf('\n\t\tDYNAMIC JAVA PATH\n'))             
    dp = javaclasspath('-dynamic');
    if length(dp)>0  
       local_pretty_print_path(dp);
    else
       disp(sprintf('\t\t<empty>'));
    end
   
% return dynamic java path
elseif strcmp(arg1,'-dynamic')
    jArray = jloader.getClassPath;
    if ~isempty(jArray)
      pathout = cell(jArray)';   
    else
      pathout = {};
    end
 
% return static java path    
elseif strcmp(arg1,'-static')
    pathout = local_get_static_path;

% return both static and dynamic java path    
elseif strcmp(arg1,'-all')
    sp = javaclasspath('-static');
    dp = javaclasspath('-dynamic');
    pathout = {sp{:},dp{:}};

% set the dynamic java path    
elseif strcmp(arg1,'-setdynamic')
    pathin = varargin{2};
    pathin = local_validate_dynamic_path(pathin);
   
    % Enable dynamic java using undocumented switches
    jloader.setEnabled(1); 
    com.mathworks.jmi.OpaqueJavaInterface.enableClassReloading(1);
    jloader.setClassPath(pathin);
    feature('clearjava',1); 
    
    % Issue clear java since the dynamic path is changing and this may  
    % invalidate currently resolved java classes.
    clear('java'); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newpath] = local_remove_pair_redundancies(pa, pb)        
% Compare two cell arrays and remove any redundancies from input arg cell 
% array string "pa"

casesen = isunix; 

% wrap char arrays into cell arrays
if ischar(pa), pa = {pa};end
if ischar(pb), pb = {pb};end

% remove any redundancies in pa from pb
for(i=1:length(pa))
   aa = pa{i};
   j = 1;
   while(j<=length(pb)) %for j=1:length(pb)
      bb = pb{j};
      if ~casesen, aa = lower(aa); end
      if ~casesen, bb = lower(bb); end
      if strcmp(aa,bb)
         pb = {pb{1:j-1},pb{j+1:end}};
      end
      j = j+1;
   end
end

p = {pa{:},pb{:}};

newpath = p;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dp] = local_validate_dynamic_path(dp)        
% Validate dynamic path for correctness:
%   -Valid file/directories
%   -No duplicate entries within dynamic path
%   -No duplicate entries with static path

% Get a cell array of static path entries 
sp = javaclasspath('-static');

% Extract a cell array of static jar file names without absolute path 
spJars = {};
for n = 1:length(sp)
   spEntry = sp{n};
   jar_file_name = local_extract_jar_file_name(spEntry);
   if ~isempty(jar_file_name)      
       spJars{end+1} = jar_file_name;    
   end
end % for

% Check each dynamic path entry for correctness 
n = length(dp);
while (n>0)  
  flag = logical(0);
  
  % Candidate dynamic path entry
  pp = dp{n};
  
  % Remove if invalid
  if ~local_is_url(pp) && ~exist(pp)
    warning('MATLAB:javaclasspath:invalidFile',...
            'Invalid file or directory ''%s''.',pp);
    flag = logical(1);
  
  % Remove if duplicate
  elseif sum(strcmp(pp,dp))>1
    warning('MATLAB:javaclasspath:duplicateEntry',...
            'Duplicate entry,%s',pp);
    flag = logical(1);
  
  % Remove if identical path already exists on the static path
  elseif any(strcmp(sp,pp)) 
      warning('MATLAB:javaclasspath:jarAlreadySpecified',...
              '%s already specified on static java path',pp);
      flag = logical(1);
      
  % Throw warning (but do not remove) if entry is to a jar file name that 
  % already exists on the static path even if under a different directory     
  else
      jar_file_name = local_extract_jar_file_name(pp);
      if ~isempty(jar_file_name) & any(strcmp(spJars,jar_file_name))
           warning('MATLAB:javaclasspath:jarAlreadySpecified',...
                   '"%s" is already specified on static java path.',jar_file_name);
      end
  end
  
  % Remove entry if flagged
  if(flag), dp = {dp{1:n-1},dp{n+1:end}}; end 
  
  % Go to next entry
  n = n-1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jar_file_name  = local_extract_jar_file_name(fullp)
% Extract jar file name "foo.jar" from path "S:/blah/foo.jar"

jar_file_name = [];
if strncmp(fliplr(fullp),fliplr('.jar'),4)
    fullp = strrep(fullp,'\','/');
    ind = strfind(fullp,'/');
    if ~isempty(ind)
        jar_file_name = fullp(ind(end)+1:end); 
    end
end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = local_is_url(str)
% input is string
ret = strncmp(str, 'http://', 7) || strncmp(str, 'ftp://', 6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p] = local_get_static_path
% get static path as a cell array

jString = java.lang.System.getProperty('java.class.path');
sp = char(jString);

ind = findstr(sp,pathsep);

% Convert from string to cell array
p = {};
prevind = 1;
for i=1:length(ind)
  currp= sp(prevind:ind(i)-1);
  p{i} = currp;
  prevind = ind(i)+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_pretty_print_path(p)
% input is cell array of strings

ch= strvcat(p);
tabspace = ones(size(ch,1),1);
tabspace(:) = sprintf('\t');
s = [tabspace, ch];
disp(s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_set_verbose_level(pa)
% input is string "-v0", "-v1", or "-v2"
jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;

if strcmp(pa,'-v0')
  jloader.setVerbose(0);
elseif strcmp(pa,'-v1')
  jloader.setVerbose(1);
else
  jloader.setVerbose(2);
end
