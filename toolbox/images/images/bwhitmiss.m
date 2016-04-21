function bw2 = bwhitmiss(varargin)
%BWHITMISS Binary hit-miss operation.
%   BW2 = BWHITMISS(BW,SE1,SE2) performs the hit-miss operation defined
%   by the structuring elements SE1 and SE2.  The hit-miss operation
%   preserves pixels whose neighborhoods "match" the shape of SE1 and
%   don't match the shape of SE2.  SE1 and SE2 may be flat structuring 
%   element objects returned by the STREL function or they may be 
%   neighborhood arrays.  The domains of SE1 and SE2 should not have
%   any common elements.  BWHITMISS(BW,SE1,SE2) is equivalent to
%   IMERODE(BW,SE1) & IMERODE(~BW,SE2).
%
%   BW2 = BWHITMISS(BW,INTERVAL) performs the hit-miss operation defined
%   in terms of a single array, called an "interval."  An interval is an
%   array whose elements can be either 1, 0, or -1.  The 1-valued
%   elements make up the domain of SE1; the -1-valued elements make up
%   the domain of SE2; and the 0-valued elements are ignored.
%   BWHITMISS(INTERVAL) is equivalent to BWHITMISS(BW,INTERVAL == 1,
%   INTERVAL == -1). 
%
%   Class support
%   -------------
%   BW1 can be nonsparse logical or numeric array of any class and 
%   dimension.  BW2 is always a logical array with the same size as BW1.
%   SE1 and SE2 must be flat STREL objects or they must be logical or 
%   numeric arrays containing 1s and 0s.
%   INTERVAL must be an array containing 1s, 0s, and -1s. 
%
%   Example
%   -------
%       bw = [0 0 0 0 0 0
%             0 0 1 1 0 0
%             0 1 1 1 1 0
%             0 1 1 1 1 0
%             0 0 1 1 0 0
%             0 0 1 0 0 0]
%
%       interval = [0 -1 -1
%                   1  1 -1
%                   0  1  0];
%
%       bw2 = bwhitmiss(bw,interval)
%
%   See also IMDILATE, IMERODE, STREL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2003/08/01 18:08:35 $

% Testing notes
% -------------
% bw       - Real, numeric, nonsparse array, any dimension.
%            Infs and NaNs ok, treated as nonzero.
%            Empty ok.
%            Required.
%
% se1,se2  - Either a flat strel object or real, double array
%            containing 0s and 1s.  Either can be an empty strel.
%
% interval - Real, numeric array containing only 0s, 1s, and -1s.
%            Output is all 1s if interval is empty.

[bw,se1,se2] = parse_inputs(varargin{:});

bw2 = imerode(bw,se1) & ~imdilate(bw,reflect(se2));


% --------------------------------------------------

function [bw,se1,se2] = parse_inputs(varargin)

checknargin(2,3,nargin,mfilename);

bw = varargin{1};
checkinput(bw,{'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, ...
           'BW', 1);

if ~islogical(bw)
    bw = bw ~= 0;
end

if nargin == 2
    % BWHITMISS(BW,INTERVAL)
    interval = varargin{2};
    checkinput(interval, {'numeric'}, {'real'}, mfilename, 'INTERVAL', 2);

    interval = double(interval);
    if ~all((interval(:) == 1) | (interval(:) == 0) | (interval(:) == -1))
        eid = 'Images:bwhitmiss:invalidIntervalValues';
        msg = 'INTERVAL must contain only -1s, 0s, and 1s.';
        error(eid,'%s',msg);
    end
    if isempty(interval)
        se1 = strel(interval);
    else
        se1 = strel(interval == 1);
    end
    
    if isempty(interval)
        se2 = strel(interval);
    else
        se2 = strel(interval == -1);
    end
        
elseif nargin == 3
    % BWHITMISS(BW,SE1,SE2)
    se1 = varargin{2};
    se2 = varargin{3};
    se1 = strelcheck(se1,mfilename,'SE1',2);
    se2 = strelcheck(se2,mfilename,'SE2',3);

    
else
    % This line should be unreachable.
    eid = 'Images:bwhitmiss:unknownSyntaxError';
    error(eid, '%s', 'Invalid input syntax.');
end

if ~isflat(se1) | ~isflat(se2)
    eid = 'Images:bwhitmiss:nonflatStrels';
    msg = 'SE1 and SE2 must be flat structuring elements.';
    error(eid,'%s',msg);
end
