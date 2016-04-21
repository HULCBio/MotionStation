function [cmat,hout] = contorm(varargin)
%CONTORM  Project a contour plot of data onto the current map axes.
%
%   CONTORM is obsolete and may be removed in the future. Use CONTOURM.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.11.4.2 $    $Date: 2003/12/13 02:52:46 $

warnobsolete(mfilename);
[cmat, hout] = contourm(varargin{:});
