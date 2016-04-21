function name = createClassFromWsdl(wsdl)
% createClassFromWsdl

% Matthew J. Simoneau, June 2003
% $Revision: 1.1.6.2 $  $Date: 2003/09/24 23:34:19 $
% Copyright 1984-2003 The MathWorks, Inc.

R = parseWsdl(wsdl);
R.name = makeLegal(R.name);
% TODO: Debugging with mixed case is broken.  Remove when that's fixed.
R.name = lower(R.name);

% Create the constructor and methods
makeconstructor(R)
makemethods(R)
rehash path

name = R.name;


%===============================================================================
function struct = parseWsdl(wsdlUrl)
if nargin < 1
    wsdlUrl = 'AddressBook.wsdl';
end

wsdlReader = javax.wsdl.factory.WSDLFactory.newInstance.newWSDLReader;
% Catch "Retrieving document at ..." text that the reader spits out.
evalc('definition = wsdlReader.readWSDL(wsdlUrl);');

% Extract namespaces.
namespaces = [];
ns = definition.getNamespaces;
iterator = ns.keySet.iterator;
while iterator.hasNext
    key = iterator.next;
    namespaces(end+1).key = char(key);
    namespaces(end).value = char(ns.get(java.lang.String(key)));
end

% TODO: Parse input types.
% types = typesToStruct(definition,namespaces);
types = [];

services = definition.getServices;
if (services.size ~= 1)
    error('More than one service defined?') %TODO is this allowed?
end
service = services.entrySet.iterator.next.getValue;

struct = [];
bindings = definition.getBindings;
keyIterator = bindings.keySet.iterator;
while keyIterator.hasNext
    bindingKey = keyIterator.next;
    binding = bindings.get(bindingKey);
    portType = binding.getPortType;
    bindingOperations = binding.getBindingOperations;
    op = [];
    for iBindingOperations = 1:bindingOperations.size
        bindingOperation = bindingOperations.get(iBindingOperations-1);
        
        % Make sure this is a SOAP operation.
        soapAction = '';
        operationExtensibilityIterator = ...
            bindingOperation.getExtensibilityElements.iterator;
        while (operationExtensibilityIterator.hasNext)
            obj = operationExtensibilityIterator.next;
            if isa(obj,'javax.wsdl.extensions.soap.SOAPOperation')
                soapAction = obj.getSoapActionURI;
                break;
            end
        end
        if isempty(soapAction)
            disp('Not SOAP.  Unsupported.')
        else
            operation = bindingOperation.getOperation;
            style = operation.getStyle;
            if (style == javax.wsdl.OperationType.NOTIFICATION) || ...
                    (style == javax.wsdl.OperationType.SOLICIT_RESPONSE)
                disp('Unsupported style.')
            else
                % style == REQUEST_RESPONSE, others?
                nextOp = bindingOperationToStruct(bindingOperation);
                if isempty(nextOp.targetNamespaceURI)
                    nextOp.targetNamespaceURI = ...
                        char(definition.getTargetNamespace);
                end
                op = [op nextOp];
            end
        end
    end
    if ~isempty(op)
        struct(end+1).name = char(service.getQName.getLocalPart);
        struct(end).wsdlLocation = wsdlUrl;
        struct(end).endpoint = char(service.getPorts.entrySet.iterator.next.getValue.getExtensibilityElements.get(0).getLocationURI);
        struct(end).methods = op;
        struct(end).types = types;
    end
end

% services = definition.getServices;
% if (services.size ~= 1)
%     error('More than one service defined?') %TODO is this allowed?
% end
% 
% service = services.entrySet.iterator.next.getValue;
% struct.name = char(service.getQName.getLocalPart);
% struct.wsdlLocation = wsdlUrl;
% 
% ports = service.getPorts;
% 
% portKeyIterator = ports.keySet.iterator;
% for portKeyNum = 1:ports.size
%     portKey = portKeyIterator.next;
%     port = ports.get(portKey);
%     if isSoapPort(port)
%         struct.endpoint = char(port.getExtensibilityElements.firstElement.getLocationURI);
%         op = [];
%         %port.getBinding.getPortType.getOperations.iterator
%         bindingOperations = port.getBinding.getBindingOperations;
%         for bindingOperationNum = 1:bindingOperations.size
%             bindingOperation = ...
%                 bindingOperations.elementAt(bindingOperationNum-1);
%             op = [op bindingOperationToStruct(bindingOperation)];
%         end
%         struct.methods = op;
%     end
% end

