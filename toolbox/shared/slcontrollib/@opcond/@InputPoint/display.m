function display(this);
%Display method for the input constraint object.

%  Author(s): John Glass
%  Copyright 1986-2002 The MathWorks, Inc.

for ct1 = 1:length(this)
    %% Display the block    
    Block = regexprep(this(ct1).Block,'\n',' ');
    str1 = sprintf('hilite_system(''%s'',''find'');',Block);
    str2 = 'pause(1);';
    str3 = sprintf('hilite_system(''%s'',''none'');',Block);
    if usejava('Swing') && desktop('-inuse')
        str1 = sprintf('<a href="matlab:%s%s%s">%s</a>',str1,str2,str3,Block);
    else
        str1 = sprintf('%s',Block);
    end
    disp(sprintf('(%d.) %s',ct1,str1))
    
    for ct2 = 1:this(ct1).PortWidth
        Value = sprintf('%0.3g',this(ct1).u(ct2));
        Value = LocalPadValue(Value,13);
        disp(sprintf('      u: %s', Value));
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Local function to pad the value string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Value = LocalPadValue(Value,nels)

if numel(Value) < nels
    Value = [Value,repmat(' ',1,nels-numel(Value))];
end