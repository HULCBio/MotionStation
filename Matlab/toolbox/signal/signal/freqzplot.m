function freqzplot(h,w,s_in,flag)
%FREQZPLOT Plot frequency response data.
%   FREQZPLOT(H,W) plots the frequency response H computed at the frequencies
%   specified in the vector W (in rad/sample).  When H is a matrix, FREQZPLOT 
%   operates on the columns of H, one frequency response per column.  The 
%   length of the frequency vector W must be the same as the number of rows
%   in the matrix H.
%   
%   FREQZPLOT(H,W,S) specifies additional plotting information that can be altered
%   for different plotting options.  H, W and S can all be obtained from:
%   [H,W,S] = FREQZ(B,A,...).
%
%   S is a structure with the following plotting options:
%
%     S.XUNITS: (string) - frequency (x-axis) units for the plot.
%                          Can be one of 'rad/sample' (default), 'Hz', 'kHz',
%                          'MHz', 'GHz' or a user specified string.
%
%     S.YUNITS: (string) - magnitude (y-axis) units for the plot.
%                          Can be either 'db' (default), 'linear' or 'squared'.
%
%     S.PLOT:   (string) - plot type. Can be either 'both' (default), 'mag' or
%                          'phase'.
%
%     S.YPHASE: (string) - scale of y axis for phase.  Can be either
%                          'degrees' (default) or 'radians'
%
%   FREQZPLOT(H,W,STR) where STR is one of the string options mentioned
%   above, is a quick way to specify a single plotting option.  For 
%   example, FREQZPLOT(H,W,'mag') plots the magnitude only.
%
%   EXAMPLE:
%      nfft = 512; Fs = 44.1; % Fs is in kHz
%      [b1,a1]  = cheby1(5,0.4,0.5);
%      [b2,a2]  = cheby1(5,0.5,0.5);
%      [h1,f,s] = freqz(b1,a1,nfft,Fs);
%      h2       = freqz(b2,a2,nfft,Fs);  % We must use the same nfft and Fs
%      h = [h1 h2];
%      s.plot   = 'mag';     % Plot magnitude only
%      s.xunits = 'khz';     % Label the freq. units correctly
%      s.yunits = 'squared'; % Plot the magnitude squared
%      freqzplot(h,f,s);     % Comparison plot between two Chebyshev filters
%
%   See also FREQZ, INVFREQZ, FREQS and GRPDELAY.

%   Author(s): R. Losada and P. Pacheco 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.31 $  $Date: 2002/11/21 15:46:52 $ 

error(nargchk(2,4,nargin));

if nargin>3,
    if strcmpi(flag, 'magphase') | strcmpi(flag, 'zerocontphase'),
        phi = h(:,:,2);
        h = h(:,:,1);
    elseif strcmpi(flag, 'zerophase'),
        hr =h;
    end
end        

% Generate defaults
s.xunits  = 'rad/sample'; 
s.yunits  = 'db';
s.plot    = 'both'; % Magnitude and phase
s.fvflag  = 0;
s.yphase  = 'degrees';
if nargin > 2,
    [s,msg] = parseOpts(s,s_in);
    error(msg);
end

% Bring the plot to the foreground
if isfield(s,'ax'),
    ax = s.ax;
    hfig = get(ax,'Parent');
    set(hfig,'CurrentAxes',ax);
else
    
    ax = newplot;
    hfig = get(ax, 'Parent');
    figure(hfig);
end

[pd,msg] = genplotdata(h,w,s); % Generate the plot data
error(msg);

switch s.plot,
case 'mag',
    if nargin>3 & strcmpi(flag, 'zerophase'),
        pd.magh = hr;
        pd.magh = [pd.magh;inf*ones(1,size(pd.magh,2))];
        if length(pd.w)<size(pd.magh,2),
            pd.w = [pd.w;2*pd.w(end)-pd.w(end-1)];
        end
        pd.maglabel = 'Zero-phase';
    end
    plotfresp(ax,pd,'mag');
    
case 'phase',
    if nargin>3,
        pd.phaseh = phi;
        pd.phaseh = [pd.phaseh;inf*ones(1,size(pd.phaseh,2))];
        if length(pd.w)<size(pd.phaseh,1),
            pd.w = [pd.w;2*pd.w(end)-pd.w(end-1)];
        end
        if strcmpi(s.yphase, 'degrees'),
            pd.phaseh = pd.phaseh*180/pi;
        end
        if strcmpi(flag, 'zerocontphase'),
            pd.phaselabel = ['Continuous Phase (' s.yphase ')'];
        end
    end
    plotfresp(ax,pd,'phase');
    
