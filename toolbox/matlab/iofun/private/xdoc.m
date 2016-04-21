function obj = xdoc( string )

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:39 $
% Copyright 1984-2003 The MathWorks, Inc.

obj.tag = string;
obj.attributes = {};
obj.children = {};
obj.contents = {};
%obj = class(obj,'xdoc');

% TODO: The parser can't handle single quotes.  This "solution" is a hack.
string = strrep(string,'''','"');

% what follows is a very simple XML parser...
position = 1;
position = skipWhite(position,string);
if(string(position) == '<') % THIS IS A STREAM NOT A TAG!!!
    stack = cell(100,1); % xml more that 100 deep will fail
    sp = 1; % stack pointer
    
    toplevelElementsFound = 0;
    position = 1;
    position = skipWhite(position,string);
    while(position < length(string))
        [tag,position] = getNextTag(string,position);
        switch(tag.type)
            case 'OPEN' % make a xdoc and push it on the stack.
                
                % tags like: <? anything you like ?>  are ignored...
                if(strcmp(tag.name,'?'))
                    continue;
                end
                
                obj = xdoc(tag.name);
                obj = applyAttributes(obj,tag);
                stack{sp} = obj; sp = sp + 1; %push
            case 'COMPLETE' % make a finished xdoc and add it to obj on stack
                obj = xdoc(tag.name);
                obj = applyAttributes(obj,tag);
                if(sp > 1)
                    stack{sp-1} = addChild(stack{sp-1},obj);
                end
            case 'CLOSE' % 
                obj = stack{sp-1}; sp = sp - 1; % pop
                if(sp > 1)
                    stack{sp-1} = addChild(stack{sp-1},obj);
                end
            case 'BETWEENTAGS'
                stack{sp-1} = addContents(stack{sp-1},tag.contents);
        end
        position = skipWhite(position,string);
        
        % check for multiple top level elements.
        if(sp == 1) % is the stack empty?
            toplevelElementsFound = toplevelElementsFound + 1;
            if(toplevelElementsFound == 2)
                error('This was not a well formed XML string, it contains more that one top-level element.');
            end
        end
        
    end
end


function obj= applyAttributes(obj,tag)
position = 1;
string = tag.contents;
while(position < length(string))
    position = skipWhite(position,string);
    
    nameStart = position;
    position = lookFor(string,position,'=');
    name = string(nameStart:(position-1));
    
    position = lookFor(string,position,'"');
    position = position + 1;
    
    valueStart = position;
    position = lookFor(string,position,'"');
    value = string(valueStart:(position-1));
    
    position = position + 1;
    obj = addAttribute(obj,name,value);
end

function position = lookFor(string,position,pattern)
while((position <= length(string)) && ~any(string(position) == pattern))
    position = position + 1;
end

function position = skipWhite(position,string)
while((position <= length(string)) && any(string(position) == [ 10 13 32 ]))
    position = position + 1;
end

% return the next tag in the stream
% it will be of type OPEN, CLOSE, or COMPLETE 
function [tag,position] = getNextTag(string,position)
tag.type = 'OPEN';
if('<' ~= string(position))
    tag.type = 'BETWEENTAGS';
    contentsStart = position;
    position = lookFor(string,position,'<');
    tag.contents = string(contentsStart:(position - 1));
else
    position = position + 1;
    position = skipWhite(position,string);
    if('/' == string(position))
        tag.type = 'CLOSE';
        position = position + 1;
    end
    nameStart = position;
    position = lookFor(string,position,[10 13 32 '/' '>']);
    tag.name = string(nameStart:(position - 1));
    contentsStart = position;
    position = lookFor(string,position,'>');
    if('/' == string(position-1))
        tag.type = 'COMPLETE';
        tag.contents = string(contentsStart:(position - 2));
    else
        tag.contents = string(contentsStart:(position - 1));
    end
    position = position + 1;
end


















