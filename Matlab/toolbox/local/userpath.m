function p = userpath
%USERPATH User environment path.
%   USERPATH returns a path string containing the current user environment path
%   (if it exists). On UNIX, the userpath is taken from the MATLABPATH
%   environment variable.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.2.1 $ $Date: 2002/10/09 17:36:47 $

cname = computer;
if (strncmp(cname,'PC',2))
   p = getenv('USERPROFILE');
   if ~(isempty(p))
      p = [p '\matlab'];
      if (exist(p,'dir'))
         p(end+1) = ';';
      else 
         p = '';
      end
   end   
   
else % Must be UNIX
  p = [getenv('MATLABPATH') ':'];
  % Remove any redundant toolbox/local
  p = strrep(p,[matlabroot '/toolbox/local'],'');
  p = strrep(p,'::',':');
end

