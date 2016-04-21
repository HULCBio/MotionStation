function [cmat,hout,msg] = contor3m(varargin)
%CONTOR3M  Project a 3D contour plot of data onto the current map axes.
%
%   CONTOR3M is obsolete and may be removed in the future. Use CONTOUR3M.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2003/12/13 02:52:45 $

warnobsolete(mfilename);
[cmat, hout, msg] = contour3m(varargin{:});
