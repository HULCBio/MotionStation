function out=rendervariable(c,v,forceinline,cellLimit,titleString,isExtract);
%RENDERVARIABLE Converts a MATLAB variable to XML source
%   S=RENDERVARIABLE(R,V,I,L,T,E)
%    S is the XML output
%
%    R is an RPTCOMPONENT object
%
%    V is a MATLAB variable or workspace variable name (see "E")
%
%    I forces the output to be an inline string if value is 1.
%      allows output to be a table if value is 0
%      optional, default=logical(1)
%
%    L is a factor which defines a multiplier for maximum number of elements
%      an array must have before it is rendered as [MxN CLASSNAME]
%      Each datatype has its own number of elements which may be tolerated
%      before the render is downgraded.  If L is zero, output will not
%      be downgraded regardless of array size.
%      optional, default=32
%
%    T is the variable title.  If a table is created, T is the table 
%      title.
%      optional, default=''
%  
%    E is a boolean value, if true it indicates that the rendered
%      variable will be extracted from the workspace.  If E is true,
%      V should be a string with the name of the variable to be extracted.
%      optional, default=logical(0)
% 

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:14 $

if nargin<6
    isExtract=0;
    if nargin<5
        titleString='';
        if nargin<4
            cellLimit=32;
            if nargin<3
                forceinline=logical(1);
            end
        end
    end
elseif isExtract
    %'v' was passed in as a string indicating a variable name
    %in the workspace.  Extract it.
    if isempty(v)
        out='';
        return
    else
        try
            v=evalin('base',v);
        catch
            out=sprintf('<%s not found>',v);
            return;
        end
    end   
end

