function h = gcr(ax)
%GCR  Gets @respplot handle associate with given HG axes.
%
%   H = GCR returns a @respplot handle if the current axes (GCA)
%   contains a response plot, and H=[] otherwise.
%
%   H = GCR(AX) returns the handle of the response plot contained
%   in the HG axes AX.
%
%   See also GCA.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/04/10 04:42:32 $

if nargin==0
   ax = gca;
end
if isappdata(ax,'WaveRespPlot')
   h = getappdata(ax,'WaveRespPlot');
   if ~isa(h,'wrfc.plot')
      h = [];
   end
else
   h = [];
end