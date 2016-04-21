function nn = deref(pp,index)
%DEREF Dereference a pointer object
%  O = DEREF(PP) Dereferences the pointer object PP, and constructs and returns 
%  a referent object O. PP must be a scalar.
%
%  O = DEREF(PP,INDEX) Dereferences an element of the multi-dimensional pointer object PP. 
%  The element dereferenced is given by INDEX.
%
%  Note: If the object PP points to 'void', DEREF will throw an error. If
%  this occurrs, convert the void pointer into a valid pointer using the
%  CONVERT or CAST method.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.18.6.3 $  $Date: 2004/04/08 20:46:44 $

error(nargchk(1,2,nargin));
if ~ishandle(pp)
    error('First Parameter must be a POINTER handle');
end
if nargin==1 
    if prod(pp.size)==1,    index = ones(1,length(pp.size));
    else  error('You must provide the index of the pointer element you want to dereference. ');
    end
else
    p_checkerforindex(pp,index,'Second Parameter');
end

% si - info structure from CC.LIST method
si = pp.referent;
if ~isfield(si,'uclass') && strcmp(si.type,'function'),
    si.uclass = 'function';
    setprop(pp,'referent',si);
end

% Check if referent non-function void
CheckReferentIfVoid(si);

% address
si.address = GetAddress(pp,index);

% If referent is STRUCTURE, add 'address' info
si = GetStructureAddress(pp,si);

si = parser_wrapper(pp.link,si);

% Create object
nn = createobj(pp.link,si);

%-------------------------------------
function si = GetStructureAddress(pp,si)

if ~strcmpi(si.uclass,'structure'), 
    return; 
end

member_list = fieldnames(si.members);
for i=1:length(member_list)
    member = si.members.(member_list{i});
    if ~pp.isrecursive,
        % add address property for each STRUCT member
        si.members.(member_list{i}).address = [si.address(1)+member.offset, si.address(2)];
    else
        % set to correct address property for each STRUCT member
        si.members.(member_list{i}).address = [si.address(1)+member.offset, si.address(2)];
    end
end

% --------------------------------
function page = GetPage(pp)

if any(strcmp(pp.procsubfamily,{'C6x','R1x','R2x'}))
    page = 0; % page does not matter
elseif any(strcmp(pp.procsubfamily,{'C54x','C55x','C28x'}))
    if strcmp(pp.referent.uclass,'function')
        page = 0; % program page
    else
        page = 1; % data page
    end
end

%--------------------------------
function addr = GetAddress(pp,index)
if strcmp(pp.referent.uclass,'function'),
    addr = struct(  'start',    [read(pp,index) GetPage(pp)], ...
                    'end',      []);
else
    addr = [read(pp,index) GetPage(pp)];
end

%-------------------------------------
function CheckReferentIfVoid(si)
if isfield(si,'type') && strcmp(si.type,'void') 
    if isfield(si,'uclass') && strcmp(si.uclass,'function')
        return;
    end
    error('Cannot dereference a pointer to void. Use CONVERT to change the pointer to a valid pointer type then call DEREF. ');
end

% [EOF] deref.m 