case 'both',
    if nargin>3,
        pd.phaseh = phi;
        pd.phaseh = [pd.phaseh;inf*ones(1,size(pd.phaseh,2))];
        if strcmpi(s.yphase, 'degrees'),
            pd.phaseh = pd.phaseh*180/pi;
        end
    end
    % We plot the phase first to retain the functionality of freqz when hold is on
    ax(2) = subplot(212);
    plotfresp(ax(2),pd,'phase');
    ax(1) = subplot(211);
    plotfresp(ax(1),pd,'mag');
    
    if ishold,
        holdflag = 1;
    else
        holdflag = 0;
    end
    axes(ax(1)); % Bring the plot to the top & make subplot(211) current axis
    
    if ~holdflag,    % Reset the figure so that next plot does not subplot
        set(hfig,'nextplot','replace');       
    end      
end

set(ax,'xgrid','on','ygrid','on','xlim',pd.xlim); 
 
%-----------------------------------------------------------------------------------------
function [s,msg] = parseOpts(s,s_in)
%PARSEOPTS   Parse optional input params.
%   S is a structure which contains the fields described above plus:
%
%     S.fvflag - flag indicating if a freq. vector was given or nfft was given
%     S.ax     - handle to an axis where the plot will be generated on. (optional)

msg = '';

% Write out all string options
yunits_opts = {'db','linear','squared'};
plot_opts = {'both','mag','phase'};

if ischar(s_in),
	s = charcase(s,s_in,yunits_opts,plot_opts);
	
elseif isstruct(s_in),
	
	[s,msg] = structcase(s,s_in,yunits_opts,plot_opts);
	
else
    msg = 'Plotting options must be given in a structure.';
    return
end

%-------------------------------------------------------------------------------
function s = charcase(s,s_in,yunits_opts,plot_opts)
% This is for backwards compatibility, if a string with freq. units was
% specified as a third input arg. 
indx = strmatch(lower(s_in),yunits_opts);
if ~isempty(indx),
	s.yunits = yunits_opts{indx};
else
	indx = strmatch(lower(s_in),plot_opts);
	if ~isempty(indx),
		s.plot = plot_opts{indx};
	else
		% Assume these are user specified x units
		s.xunits = s_in;
	end
end

%-------------------------------------------------------------------------------
function [s,msg] = structcase(s,s_in,yunits_opts,plot_opts)

msg = '';

if isfield(s_in,'xunits'),
	s.xunits = s_in.xunits;
end

if isfield(s_in,'yunits'),
	s.yunits = s_in.yunits;
end

if isfield(s_in,'plot'),
	s.plot = s_in.plot;
end

if isfield(s_in,'fvflag'),
	s.fvflag = s_in.fvflag;
end

if isfield(s_in,'ax'),
	s.ax = s_in.ax;
end

if isfield(s_in,'yphase'),
    s.yphase = s_in.yphase;
end

% Check for validity of args
if ~ischar(s.xunits),
	msg = 'Frequency units must be a string.';
	return
end

j = strmatch(lower(s.yunits),yunits_opts);
if isempty(j),
	msg = 'Magnitude units must be ''db'', ''linear'' or ''squared''.';
	return
end
s.yunits = yunits_opts{j};

k = strmatch(lower(s.plot),plot_opts);
if isempty(k),
	msg = 'Plot type must be ''both'', ''mag'' or ''phase''.';
	return
end
s.plot = plot_opts{k};


%-----------------------------------------------------------------------------------------
function plotfresp(ax,pd,type)
switch type
case 'phase'
    data = pd.phaseh;
    lab  = pd.phaselabel;
case 'mag'
    data = pd.magh;
    lab  = pd.maglabel;
    if strcmpi(pd.maglabel, 'zero-phase'),
        lab = 'Amplitude';
    end
end
%axes(ax);
set(ax,'box','on')
line(pd.w,data,'parent',ax);
set(get(ax,'xlabel'),'string',pd.xlab);
set(get(ax,'ylabel'),'string',lab);


% [EOF] - freqzplot.m
