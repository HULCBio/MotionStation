function mcodeConstructor(hThis,hCode)
% MCODECONSTRUCTOR Customize code generation for basic fitting
% HTHIS This object
% HCODE Instance of codegen.codeblock class

% Copyright 2003 The MathWorks, Inc.

% Generate code that creates a basic fit line
% using POLYFIT and POLYVAL. The code will have the
% following template:
%   ydata = get(datahandle,'ydata');
%   xdata = get(datahandle,'xdata');
%   [p,s] = polyfit(xdata,ydata,order);
%   xdata_fit = linspace(x1,x2,N);
%   ydata_fit = polyval(p,xdata_fit)
%   h = plot(xdata_fit,ydata_fit);

bfit = getappdata(hThis,'bfit');
if isempty(bfit) | ~isstruct(bfit) | ~isfield(bfit,'index')
  return;
end
n_order = bfit.index;

% Get handle to line containing raw data
hAxes = ancestor(hThis,'axes');
datahandle = localGetDataHandle(hAxes);
if isempty(datahandle) | ~ishandle(datahandle)
  return;
end

% Check for malformed data
ydata = get(datahandle,'ydata');
xdata = get(datahandle,'xdata');
xdata_fit = get(hThis,'xdata');
ydata_fit = get(hThis,'ydata');
if isempty(xdata) | isempty(ydata)
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate code: "xdata = get(datahandle,'xdata');"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hFunc = codegen.codefunction('Name','get','CodeRef',hCode);

% Output arguments
hArgout = codegen.codeargument('Value',xdata);
addArgout(hFunc,hArgout);

% Input arguments
hArgin = codegen.codeargument('IsParameter',true,'Value',datahandle);
addArgin(hFunc,hArgin);
hArgin = codegen.codeargument('Value','xdata');
addArgin(hFunc,hArgin);
addPreConstructorFunction(hCode,hFunc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate code:  [p] = polyfit(xdata,ydata,order);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hFunc = codegen.codefunction('Name','polyfit','CodeRef',hCode);
addPreConstructorFunction(hCode,hFunc);

% Output arguments
hArgout = codegen.codeargument('IsOutputArgument',true,...
                               'IsParameter',true,...
                               'Name','p');
addArgout(hFunc,hArgout);

% Input arguments
hArgin = codegen.codeargument('Value',xdata,...
                              'IsParameter',true,...
                              'Name','xdata');
addArgin(hFunc,hArgin);
hArgin = codegen.codeargument('Name','ydata',...
                              'Value',ydata,...
                              'IsParameter',true);
addArgin(hFunc,hArgin);
hArgin = codegen.codeargument('Value',n_order);
addArgin(hFunc,hArgin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate code: "xdata_fit = linspace(x1,x2,N);" 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x1 = xdata_fit(1);
x2 = xdata_fit(end);
N = length(xdata_fit); 
xdata_fit = get(hThis,'xdata');
hFunc = codegen.codefunction('Name','linspace','CodeRef',hCode);

% Output arguments
hArgout = codegen.codeargument('IsOutputArgument',true,...
                               'Name','xdata_fit',...
                               'Value',xdata_fit);
addArgout(hFunc,hArgout);

% Input arguments
hArgin = codegen.codeargument('Value',x1);
addArgin(hFunc,hArgin);
hArgin = codegen.codeargument('Value',x2);
addArgin(hFunc,hArgin);
hArgin = codegen.codeargument('Value',N);
addArgin(hFunc,hArgin);
addPreConstructorFunction(hCode,hFunc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate code:  ydata_fit = polyval(p,xdata_fit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hFunc = codegen.codefunction('Name','polyval','CodeRef',hCode);
addPreConstructorFunction(hCode,hFunc);

% Output arguments
hArgout = codegen.codeargument('IsOutputArgument',true,...
                               'Value',ydata_fit,...
                               'Name','ydata_fit');
addArgout(hFunc,hArgout);

% Input arguments
hArgin = codegen.codeargument('IsParameter',true,'Name','p');
addArgin(hFunc,hArgin);
xdata_fit_hArgin = codegen.codeargument('Name','xdata_fit',...
                                        'Value',xdata_fit,...
                                        'IsParameter',true);
addArgin(hFunc,xdata_fit_hArgin);


%%%%%%%%%%%%%%%%$%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate code:  plot(xdata_fit,ydata_fit);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setConstructorName(hCode,'plot');

% Input arguments
hArgin = codegen.codeargument('IsParameter',true,'Value',xdata_fit);
addConstructorArgin(hCode,xdata_fit_hArgin);
hArgin = codegen.codeargument('IsParameter',true,'Value',ydata_fit);
addConstructorArgin(hCode,hArgin);

% 'color',...
hArgin = codegen.codeargument('Value','Color');
addConstructorArgin(hCode,hArgin);
hArgin = codegen.codeargument('Value',get(hThis,'Color'));
addConstructorArgin(hCode,hArgin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [datahandle] = localGetDataHandle(hAxes)
% Get datahandle, the handle to the line representing the original 
% data.
% TODO: For now infer datahandle by getting all lines and finding 
% line with 'Basic_Fit_Handles' application data. A more elegant 
% approach is needed.
hAllLines = findall(hAxes,'type','line');
n_lines = length(hAllLines);
datahandle = [];
for n = 1:n_lines
   if isappdata(hAllLines(n),'Basic_Fit_Handles');
       datahandle = hAllLines(n);
   end
end