%===============================================================================
function isSoap = isSoapPort(port)
% TODO: Check to see if this port has something that makes it SOAP.
soapAddress = 'http://schemas.xmlsoap.org/wsdl/soap/:address';
extensibilityElements = port.getExtensibilityElements;
isSoap = false;
for extensibilityElementNum = 1:extensibilityElements.size
    extensibilityElement = extensibilityElements.elementAt(extensibilityElementNum-1);
    elementTypeChar = char(extensibilityElement.getElementType.toString);
    if isequal(elementTypeChar,soapAddress)
        isSoap = true;
        break
    end
end

%===============================================================================
function struct = bindingOperationToStruct(bindingOperation)
struct.methodName = char(bindingOperation.getName);
struct.docmentation = bindingOperation.getDocumentationElement; %TODO: use this
inputExtensibilityElements = ...
    bindingOperation.getBindingInput.getExtensibilityElements;
struct.targetNamespaceURI = ...
    char(inputExtensibilityElements.firstElement.getNamespaceURI);
operation = bindingOperation.getOperation;
struct.input = messageToStruct(operation.getInput.getMessage);
if isempty(struct.input)
    struct.inputNames = {};
    struct.inputTypes = {};
else
    struct.inputNames = {struct.input.name}';
    struct.inputTypes = {struct.input.type}';
end
struct.output = messageToStruct(operation.getOutput.getMessage);
if isempty(struct.output)
    struct.outputNames = {};
    struct.outputTypes = {};
else
    struct.outputNames = {struct.output.name}';
    struct.outputTypes = {struct.output.type}';
end
soapOperation = bindingOperation.getExtensibilityElements.firstElement;
struct.soapAction = char(soapOperation.getSoapActionURI);


%===============================================================================
function struct = messageToStruct(message)
partList = message.getOrderedParts([]);
struct = [];
for iPart = 1:partList.size
    part = partList.get(iPart-1);
    s.name = char(part.getName);
    if isempty(part.getTypeName)
        s.type = char(part.getElementName.toString);
    else
        s.type = char(part.getTypeName.toString);
    end
    struct = [struct s];
end




%===============================================================================
function s = typesToStruct(definition,namespaces)

s = [];

xmlSchema = 'http://www.w3.org/2001/XMLSchema';

types = definition.getTypes;
schemaElement = types.getExtensibilityElements.elementAt(0).getElement;
childNodes = schemaElement.getChildNodes;
for i = 1:childNodes.getLength
    node = childNodes.item(i-1);
    nodeName = char(node.getNodeName);
    if isequal(nodeName,'#text')
        % Do nothing.
    else
        type = char(node.getLocalName);
        name = char(node.getAttribute('name'));
        switch type
            case 'simpleType'
                restriction = node.getElementsByTagNameNS(xmlSchema,'restriction').item(0);
                if isempty(restriction)
                    %TODO.
                else
                    t = char(restriction.getAttribute('base'));
                    s.(name) = reduceNs(t,namespaces);
                end
            case 'complexType'
                % Complex type.
                sequenceNode = node.getElementsByTagNameNS(xmlSchema,'sequence').item(0);
                elements = node.getElementsByTagNameNS(xmlSchema,'element');
                for j = 1:elements.getLength
                    n = char(elements.item(j-1).getAttribute('name'));
                    t = char(elements.item(j-1).getAttribute('type'));
                    s.(name).(n) = reduceNs(t,namespaces);
                end
            case 'element'
                complexTypeNode = node.getElementsByTagNameNS(xmlSchema,'complexType').item(0);
                if isempty(complexTypeNode)
                    %TODO nilable?
                else
                    % Complex type.
                    sequenceNode = node.getElementsByTagNameNS(xmlSchema,'sequence').item(0);
                    elements = node.getElementsByTagNameNS(xmlSchema,'element');
                    for j = 1:elements.getLength
                        n = char(elements.item(j-1).getAttribute('name'));
                        t = char(elements.item(j-1).getAttribute('type'));
                        s.(name).(n) = reduceNs(t,namespaces);
                    end
                end
        end
    end
end


%===============================================================================
function s = reduceNs(s,namespaces)
splitter = find(s == ':');
if isempty(splitter)
    error
end
ns = s(1:splitter-1);
rest = s(splitter+1:end);
match = strmatch(ns,{namespaces.key},'exact');
if isempty(match)
    error
end
s = ['{' namespaces(match).value '}' rest];




