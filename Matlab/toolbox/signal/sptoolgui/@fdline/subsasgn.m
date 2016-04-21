function obj = subsasgn(obj,s,rhs);
%SUBSASGN  Method for fdline object

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

if (isa(rhs,'fdline') & strcmp(s(1).type,'()'))
    rhs = struct(rhs);
    obj = struct(obj);
    obj(s(1).subs{:}) = rhs;
    obj = fdline(obj);
    return
elseif (isempty(rhs) & strcmp(s(1).type,'()') & length(s)==1)
    obj = struct(obj);
    obj(s(1).subs{:}) = [];
    obj = fdline(obj);
    return
end

if strcmp(s(1).type,'()')
    obj_subs = s(1).subs;
    s(1) = [];
else
    obj_subs = {};
    d = size(obj);
    obj_subs = cell(size(d));
    for i = 1:length(d)
        obj_subs{i} = ':';
    end
end

if length(s)>1
    error(['Sorry, can''t assign individual elements or fields of an' ...
           ' FDLINE''s properties.'])
end

switch s(1).type
case '.'
    set(obj(obj_subs{:}),s(1).subs,rhs);    
end

