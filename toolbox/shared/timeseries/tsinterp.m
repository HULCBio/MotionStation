function out = tsinterp(type,t,T,X)
%TSINTERP Utility used to define the default time series interpolation 
%
% Predefined interpolation function handles must be on the path and not
% local functions so that the time series object can be saved. They have
% been assembled into a single function called with the type of
% interpolation to avoid creating multiple interpolation functions in the
% parent folder
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:34:13 $


switch lower(type)
   case 'zoh'
       out = zordhold(t,T,X);
   case 'linear'
       out = linearinter(t,T,X);
   case 'nan'
       out = nanhold(t,T,X);
end
   
function out = zordhold(t,T,X)

% Find NaN values and initialize output
s = size(X);
out = zeros([length(t),s(2:end)]);

% Find NaN values. Note that since the "interpolation" function is always
% called vie tsArrayFcn we are guarenteed that if any part of a "row" has 
% NaN value then the entire row is all NaNs  
nanvals = isnan(X);
if length(s)==2 && min(s)==1
    I = find(~nanvals);
else % Find any NaN valued rows
    I = find(~any(nanvals(:,:)'));
end

for k=1:length(t)
   Iref = I(find(T(I)<=t(k)));
   if ~isempty(Iref)
       out(k,:) = X(max(Iref),:);
   else % t starts before the time vector
       out(k,:) = repmat(NaN,1,s(2:end));
   end
end

function out = linearinter(t,T,X)

if t(1)<T(1) || t(end)>T(end)
    error('interpolation:interpolation:noextrap','Cannot exrapolate')
end

% Find any observations that would cause interp to return NaNs
% Note that this function is called through tsArrayFcn, so if
% a row has a NaN value, all observations in that row have NaN
% values
nanobs = isnan(X);
I = find(any(nanobs'));

s = size(X);
if length(I)>1   
    out = interp1(T(I),reshape(X(I,:),[length(I) s(2:end)]),t,'linear');
else
    out = ones([length(t), s(2:end)])*NaN;
end

function out = nanhold(t,T,X)

% If time vector is a cell array of datestrs then
% convert to datenum
if iscell(t) || ischar(t)
    t = datenum(t);
end
if iscell(T) || ischar(T)
    T = datenum(T);
end

out = zeros(length(t),size(X,2))*NaN;
for k=1:length(t)
   [tdelta I] = min(abs(T-t(k)));
   if tdelta<=eps
       out(k,:) = X(I(1),:);
   end
end
