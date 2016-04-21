function list = dspTrimItemList(list)
% trimItemList Signal Processing Blockset Dynamic Dialog block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:05:52 $

% trimItemList takes an input cell aray and trims out the empty elements

list = list(~cellfun('isempty',list));
