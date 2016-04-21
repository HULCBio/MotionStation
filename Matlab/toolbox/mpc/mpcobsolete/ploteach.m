function [Hy,Hu]=ploteach(y,u,t,replace)

%PLOTEACH Plot each y and each u separately
%   	ploteach(y)
%   	ploteach([],u)
%   	ploteach(y,u)
%   	ploteach(y,[],t)
%  	    ploteach(y,u,t)
%       ploteach(y,u,t,replace)
% Up to four plots are be plotted on a screen
%
% Inputs:
%  y : outputs
%  u : manipulated variables
%  t : time interval or sequence of times
%  replace : 'on' to over-write existing plots.  Otherwise creates
%            additional plots in new windows.
%
% [Hy,Hu]=ploteach(y,u,t) returns handles of the figure windows
% containing y and u, respectively.
%
% See also PLOTALL, PLOTSTEP, PLOTFRSP.

% Written by N. L. RICKER, July 3, 1990.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $ Date: $

if nargin == 0,
   disp('Usage:  ploteach(y,u,t,replace)');
   return
end
if ~isempty(y)
   [m,ny] = size(y);
end

if nargin > 1
   if ~isempty(u)
      [mu,nu] = size(u);
      if isempty(y)
         m=mu;
      else
         if mu ~= m
            error('Y and U must have same number of rows.')
         end
      end
   end
else
   u=[];
end

if isempty(y) & isempty(u)
   error('Y and U were both empty ... no data to plot.')
end

yFig=[]; uFig=[];
if (nargin>=3)
   [mt,nt]=size(t);
   if nt ~= 1
      error('T must be a scalar or a column vector.')
   elseif mt == 1
      delt = t;
      t = delt*[0:m-1]';
   elseif mt ~= m
      error('Number of rows in T must be same as in Y and/or U.')
   end
else
   delt = 1;
   t = delt*[0:m-1]';
end
if nargin == 4 && strcmpi(replace,'on')
    % Replacing, so delete existing plots
    set(0,'showhiddenhandles','on')
    delete(findobj('Name','Outputs'));
    delete(findobj('Name','Inputs')); 
    set(0,'showhiddenhandles','off')
end

if ~isempty(y)
	% Plot the outputs
	y = y(1:m,:);
	Title=cell(ny,1);
	for i=1:ny
		Title{i}=['Output ',int2str(i)];
	end
	Data=struct('x',{t},'y',{y},'iy',{[1:ny]'},'title',{Title},...
            'legend',{[]},'xlabel','Time');
	yFig=mpcplot('Initialize',Data,'Outputs');
end

if ~isempty(u)
	% Plot the inputs in a separate window, offset
    tstair=mpcstair(t,1);
    ustair=mpcstair(u);
	Title=cell(nu,1);
	for i=1:nu
		Title{i}=['Input ',int2str(i)];
	end
	Data=struct('x',{tstair},'y',{ustair},'iy',{[1:nu]'},'title',{Title},...
            'legend',{[]},'xlabel','Time');
	uFig=mpcplot('Initialize',Data,'Inputs',20);
end

% Return optional figure window handles.
if nargout > 0
	Hy=yFig;
end
if nargout > 1
	Hu=uFig;
end

% end of function PLOTEACH.M
