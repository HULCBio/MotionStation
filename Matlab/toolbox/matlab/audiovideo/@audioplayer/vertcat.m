function c = vertcat(varargin)
%VERTCAT Vertical concatenation of audioplayer objects.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:52 $

error('MATLAB:audioplayer:nocatenation',...
       audioplayererror('matlab:audioplayer:nocatenation'));