out=LocRender(v,forceinline,cellLimit,titleString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocRender(v,forceinline,cellLimit,titleString);
%the default cellLimit for the insert variable component is 32

switch class(v)
case 'sgmltag'
    out=v;
case 'char'
    if limitCheck(v,cellLimit*20,0) %do not use hypotenuse method
        out=[ '[' LocSizeString(size(v),logical(0))  'char]' ];
    elseif min(size(v))>1
        %we need vector strings only
        out=singlelinetext(rptparent,v,sprintf('\n'));
    else
        out=v;
    end
case { %handle numeric data
    'double'
    'single'
    'uint8'
    'uint16'
    'uint32'
    'uint64'
    'int8'
    'int16'
    'int32'
    'int64'
    }
    
    out=LocRenderTable(double(v),forceinline,cellLimit,titleString,class(v));
case 'sparse'
    out=LocRenderTable(v,forceinline,cellLimit,titleString,'sparse');
case 'cell'
    out=LocRenderTable(v,forceinline,.75*cellLimit,titleString,'cell array');
case 'struct'
    out=LocRenderStruct(v,forceinline,cellLimit,titleString,'struct');
otherwise %custom object
    try
        structV=struct(v);
        ok=1;
    catch
        ok=0;
    end
    
    if ok
        out=LocRenderStruct(structV,forceinline,cellLimit,titleString,class(v));
    else
        out=[ '[' LocSizeString(size(v),logical(1)) class(v) ']' ];   
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocRenderStruct(v,isInline,cellLimit,titleString,objType)

sz=size(v);
if isInline | length(sz)>2 | min(sz)>1 | limitCheck(v,cellLimit,1*32)
    %construct list of fieldnames
    f=fieldnames(v);
    if length(f)>8
        f=f(1:8);
        f{8}='...';
        endStr='s: ';
    elseif length(f)<2
        endStr=': ';
    else
        endStr='s: ';
    end
    
    out=['[' LocSizeString(size(v),logical(1)) ...
            objType,' w/ field' endStr  ...
            singlelinetext(rptparent,f,', ') ']' ];
else
    fNames=fieldnames(v);
    nFields=length(fNames);
    nStruct=max(sz);
    if nStruct==1
        nHR=0;
        tCells=cell(0,2);
        cWid=[.3 .7];
    else
        nHR=1;
        tCells=[{'field'} num2cell(1:1:nStruct)];
        cWid=[.3 ones(1,nStruct)*(1-.3)/nStruct];
    end
    
    for i=length(fNames):-1:1
        currField=fNames{i};
        for j=nStruct:-1:1
            tCells{i+nHR,j+1}=LocRender(getfield(v(j),currField),...
                logical(1),...
                .66*cellLimit,...
                '');
        end
        tCells{i+nHR}=currField;
    end
    
    tableComp=subsref(rptcomponent,...
        substruct('.','comps','.','cfrcelltable'));
    
    tableComp.att.TableTitle=titleString;
    tableComp.att.TableCells=tCells;
    tableComp.att.numHeaderRows=nHR;
    tableComp.att.ColumnWidths=cWid;
    
    out=runcomponent(tableComp,0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocRenderTable(v,forceinline,cellLimit,titleString,arrayType);

sz=size(v);

if iscell(v)
    cellType=1;
    brackets='{}';
else
    cellType=0;
    brackets='[]';
end

if ~cellType & max(sz)==1
    out = sprintf('%g',v);
elseif forceinline
    if min(sz)==0
        out=brackets;
    elseif length(sz)>2 | limitCheck(v,cellLimit,logical(0))
        out=[ '[' LocSizeString(sz,logical(0))  arrayType ']' ];
    else  %if not expanding
        if cellType
            out=[brackets(1) ' '];
            for i=1:sz(1)
                for j=1:sz(2)
                    if cellType
                        out=[out LocRender(v{i,j},logical(1),...
                                .5*cellLimit,'') ' '];
                    else
                        out=sprintf('%s %g',out,v(i,j));
                    end
                end %for columns
                if i<sz(1)
                    out=[out ';' char(13)];
                else
                    out=[out brackets(2)];
                end
            end %for rows
        else
            %if the result is numeric
            out=num2str(v);
            
            blankColumn=blanks(size(out,1))';
            
            semicolonColumn=';';
            semicolonColumn=semicolonColumn(ones(size(out,1),1));

            out=[blankColumn,out,semicolonColumn];
            out(1,1)     = brackets(1);
            out(end,end) = brackets(2);
            %make sure that out is single-line for concatenating w/ others
            out=out';
            out=[out(:)]';
        end %is cellType
    end %if isempty
else %not force inline
    if min(sz)==0 | limitCheck(v,cellLimit)
        out=[ '[' LocSizeString(sz,logical(0))  arrayType ']' ];
    else
        if cellType
            for i=1:sz(1)
                for j=1:sz(2)
                    if cellType
                        v{i,j}=LocRender(v{i,j},logical(1),...
                            .66*cellLimit,'');
                    end
                end
            end
        else
            v=num2cell(v);
        end
        
        tableComp=subsref(rptcomponent,...
            substruct('.','comps','.','cfrcelltable'));
        
        tableComp.att.TableTitle=titleString;
        tableComp.att.TableCells=v;
        tableComp.att.numHeaderRows=0;
        tableComp.att.isPgwide=logical(0);
        
        out=runcomponent(tableComp,0);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function szString=LocSizeString(sz,isMinimize);
%LocSizeString accepts a size vector (i.e. the output from size(v))
%and renders it as AxBxC
%isMinimize renders szString as empty if sz==[1 1]

szString='';

szLength=length(sz);
if isMinimize & szLength<3 & max(sz)==1
    %do nothing
else
    for i=1:szLength-1
        szString=[szString num2str(sz(i)) 'x'];
    end   
    szString=[szString num2str(sz(end)) ' '];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tooLarge=limitCheck(v,cellLimit,isHypotenuse)
%ISHYPOTENUSE checks to see if the HYPOTENUSE of the matrix size
%is greater than the imposed limit.  We use hypotenuse
%because a 32x32 matrix might be reasonable but a 1024
%element vector is not.  This calculation only sort of
%works for 3-d and greater elements.
%
%If not using the hypotenuse method, limitCheck looks at the
%number of elements in the matrix to see if they are larger
%than the cell limit.

if cellLimit==0
    tooLarge=logical(0);
else
    if nargin<3
        isHypotenuse=1;
    end
    
    sv=size(v);
    if sum(sv)==1  %1x1 will never be too large
        tooLarge=logical(0);
    elseif isHypotenuse
        tooLarge=(sqrt(sum(sv.^2))>cellLimit);
    else
        tooLarge=(prod(sv)>cellLimit);
    end
end