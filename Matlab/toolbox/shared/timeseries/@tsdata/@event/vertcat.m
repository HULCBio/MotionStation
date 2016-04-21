function eout = vertcat(e1,e2)
%VERTCAT Overloaded vertical concatenation for events
%
%
%   Authors: James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:33:16 $

eout = horzcat(e1,e2);