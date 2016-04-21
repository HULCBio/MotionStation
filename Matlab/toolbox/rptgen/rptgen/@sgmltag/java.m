function j=java(t,d)
%JAVA converts an SGMLTAG object to a java XML DOM object
%     XDOM=JAVA(T) where T is the SGMLTAG object.
%     XDOM=JAVA(T,DOC) where DOC is the parent document of the
%          resulting XML DOM object.  

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:36 $

if nargin<2
    d=get(rptgen.appdata_rg,'CurrentDocument');
end

if ~isempty(t.tag)
    j = d.createElement(lower(t.tag));
    %@NOTE: the "lower" on t.tag is docbook specific.  DocBook XML uses all lower-case
    %tag names
    if (~t.opt(1)) %indent
        j.setAttribute('xml:space','preserve');
    end
    for i=1:size(t.att,1)
        j.setAttribute(lower(t.att{i,1}),rg('tostring',t.att{i,2},0));        
        %@NOTE: the "lower" on t.tag is docbook specific.  DocBook XML uses all lower-case
    end
else
    j = d.createDocumentFragment;
end

%@BUG: is there any way to honor the isSgmlTag option?

if iscell(t.data)
    tagData=t.data(:);
    for i=1:length(tagData)
        appendData(j,tagData{i},d);
        appendData(j,d.createTextNode(char(10)));
    end
else
    appendData(j,t.data,d);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function appendData(j,elData,d)

if isa(elData,'sgmltag')
    j.appendChild(java(elData,d));
elseif isa(elData,'org.w3c.dom.Node')
    j.appendChild(elData);
else
    %This is the same logic found in rpt_xml.document/makeNode
    s=rg('tostring',elData,inf);
    t=d.createTextNode(s);
    
    if ~isempty(findstr(s,char(10)))
        n=d.createElement('programlisting');
        n.appendChild(t);
        n.setAttribute('xml:space','preserve');
        j.appendChild(n);
    else
        j.appendChild(t);
    end
end
