function h = ltisource(model,varargin)
%LTISOURCE  Constructor for @ltisource class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:59 $

% Create class instance
h = resppack.ltisource;

% Initialize attributes
h.Model = model;

% RE: SimStep is the time step for simulation of continuous-time models
Nresp = getsize(h,3);
% RE: DCGain is the array of step response steady-state values
h.TimeResponse = struct(...
   'DCGain',  [],...
   'SimStep', cell(Nresp,1));
% RE: Magnitude (abs) is Nf x Ny x Nu
%     Phase (rad, unwrapped) is Nf x Ny x Nu
h.FreqResponse = struct(...
   'Frequency', cell(Nresp,1), ...
   'Magnitude', [], ...
   'Phase', [], ...
   'Grade', [], ...
   'FocusInfo', [], ...
   'MarginInfo',[]);
% Zero/pole/gain data
h.ZPKData = struct(...
   'Zero', [], ...
   'Pole', [], ...
   'Gain', cell(Nresp,1));   

% Add listeners
h.addlisteners;

% Set additional parameters in varargin
if ~isempty(varargin)
    set(h,varargin{:});
end

