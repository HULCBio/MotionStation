function w = addwave(this, varargin)
%ADDWAVE  Adds a new wave to a wave plot.
%
%   W = ADDWAVE(WAVEPLOT,CHANNELINDEX,NWAVES) adds a new wave W
%   to the wave plot WAVEPLOT.  The index vector CHANNELINDEX
%   specify the wave position in the axes grid, and NWAVES is
%   the number of waves in W (default = 1).
%
%   W = ADDWAVE(WAVEPLOT,DATASRC) adds a wave W that is linked to the 
%   data source DATASRC.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:28 $

if ~isempty(varargin) & isnumeric(varargin{1})
   % Size check
   if max(varargin{1})>this.AxesGrid.Size(1)
      error('Axis grid does not have enough rows to contain this wave.')
   end 
   % Insert column index
   varargin = [varargin(1) {1} varargin(2:end)];
end

% Add new wave
try
   w = addwf(this,varargin{:});
catch
   rethrow(lasterror)
end

% Resolve unspecified name against all existing "untitledxxx" names
setDefaultName(w,this.Waves)

% Add to list of waves
this.Waves = [this.Waves ; w];