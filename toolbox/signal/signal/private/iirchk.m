function [btype,analog,errStr] = iirchk(Wn,varargin)
%IIRCHK  Parameter checking for BUTTER, CHEBY1, CHEBY2, and ELLIP.
%   [btype,analog,errStr] = iirchk(Wn,varargin) returns the 
%   filter type btype (1=lowpass, 2=bandpss, 3=highpass, 4=bandstop)
%   and analog flag analog (0=digital, 1=analog) given the edge
%   frequency Wn (either a one or two element vector) and the
%   optional arguments in varargin.  The variable arguments are 
%   either empty, a one element cell, or a two element cell.
%
%   errStr is empty if no errors are detected; otherwise it contains
%   the error message.  If errStr is not empty, btype and analog
%   are invalid.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.7 $

errStr = '';

% Define defaults:
analog = 0; % 0=digital, 1=analog
btype = 1;  % 1=lowpass, 2=bandpss, 3=highpass, 4=bandstop

if length(Wn)==1
    btype = 1;  
elseif length(Wn)==2
    btype = 2;
else
    errStr = 'Wn must be a one or two element vector.';
    return
end

if length(varargin)>2
    errStr = 'Too many input arguments.';
    return
end

% Interpret and strip off trailing 's' or 'z' argument:
if length(varargin)>0 
    switch lower(varargin{end})
    case 's'
        analog = 1;
        varargin(end) = [];
    case 'z'
        analog = 0;
        varargin(end) = [];
    otherwise
        if length(varargin) > 1
            errStr = 'Analog flag must be either ''z'' or ''s''.';
            return
        end
    end
end

% Check for correct Wn limits
if ~analog
   if any(Wn<=0) | any(Wn>=1)
      errStr = 'The cutoff frequencies must be within the interval of (0,1).';
      return
   end
else
   if any(Wn<=0)
      errStr = 'The cutoff frequencies must be greater than zero.';
      return
   end
end

% At this point, varargin will either be empty, or contain a single
% band type flag.

if length(varargin)==1   % Interpret filter type argument:
    switch lower(varargin{1})
    case 'low'
        btype = 1;
    case 'bandpass'
        btype = 2;
    case 'high'
        btype = 3;
    case 'stop'
        btype = 4;
    otherwise
        if nargin == 2
            errStr = ['Option string must be one of ''high'', ''stop'',' ...
              ' ''low'', ''bandpass'', ''z'' or ''s''.'];
        else  % nargin == 3
            errStr = ['Filter type must be one of ''high'', ''stop'',' ...
              ' ''low'', or ''bandpass''.'];
        end
        return
    end
    switch btype
    case 1
        if length(Wn)~=1
            errStr = 'For the ''low'' filter option, Wn must have 1 element.';
            return
        end
    case 2
        if length(Wn)~=2
            errStr = 'For the ''bandpass'' filter option, Wn must have 2 elements.';
            return
        end
    case 3
        if length(Wn)~=1
            errStr = 'For the ''high'' filter option, Wn must have 1 element.';
            return
        end
    case 4
        if length(Wn)~=2
            errStr = 'For the ''stop'' filter option, Wn must have 2 elements.';
            return
        end
    end
end

