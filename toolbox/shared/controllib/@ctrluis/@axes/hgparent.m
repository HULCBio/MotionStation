function f = hgparent(Axes)
%HGPARENT  Gets handle of parent in HG hierarchy.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:31 $

f = get(Axes.Handle,'parent');