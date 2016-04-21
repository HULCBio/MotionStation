function c = horzcat(varargin)
%HORZCAT Horizontal concatenation of audiorecorder objects.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:00:32 $

if (nargin == 1)
   c = varargin{1};
else
   error('MATLAB:audiorecorder:nocatenation',...
          audiorecordererror('matlab:audiorecorder:nocatenation'));
end
