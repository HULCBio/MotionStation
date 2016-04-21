function str = maketip(src,event_obj,info)
%MAKETIP  Build data tips for LTI responses.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): P. Gahinet, B. Eryilmaz.
%   Revised  : K. Subbarao 10-29-2001   
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:00 $

% Context 
r = info.Carrier;
h = r.Parent;
AxGrid = h.AxesGrid;

% Model array indices
Size = size(src.Model);
if length(Size)<3
   astr = '';
elseif all(Size(4:end)==1)
   astr = sprintf('(:,:,%d)',info.ArrayIndex);
else
   asize = Size(3:end);
   aindex = cell(1,length(asize));
   [aindex{:}] = ind2sub(asize,info.ArrayIndex);
   astr = sprintf(',%d',aindex{:});
   astr = sprintf('(:,:%s)',astr);
end

% Standard tip
str = maketip(info.View,event_obj,info);

% Customize header
str{1} = sprintf('System: %s%s', r.Name, astr);

