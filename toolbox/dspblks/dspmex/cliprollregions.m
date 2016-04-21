function y = ClipRollRegion(x,varargin)
% CLIPROLLREGION Clip a RollRegions string for use by the TLC roller.
%
% ClipRollRegion(RollRegion, first, last) clips the RollRegion string
%   to start at index FIRST and end at index LAST.
%
%   Indices are "1-based", i.e., first=1 retains the first roll region
%   index.  Note that LAST=-1 specifies that all entries (after the FIRST
%   one) are to be preserved.

% ClipRollRegion(RollRegion, idx)             - Not implemented
% ClipRollRegion(RollRegion, first,skip,last) - Not implemented

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:07:54 $

error(nargchk(2,4,nargin));
reg = parse_roll_regions(x);                 % Parse roll regions string
ireg = index_roll_regions(reg, varargin{:}); % Construct new roll regions
y = roll_regions_string(ireg);               % Convert to roll regions string

return

% -------------------------------------------------------------------------

function reg = parse_roll_regions(x)
% PARSE_ROLL_REGIONS

% Input must be a string
if ~ischar(x),
   error('Input must be a string');
end

% Deblank both sides of string:
i = find(~isspace(x));
x = x(min(i):max(i));

% Input must be of the form: '[...]'
% Verify, and remove brackets:
if (length(x)<3) | (x(1)~='[') | (x(end)~=']'),
   error('Improper roll regions string');
end
x=x(2:end-1);

% Parse indices of the form:
%    'a b:c d e f:g'
rnum = 1;
r = x;
while(~isempty(r)),
   % Get next index region
   [t,r] = strtok(r, ' ,');
   
   % Token is either single index, or region
   ic = find(t==':');
   if length(ic)>1,
      error('Improper roll regions string');
      
   elseif isempty(ic),
      % Single index:
      reg(rnum).first = str2num(t);
      reg(rnum).last  = reg(rnum).first;
      reg(rnum).num   = 1;
   else
      % Index range:
      a = str2num(t(1:ic-1));
      b = str2num(t(ic+1:end));
      reg(rnum).first = a;
      reg(rnum).last  = b;
      reg(rnum).num   = b-a+1;
   end
   rnum=rnum+1;  % Next region
end
return

% -------------------------------------------------------------------------

function new_reg = index_roll_regions(reg, varargin)
% INDEX_ROLL_REGIONS

num_idx = length(varargin);
i1 = varargin{1};
if num_idx>1, i2 = varargin{2}; end
if num_idx>2, i3 = varargin{3}; end

% Find the very last roll region index, and
% convert from a 0- to a 1-based index:
last_entry = reg(end).last+1;

if num_idx==2,
   % i1=first, i2=last
   
   % Assign last index to wildcard entry (-1):
   if strcmp(i2,'end'),
      i2 = -1;
   end
   if (i2==-1),
      i2=last_entry; % =reg(end).last+1;
   end
   
   % Check that user indices are not out-of-bounds:
   if i1<1 | i1>last_entry,
      error('first index invalid');
   end
   if i2<i1 | i2>last_entry,
      error('last index invalid');
   end
   
   % Get the roll region and index into the roll region
   % for the user's start and end indices:
   [r1,j1] = inregion(reg,i1);
   [r2,j2] = inregion(reg,i2);
   
   % Retain only the needed subset of roll regions
   % which span the user's index range:
   new_reg=reg(r1:r2);
   
	if(r1==r2)
      % Only one roll region needs to be retained:
      jdiff = j2-j1;   % number of elements to keep in region
      new_reg(1).first = new_reg(1).first + (j1-1);
      new_reg(1).last  = new_reg(1).first + jdiff;
   else
      % Multiple consecutive roll regions need to be retained:
      new_reg(1).first  = new_reg(1).first   + j1-1;
      new_reg(end).last = new_reg(end).first + j2-1;
   end
   
elseif num_idx==3,
   % i1=first, i2=skip, i3=last
   error('first,skip,last not implemented')

else % num_idx==1
   % i1=index vector
   error('Index vector not implemented')

end
return

% -------------------------------------------------------------------------

function y = roll_regions_string(new_reg)
% ROLL_REGIONS_STRING
y = '[';
for i=1:length(new_reg),
   y=[y num2str(new_reg(i).first)];
   if new_reg(i).first ~= new_reg(i).last,
      y=[y ':' num2str(new_reg(i).last)];
   end
   if i<length(new_reg),
      y=[y ', '];
   end
end
y=[y ']'];
return

% -------------------------------------------------------------------------

function [r,j] = inregion(reg,i)
% INREGION
% Determine the index region containing index i
%
% Example:
%   reg (TLC RollRegions) = [1:3 4 5:10]
%   If i=2, r (region #) = 1, j (offset) = 2
%   If i=7, r (region #) = 3, j (offset) = 3

% r=index region #, r=1,2,...
% j=relative index in region, j=1,2,...

i=i-1; % convert from 1-based to 0-based indices
r=[];
for k=1:length(reg),
   if (i>=reg(k).first & i<=reg(k).last),
      r = k;
      break;
   end
end
if isempty(r),
   error('Specified index not in roll region');
end
j = i - reg(k).first + 1;

return

% -------------------------------------------------------------------------
