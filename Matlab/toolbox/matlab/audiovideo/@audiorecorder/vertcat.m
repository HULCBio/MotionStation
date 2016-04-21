function c = vertcat(varargin)
%VERTCAT Vertical concatenation of audiorecorder objects.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:01:06 $

error('MATLAB:audiorecorder:nocatenation',...
       audiorecordererror('matlab:audiorecorder:nocatenation'));