%===============================================================================
%===============================================================================
function makeconstructor(R)
% Create a constructure from a structure derived from a WSDL
tf = fullfile(fileparts(mfilename('fullpath')),'private','constructor.mtl');
template = textread(tf,'%s','delimiter','\n','whitespace','');

replacements = {'$CLASSNAME$',R.name,'$ENDPOINT$', ...
    R.endpoint,'$WSDLLOCATION$',R.wsdlLocation};
for i = 1:2:length(replacements)
    template = strrep(template,replacements{i},replacements{i+1});
end

[succ mess mid] = rmdir(['@' R.name],'s');
mkdir(['@' R.name])

writemfile(['@' R.name filesep R.name '.m'],template);

% Also create a display method
C = {'function display(obj)','disp(struct(obj))'};
writemfile(['@' R.name filesep 'display.m'],C);


%===============================================================================
function makemethods(R)
% Creates the methods for the WSDL described by R

% Read in the template.
tf = fullfile(fileparts(mfilename('fullpath')),'private','genericmethod.mtl');
originalTemplate = textread(tf,'%s','delimiter','\n','whitespace','');

methods = R.methods;
for method = methods
    
    legalOutputNames = makeLegal(method.outputNames);
    switch length(legalOutputNames)
        case 0
            outputString = '';
        case 1
            outputString = sprintf('%s = ',legalOutputNames{1});
        otherwise
            outputString = sprintf('%s,',legalOutputNames{:});
            outputString(end) = [];
    end

    legalInputNames = makeLegal(method.inputNames);
    switch length(legalInputNames)
        case 0
            inputString = '(obj)';
        case 1
            inputString = sprintf('(obj,%s)',legalInputNames{1});
        otherwise
            inputString = sprintf('%s,',legalInputNames{:});
            inputString(end) = [];
            inputString = sprintf('(obj,%s)',inputString);
    end

%     % Write out the parameter name, input name, and type mapping.
%     s = sprintf('parameters = { ...\n');
%     for i = 1:length(method.inputNames)
%         s = sprintf('%s   ''%s'',%s,''%s'', ...\n', ...
%             s, ...
%             method.inputNames{i}, ...
%             legalInputNames{i}, ...
%             method.inputTypes{i});
%     end
%     parameterDefinition = sprintf('\n%s   };',s);

    % Write out the parameter name, input name, and type mapping.
    s = sprintf('values = { ...\n');
    for i = 1:length(method.inputNames)
        s = sprintf('%s   %s, ...\n', ...
            s, ...
            legalInputNames{i});
    end
    s = sprintf('%s   };\n',s);
    s = sprintf('%snames = { ...\n',s);
    for i = 1:length(method.inputNames)
        s = sprintf('%s   ''%s'', ...\n', ...
            s, ...
            method.inputNames{i});
    end
    s = sprintf('%s   };\n',s);
    s = sprintf('%stypes = { ...\n',s);
    for i = 1:length(method.inputNames)
        s = sprintf('%s   ''%s'', ...\n', ...
            s, ...
            method.inputTypes{i});
    end
    parameterDefinition = sprintf('%s   };',s);

    replacements = {'$METHODNAME$',method.methodName,...
        '$TARGETNAMESPACEURI$',method.targetNamespaceURI,...
        '$SOAPACTION$',method.soapAction,...
        '$OUTPUT$',outputString,...
        '$INPUT$',inputString, ...
        '$PARAMETERDEFINITION$',parameterDefinition,};
    template = originalTemplate;
    for i = 1:2:length(replacements)
        template = strrep(template,replacements{i},char(replacements{i+1}));
    end
    writemfile(['@' R.name filesep method.methodName '.m'],template);
end


%===============================================================================
function status = writemfile(fname,C)
% Write a cell to file

C = cellstr(C);
count = 0;
fid = fopen([pwd filesep lower(fname)],'w');
for i = 1:length(C);
    count = count + fprintf(fid,'%s\n',C{i});
end
status = fclose(fid);
if (count~=(sum(cellfun('length',C))+length(C))) || (status==-1)
    error(['Error writing file ' fname])
end

%===============================================================================
function names = makeLegal(names)
if ischar(names)
    names = {names};
    unroll = true;
else
    unroll = false;
end
for i = 1:length(names)
    name = names{i};
    name = name(max([0 find(name == '.')])+1:end);
    switch name
        case 'return'
            name = 'return_';
    end
    names{i} = name;
end
if unroll
    names = names{1};
end
