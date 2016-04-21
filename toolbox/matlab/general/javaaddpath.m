function javaaddpath(varargin)
%JAVAADDPATH Add directories to the dynamic java path.
%  JAVAADDPATH DIRNAME appends the specified directory to the 
%  current dynamic java path. Surround the DIRNAME in quotes 
%  if the name contains a space.
%
%  JAVAADDPATH DIR  ... appends the specified 
%  directory to the dynamic java path.
%
%  JAVAADDPATH ... -END appends the specified directories.
%
%  Use the functional form of JAVAADDPATH, such as 
%  JAVAADDPATH({'dir1','dir2',...}), when the directory 
%  specification is stored in a string or cell array of
%  strings.
%
%  Examples:
%  UNIX: javaaddpath /home/myfriend/goodjavastuff
%  WINDOWS: javaaddpath c:\tools\goodjavastuff
%
%  See also JAVACLASSPATH, JAVARMPATH, JAVA, CLEAR. 

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:06:53 $

n = nargin;

nargchk(1,2,n);

append = logical(0); % default, pre-append

if n>1
  last = varargin{2};
  
  % append 
  if strcmp(last,'-end')
    append = logical(1);
  
  % pre-append  
  elseif strcmp(last,'-begin')
    append = logical(0);
  end 
end

p = varargin{1};

% Append or prepend the new path   
if append
  javaclasspath( javaclasspath, p );
else
  javaclasspath( p, javaclasspath );
end



