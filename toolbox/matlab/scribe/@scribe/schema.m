function schema
%creates the scribe user object package

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/10 23:30:51 $

schema.package('scribe');
if isempty(findtype('ScribeShapeType'))
    schema.EnumType('ScribeShapeType',...
        {'none','rectangle','square','ellipse','circle',...
        'arrow','textarrow','doublearrow','line','legend',...
        'colorbar','textbox','scribegrid'});
end

