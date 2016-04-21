function c = horzcat(varargin)
%HORZCAT Horizontal concatenation of audioplayer objects.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:12 $

if (nargin == 1)
   c = varargin{1};
else
   error('MATLAB:audioplayer:nocatenation',...
          audioplayererror('matlab:audioplayer:nocatenation'));
end
