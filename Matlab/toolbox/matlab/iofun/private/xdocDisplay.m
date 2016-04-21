function display( obj,indent,stream )

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:40 $
% Copyright 1984-2003 The MathWorks, Inc.

if(nargin < 3)
    stream = 1;
    if(nargin < 2)
        indent = '';
    end
end

% open the tag
fprintf(stream,'%s<%s',indent,obj.tag);

% print attributes
for i = 1:length(obj.attributes)
    k = obj.attributes{i};
    fprintf(stream,' %s="%s"',k{1},k{2});
end

if(isempty(obj.children) && isempty(obj.contents))
    %close the tag
    fprintf(stream,'/>\n',obj.tag);
else
    fprintf(stream,'>\n',obj.tag);
    
    for i = 1:length(obj.contents)
        content = obj.contents{i};
        fprintf(stream,'%s%s\n',[indent, '     '],content);
    end
    
    %or display the children
    for i = 1:length(obj.children)
        child = obj.children{i};
        display(child,[indent, '     '],stream);
    end
    %and close the tag
    fprintf(stream,'%s</%s>\n',indent,obj.tag);
end