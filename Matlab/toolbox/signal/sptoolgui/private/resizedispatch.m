function resizedispatch
% RESIZEDISPATCH This function is the resizefcn for all the SPTool
%                components.  Once called it parses the complete
%                resizefcn (figure property) string and executes all
%                other resize function calls listed in resizefcn string.
%                At the end of the function, if the figure position
%                changed, it manually calls (EVALs) the resizefcn 
%                string again.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

% Get handle to figure and store it.
hFig = gcf;

% Cache the figure's position to be checked against later.
fpos = get(hFig,'position'); 

% Cache the complete resizefcn string
resizefcnList = get(hFig,'resizefcn');

% Parse the resizefcn string; 
%     1. remove the first function call which is this function
%        and the delimeter which is a percent sign, %.
%     2. then execute the remaining resize fcns
indx = findstr(resizefcnList,'%');
eval(resizefcnList(indx+2:end));

% If the figure's size changed during a resize call, then
% make sure the other resize functions listed in resizefcnList 
% have a chance to resize according to the new figure size.
% This is necessary because repeatedly setting the figure's 
% size does not invoke the resize fcn each time - HG has short 
% circuit code to prevent infinite resizing loops.
new_fpos = get(hFig,'position');
if ~isequal(fpos(3:4),new_fpos(3:4)),
   eval(resizefcnList(indx+2:end));
end

% [EOF] resizedispatch.m
