function display(this,varargin);
%Display method for the StateReport object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/19 01:31:16 $

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
    
    for ct2 = 1:length(this(ct1).x)
        xValue = sprintf('%0.3g',this(ct1).x(ct2));
        xValue = LocalPadValue(xValue,13);
        dxValue = sprintf('%0.3g',this(ct1).dx(ct2));
        dxValue = LocalPadValue(dxValue,13);
        
        if this(ct1).SteadyState(ct2)
            disp(sprintf('      x: %s      dx: %s (0)', xValue, dxValue));
        else
            disp(sprintf('      x: %s      dx: %s', xValue, dxValue));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Local function to pad the value string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Value = LocalPadValue(Value,nels)

if numel(Value) < nels
    Value = [repmat(' ',1,nels-numel(Value)),Value];
end
