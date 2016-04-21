function varargout = dspblkbfftscope(action, varargin)
% DSPBLKBFFTSCOPE Signal Processing Blockset Buffered FFT scope block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:06:01 $

% Params structure fields:
%
% 1: FFTlength
% 2: BufferSize
% 3: Overlap
%
% Add 3 to the index of all the following:
%
% (invis) 1 Domain: 0=Time, 1=Frequency, 2=User Defined
%
% (invis) 2 XLabel:
%     Time, Frequency: ignored
%     User: displayed
% 3 XUnits:
%     User, Time: ignored
%     Freq: 0=Hz, 1=rad/sec
% 4 XRange:
%     User, Time: ignored
%     Freq: 0=[0,Fn] , 1=[-Fn,Fn], 2=[0, Fs]
%                (Fn=Nyquist rate, Fs=Sample rate)
% 5 XIncr: increment of x-axis samples, used for x-axis display
%     Time: ignored (assumes frame-based)
%     Freq: Only displayed if data was zero-padded
%     User: seconds per sample
% 6 YLabel:
%     Always used
% 7 YUnits:
%      User, Time: ignored
%      Freq: 0=Magnitude, 1=dB
%
% (invis) 8 HorizSpan: Horizontal time span (number of frames)
% 9 NChans: Number of frames (columns) in input matrix
%
% (10) AxisParams: checkbox
% 11 YMin: minimum Y-limit
% 12 YMax: maximum Y-limit
% 13 FigPos: figure position
% 14 AxisGrid: checkbox
% 15 AxisZoom: checkbox
% 16 FrameNumber: checkbox
% 17 AxisLegend: checkbox
% 18 Memory: checkbox
%
% (19) LineParams: checkbox
% 20 LineVisibilities
% 21 LineColors: pipe-delimited string
% 22 LineStyles: pipe-delimited string
% 23 LineMarkers: pipe-delimited string

if nargin==0, action = 'dynamic'; end
blk = gcb;
domain = get_param(blk,'Domain');

switch action
case 'icon'
   
   if ~strcmp(domain,'Frequency'),
      error('Invalid domain for Buffered FFT scope');
   end
   
   % Frequency domain:
   x = [0 NaN 100 NaN ...
         8 8 92 92 8 NaN 16 16 84 NaN 24 24 NaN 32 32 32 NaN ...
         40 40 NaN 48 48 NaN 56 56 NaN 64 64 NaN ...
         80 80 80 80 NaN 72 72 72];
   y = [0 NaN 100 NaN ...
         92 40 40 92 92 NaN 88 48 48 NaN 76 48 NaN 65 48 48 NaN ...
         79 48 NaN 60 48 NaN 58 48 NaN 64 48 NaN ...
         49 49 48 48 NaN 48 48 54];
   
   str = 'B-FFT';  % domain(1:4);
   varargout(1:3) = {x,y,str};
   

case 'init'

    % Copy all mask entries to structure:
    n = get_param(blk,'masknames');
    s = cell2struct(varargin,n,2);
    varargout{1} = s;

	sdspfscope([],[],[],'DialogApply',s);


case 'dynamic'
   
   opt = varargin{1};
   vis = get_param(blk,'maskvisibilities');
   orig_vis = vis;
   prompts = get_param(blk,'maskprompts');
   orig_prompts = prompts;
   
   % Turn off several standard Frame-Scope options, since
   % this scope only operates in the frequency domain:
   vis(3+[1 2 8]) = {'off'};
   
   switch opt
   case 'Domain'    
      % Set visibilities of: 2:XLabel, 3:XUnits, 4:XIncr, 5:XRange,
      %                      7:YRange, 8:HorizSpan
      switch domain
      case 'Time'
         vis(3+[2 3 4 5 7]) = {'off'};
         vis(3+8) = {'on'};
         prompts{3+8}='Time display span (number of frames):';
         
      case 'Frequency'
         vis(3+[2 8]) = {'off'};
         vis(3+[3 4 5 7]) = {'on'};
         prompts{3+5} = 'Sample time of original time series (-1 if not zero-padded):';
         
      otherwise
         % User defined:
         vis(3+[2 5 8]) = {'on'};
         vis(3+[3 4 7]) = {'off'};
         prompts{3+5} = 'Increment per sample in input frame:';
         prompts{3+8} = 'Horizontal display span (number of frames):';
      end
      
   case 'AxisParams'
      % Set visibility of additional parameters:
      if strcmp(get_param(blk,'AxisParams'),'on');
         vis(3+(11:18))={'on'};
      else
         vis(3+(11:18))={'off'};
      end
            
   case 'LineParams'
      % Set visibility of additional parameters:
      if strcmp(get_param(blk,'LineParams'),'on');
         vis(3+(20:23))={'on'};
      else
         vis(3+(20:23))={'off'};
      end
            
   otherwise
      error('Unknown dynamic dialog callback');
   end
   
   if ~isequal(vis,orig_vis) | ~isequal(prompts,orig_prompts),
      set_param(blk, ...
         'maskvisibilities',vis, ...
         'maskprompts',prompts);
   end
end

% [EOF] dspblkbfftscope.m
