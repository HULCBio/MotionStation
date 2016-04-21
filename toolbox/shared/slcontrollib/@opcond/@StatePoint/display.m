function display(this,varargin);
%% Display method for the StatePoint object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:26 $

for ct1 = 1:length(this)
    %% Be sure to remove returns and insert spaces
    StateName = regexprep(this(ct1).Block,'\n',' ');
    str1 = sprintf('hilite_system(''%s'',''find'');',StateName);
    str2 = 'pause(1);';
    str3 = sprintf('hilite_system(''%s'',''none'');',StateName);
    if usejava('Swing') && desktop('-inuse')
        str1 = sprintf('<a href="matlab:%s%s%s">%s</a>',str1,str2,str3,StateName);
    else
        str1 = sprintf('%s',StateName);
    end
    if (nargin == 2)
        disp(sprintf('(%d.) %s',varargin{1},str1))
    else
        disp(str1)
    end
    for ct2 = 1:this(ct1).Nx
        Value = sprintf('%0.3g',this(ct1).x(ct2));
        Value = LocalPadValue(Value,13);
        disp(sprintf('      x: %s', Value));
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Local function to pad the value string
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Value = LocalPadValue(Value,nels)

if numel(Value) < nels
    Value = [Value,repmat(' ',1,nels-numel(Value))];
end