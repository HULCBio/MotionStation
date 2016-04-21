function []=plotall(y,u,t)

%PLOTALL Plot manipulated and controlled variables on one "page".
%        []=plotall(y,u)
%        []=plotall(y,u,t)
% Plots y and u in separate graphs versus time.  Converts
% u to a stairstep form before plotting.  If y (or u)
% has more than 1 column, all will be plotted on the same
% graph.  If the scalings are very different, this may not be
% satisfactory.  In that case, use PLOTEACH.
%
% Inputs:
%     y    matrix of outputs
%     u    matrix of manipulated variables
%     t    if supplied as scalar, then sampling period
%          if supplied as column vector, then times when
%          samples of y and u where taken.
%
% See also PLOTEACH, PLOTSTEP, PLOTFRSP.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $


if nargin == 0,
   disp('Usage:  plotall(y,u,t)');
   return
end

if nargin < 2
   error('Must supply at least 2 input arguments')
end

[npts,p]=size(y);
[nrowu,m]=size(u);
if nrowu ~= npts
   error('y and u must have the same # of rows')
end
if nargin == 2
   t=[0:npts-1]';
elseif nargin == 3
   [nrowt,ncolt]=size(t);
   if ncolt ~= 1
      error('t must be a column vector')
   elseif nrowt == 1
      t=t*[0:npts-1]';
   elseif nrowt ~= npts
         error('size of time vector inconsistent with size of y')
   end
else
   error('Too many input arguments')
end

tstair=mpcstair(t,1);

clf

subplot(211);
plot(t,y);
title('Outputs');
xlabel('Time');
subplot(212);
plot(tstair,mpcstair(u));
title('Manipulated Variables');
xlabel('Time');