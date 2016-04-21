function retval = surfaceplot(varargin)
%SURFACEPLOT Surface plot constructor

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/10 23:26:43 $

% Default values
xdata = [];
ydata = [];
zdata = [];
cdata = [];
xdatamode = 'auto';
ydatamode = 'auto';
cdatamode = 'auto';

% Determine number of numeric data arguments
len = length(varargin);
n = 1;
while n <= len && isnumeric(varargin{n}) 
  n = n + 1;
end
n = n - 1;

% Determine appropriate syntax
switch (n)

  % SURFACEPLOT(Z,...)
  case 1
    zdata = varargin{1};
    xdata = 1:size(zdata,2);
    ydata = (1:size(zdata,1))';
    cdata = zdata;

  % SURFACEPLOT(Z,C,...)
 case 2
    cdatamode = 'manual';
    zdata = varargin{1};
    xdata = 1:size(zdata,2);
    ydata = (1:size(zdata,1))';
    cdata = varargin{2};
  
  % SURFACEPLOT(X,Y,Z,...)
 case 3
    xdatamode = 'manual';
    ydatamode = 'manual';
    xdata = varargin{1};
    ydata = varargin{2};
    zdata = varargin{3};
    cdata = zdata;
 
  % SURFACEPLOT(X,Y,Z,C,...)
 case 4
    xdatamode = 'manual';
    ydatamode = 'manual';
    cdatamode = 'manual';
    xdata = varargin{1};
    ydata = varargin{2};
    zdata = varargin{3};
    cdata = varargin{4};    
end

% Cycle through parameter list and pull out properites defined by 
% this class since we can't pass them down to the super constructor 
% (surface).
argin_param = {varargin{(n+1):end}};
len = length(varargin)-n;
propsToSet = {};
if len > 0 
  % must be even number for param-value syntax
  if mod(len,2)>0 
      error('MATLAB:graph3d:surfaceplot','Invalid input arguments');
  end

  c = {varargin{(n+1):end}};  
  idxremove = []; 
  for i = 1:2:length(c)
     switch(c{i})
         case 'xdata' 
            xdatamode = 'manual';
         case 'ydata'
            ydatamode = 'manual';
         case 'cdata'
            cdatamode = 'manual';
      
         % Public properties defined by this class (see schema.m)
         case  {'XDataMode','XDataSource',...
                'YDataMode','YDataSource',...
                'CDataMode','CDataSource',...
                'ZDataSource','DisplayName',...
                'Initialized'}

            idxremove = [i,i+1,idxremove];
            propsToSet = { propsToSet{:},c{i}, c{i+1} };
      end % switch     
  end % for
  
  % set indices of fields to keep
  idxkeep = 1:length(c);
  idxkeep(idxremove) = [];

  argin_param = {c{idxkeep}};
end
                          
argin_data = {};
if n>0
   argin_data = {'xdata',xdata,...
                 'ydata',ydata,...
                 'zdata',zdata,...
                 'cdata',cdata};
end

% call super constructor
argin = {argin_data{:},argin_param{:}};

h = graph3d.surfaceplot(argin{:});

% Set mode values
set(h,'XDataMode',xdatamode);
set(h,'YDataMode',ydatamode);
set(h,'CDataMode',cdatamode);

% Set properties defined by this class
if length(propsToSet)>1
   set(double(h),propsToSet{:});
end

% Activate datamode listeners only if this object is 
% not being deserialized
if ~isappdata(0,'BusyDeserializing')
   set(h,'Initialized',true);
end

% Update plot tool
plotdoneevent(ancestor(h,'axes'),h);

if nargout>0
  retval = h;
end
