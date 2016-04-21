function r = addresponse(this, varargin)
%ADDRESPONSE  Adds a new response to a response plot.
%
%   R = ADDRESPONSE(RESPPLOT,ROWINDEX,COLINDEX,NRESP) adds a new response R
%   to the response plot RESPPLOT.  The index vectors ROWINDEX and COLINDEX
%   specify the response I/O sizes and position in the axes grid, and NRESP
%   is the number of individual responses in R (default = 1).
%
%   R = ADDRESPONSE(RESPPLOT,DATASRC) adds a response R that is linked to the 
%   data source DATASRC.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:28 $

% Size checking
if length(varargin)>1 & ...
      (max(varargin{1})>this.AxesGrid.Size(1) | ...
      max(varargin{2})>this.AxesGrid.Size(2))
   error('Axis grid does not have enough rows or columns to contain this response.')
end

% Add new response
try
   r = addwf(this,varargin{:});
catch
   rethrow(lasterror)
end

% Resolve unspecified name against all existing "untitledxxx" names
setDefaultName(r,this.Responses)

% Add to list of responses
this.Responses = [this.Responses ; r];