function str = iterdisplay(this,x,optimValues)
% STR = ITERDISPLAY(THIS,X,OPTIMVALUES,STATE)

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:08:25 $

if ~isempty([this.F_dx(:);this.F_y(:)])
    [max_dx,ind_dx] = max(abs(this.F_dx));
    [max_y,ind_y] = max(abs(this.F_y));
    if ~isempty(max_dx) && (isempty(max_y) || (max_dx > max_y))
        block = this.StateConstraintBlocks{ind_dx};
        max_val = max_dx;
    else
        block = this.OutputConstraintBlocks{ind_y};
        max_val = max_y;
    end

    str1 = sprintf('hilite_system(''%s'',''find'');',block);
    str2 = 'pause(1);';
    str3 = sprintf('hilite_system(''%s'',''none'');',block);

    str1 = sprintf('<a href="matlab:%s%s%s">%s</a>',str1,str2,str3,block);
    str = {sprintf('(%0.5e) %s',max_val,str1)};
else
    str = {'There are no constraints to meet'};
end
