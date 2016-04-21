function generateDefaultPropValueSyntax(hThis)

% Copyright 2003-2004 The MathWorks, Inc.

% Get handles
hFunc = getConstructor(hThis);
hMomento = get(hThis,'MomentoRef');
hObj = get(hMomento,'ObjectRef');
  
% Give this object a name if it doesn't 
% have one already
name = [];
if isempty(get(hThis,'Name'))
   hFunc = get(hThis,'Constructor');
   name = get(hFunc,'Name');
   if ~isempty(name)
      set(hThis,'Name',name); 
   end
end

% Add Input arguments
hPropList = get(hMomento,'PropertyObjects');
local_add_argin(hFunc,hPropList,name);

% Add Output argument
hArg = codegen.codeargument('Value',hObj,...
                            'Name',get(hFunc,'Name'));
addArgout(hFunc,hArg);

%----------------------------------------------------------%
function local_add_argin(hFunc,hPropList,name);
% Adds list of properties to be input arguments to the
% specified function. The syntax will be param-value
% pairs.

n_props = length(hPropList);
for n = 1:n_props
   hProp = hPropList(n);
   if ~get(hProp,'Ignore')
   
      % Create param argument
      val = get(hProp,'Name');
      hArg = codegen.codeargument('Value',val,'ArgumentType','PropertyName');
      addArgin(hFunc,hArg);     
      
      % Create value argument
      hArg = codegen.codeargument('ArgumentType','PropertyValue');
      set(hArg,'Name',get(hProp,'Name'));
      set(hArg,'Value',get(hProp,'Value'));
      set(hArg,'IsParameter',get(hProp,'IsParameter'));
      % This comment will appear in generated m-help
      if ~isempty(name)
         set(hArg,'Comment',[name,' ',get(hProp,'Name')]);
      end
      addArgin(hFunc,hArg);
   end
end


