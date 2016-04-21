function f = fullfile(varargin)
%FULLFILE Build full filename from parts.
%   FULLFILE(D1,D2, ... ,FILE) builds a full file name from the
%   directories D1,D2, etc and filename FILE specified.  This is
%   conceptually equivalent to
%
%      F = [D1 filesep D2 filesep ... filesep FILE] 
%
%   except that care is taken to handle the cases where the directory
%   parts D1, D2, etc. may begin or end in a filesep. Specify FILE = ''
%   to build a pathname from parts. 
%
%   Examples
%     To build platform dependent paths to files:
%        fullfile(matlabroot,'toolbox','matlab','general','Contents.m')
%
%     To build platform dependent paths to a directory:
%        addpath(fullfile(matlabroot,'toolbox','matlab',''))
%
%   See also FILESEP, PATHSEP, FILEPARTS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $ $Date: 2002/06/17 13:26:57 $

if nargin<2, error('Not enough input arguments.'); end
fs = filesep;
f = varargin{1};

% Be robust to / or \ on PC
if strncmp(computer,'PC',2)
   f = strrep(f,'/','\');
end

for i=2:nargin,
   part = varargin{i};
   if isempty(f) | isempty(part)
      f = [f part];
   else
      % Handle the three possible cases
      if (f(end)==fs) & (part(1)==fs),
         f = [f part(2:end)];
      elseif (f(end)==fs) | (part(1)==fs)
         f = [f part];
      else
         f = [f fs part];
      end
   end
end
