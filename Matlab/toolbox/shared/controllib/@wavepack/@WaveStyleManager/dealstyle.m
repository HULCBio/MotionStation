function style = dealstyle(this,StyleList)
%DEALSTYLE  Deals next available style.
%
%   Returns the next available @style instance given the list STYLELIST of 
%   styles of waveforms currently plotted.

%   Author(s): John Glass
%   Revised  : Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:36 $

% Define a default list to count the number of times that a style object
% has been used.
index = zeros(size(this.Styles));

% Search through all existing responses. Increment index for all style matches.
for st=StyleList'
    match = find(st == this.Styles);
    index(match) = index(match) + 1;
end

% Get the least used style
[min_value, min_ind] = min(index);
style = this.Styles(min_ind);   