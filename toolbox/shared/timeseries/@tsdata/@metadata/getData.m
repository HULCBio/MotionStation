function A = getData(h, data)
%GETDATA Extracts data from @ValueArray data storage
%
%   Author(s): J.G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:22 $

% Gets data from the ValueArray data property if the "data" property

% Note, in this implemention h does not do anything. However, h is used
% in @timemetadata object
A = data;
