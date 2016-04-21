function po = parser_wrapper(cc,dtype)
% PARSER_WRAPPER (Private) Adds in missing info fields to 'dtype' that are required by 
% 'createobj' for constructing an object.
 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:07:28 $

po = dtype;
fnames = fieldnames(po);
if isempty(strmatch('uclass',fnames,'exact'))
    error('You need to supply the class (numeric, function, pointer, ...) of the input.');
end

switch po.uclass
case 'numeric'
    reqd_fnames = { 'name'      , ...
					'address'   , ...
					'size'      , ...  
                    'type' };
    % Info that createobj can determine: 
    %  'bitsperstorageunit' 
	%  'endianness'         
	%  'timeout'            
	%  'procsubfamily'
	%  'link'              
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultAddress(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultNumericType(po,fnames);
    
case 'pointer'
    reqd_fnames = { 'name'      , ...
                    'address'   , ...
                    'size'      , ...  
                    'reftype'   , ...               % pointer type (string)
                    'referent' };
	% Info that createobj can determine:
	%  'bitsperstorageunit'
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'storageunitspervalue'
	%  'isrecursive'         
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultAddress(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultPointerType(po,fnames);
    po = AssignDefaultReferent(po,fnames);
        
case 'enum'
    reqd_fnames = { 'name'      , ...
                    'address'   , ...
                    'size'      , ...  
                    'label'     , ...
	    		    'value'     };
	% Info that createobj can determine:
	%  'bitsperstorageunit'
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultAddress(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultLabelNValue(po,fnames);
    
case 'bitfield'
    reqd_fnames = { 'name'      , ...
                    'address'   , ...
                    'size'      , ...
                    'location'  , ...   % si.bitinfo
                    'type'      };
	% Info that createobj can determine:
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultAddress(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultNumericType(po,fnames);
    po = AssignDefaultBitInfo(po,fnames,cc.procsubfamily);
    
case 'string'
    reqd_fnames = { 'name'      , ...
                    'address'   , ...
                    'size'      };
	% Info that createobj can determine:
    %  'bitsperstorageunit'
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultAddress(po,fnames);
    po = AssignDefaultSize(po,fnames);

% REGISTER OBJECTS -------------------------------------------------

case 'rnumeric'
    reqd_fnames = { 'name'      , ...
                    'regname'   , ...
                    'regid'     , ...
                    'size'      , ...
                    'type'      };
	% Info that createobj can determine:
    %  'bitsperstorageunit'
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultNumericType(po,fnames);
    po = AssignDefaultRegisterInfo(po,fnames);
    
case 'rpointer'
    reqd_fnames = { 'name'      , ...
                    'regname'   , ...
                    'regid'     , ...
                    'size'      , ...  
                    'reftype'   , ...               % pointer type (string)
                    'referent' };
	% Info that createobj can determine:
	%  'bitsperstorageunit'
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'storageunitspervalue'
	%  'isrecursive'         
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultPointerType(po,fnames);
    po = AssignDefaultReferent(po,fnames);
    po = AssignDefaultRegisterInfo(po,fnames);
    
case 'renum' % (->rnumeric->registerobj)
    reqd_fnames = { 'name'      , ...
                    'regname'   , ...
                    'regid'     , ...
                    'size'      , ...  
                    'label'     , ...
	    		    'value'     };
	% Info that createobj can determine:
	%  'bitsperstorageunit'
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'link'                
    %  'storageunitspervalue'
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultLabelNValue(po,fnames);
    po = AssignDefaultRegisterInfo(po,fnames);

case 'rstring'
    reqd_fnames = { 'name'      , ...
                    'regname'   , ...
                    'regid'     , ...
                    'size'      };
	% Info that createobj can determine:
    %  'bitsperstorageunit'
	%  'endianness'        
	%  'timeout'           
	%  'procsubfamily'     
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultRegisterInfo(po,fnames);
    
% STRUCTURE OBJECT ---------------------------------------
                     
case 'structure'
    reqd_fnames = { 'name'      , ...
                    'address'   , ... % also used by containerobj
                    'members'   , ... % also used by containerobj
                    'size'      , ...
                    'sizeof'    , ...  % storageunitspervalue
                    };
	% Info that createobj can determine: 
    % 'member'
    % 'link'
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultAddress(po,fnames);
    po = AssignDefaultSize(po,fnames);
    po = AssignDefaultStructSizeInAus(po,fnames);
    po = AssignDefaultStructMembers(po,fnames);

% FUNCTION OBJECT ---------------------------------------

case 'function'
    reqd_fnames = { 'name'      , ...
                    'address'   , ...
                    'variables' , ... % funcvar
                    'filename'  , ...
                    'islibfunc' , ... % -1 if unknown - note: this will pass 'if' condition  
                    'uclass'    };
	% Info that createobj can determine:
	%  'timeout'           
	%  'procsubfamily'     
	%  'link'                
    % Info that createobj needs:
    po = AssignDefaultName(po,fnames);
    po = AssignDefaultFcnAddress(po,fnames,cc);
    po = AssignDefaultFcnVariables(po,fnames);
    po = AssignDefaultFcnCategory(po,fnames);
    po = AssignDefaultFcnUddClass(po,fnames);
    po = AssignDefaultFcnFilename(po,fnames);
    po = AssignDefaultFcnDeclaration(po,fnames);
    po = AssignDefaultFcnInfo(po,fnames);

otherwise,
    error(['Data class ''' upper(po.uclass) ''' not supported.'])
end
    
%--------------------------
function po = AssignDefaultName(po,fnames)
if ~isempty(strmatch('name',fnames,'exact')), 
    return; 
end
po.('name') = '';

%--------------------------
function po = AssignDefaultAddress(po,fnames)
if ~isempty(strmatch('address',fnames,'exact')), 
    return; 
end
po.('address') = [0 0];

%--------------------------
function po = AssignDefaultSize(po,fnames)
if ~isempty(strmatch('size',fnames,'exact')), 
    return; 
end
po.('size') = 1;

%--------------------------
function po = AssignDefaultNumericType(po,fnames)
if ~isempty(strmatch('type',fnames,'exact')), 
    return; 
end
po.('type') = 'int';

%--------------------------
function po = AssignDefaultPointerType(po,fnames);
if ~isempty(strmatch('reftype',fnames,'exact')), 
    return; 
end
po.('reftype') = 'void *';

%--------------------------
function po = AssignDefaultReferent(po,fnames);
if ~isempty(strmatch('referent',fnames,'exact')), 
    return; 
end
po.('referent') = [];

%--------------------------
function po = AssignDefaultLabelNValue(po,fnames)
if isempty(strmatch('label',fnames,'exact'))
    po.('label') = [];
end
if isempty(strmatch('value',fnames,'exact')),
    po.('value') = [];
else
    return; 
end

%--------------------------
function po = AssignDefaultBitInfo(po,fnames,procsubfamily)
if ~isempty(strmatch('bitinfo',fnames,'exact')),
    return; 
end
if strcmp('C54x',procsubfamily)
    po.('bitinfo') = 'Bit Field Location (Address: ...) Type ((unsigned int:0:16))'
else % C6xx
    po.('bitinfo') = 'Bit Field Location (Address: ...) Type ((unsigned int:0:32))'
end

%--------------------------
function po = AssignDefaultRegisterInfo(po,fnames)
po.('location') = '';
if isempty(strmatch('regname',fnames,'exact'))
    po.('regname') = '';
end
if isempty(strmatch('regid',fnames,'exact')),
    po.('regid') = [];
else
    return; 
end

%---------------------------------------
function po = AssignDefaultStructSizeInAus(po,fnames);
if ~isempty(strmatch('sizeof',fnames,'exact')), 
    return; 
end
po.('sizeof') = 1;

%---------------------------------------
function po = AssignDefaultStructMembers(po,fnames);
if ~isempty(strmatch('members',fnames,'exact')), 
    return; 
end
po.('members') = 1;

%---------------------------------------
function  po = AssignDefaultFcnAddress(po,fnames,cc)
if ~isempty(strmatch('address',fnames,'exact')), 
    return; 
end
addr = address(cc,po.name);
if isempty(addr)
    po.('address') = struct('start',[0 0],'end',[]);
else
    po.('address') = struct('start',addr,'end',[]);
end

%-------------------------------------------
function po = AssignDefaultFcnVariables(po,fnames);
if ~isempty(strmatch('funcvar',fnames,'exact')), 
    return; 
end
po.('funcvar') = []; % no variables

%-------------------------------------------
function po = AssignDefaultFcnCategory(po,fnames);
if ~isempty(strmatch('islibfunc',fnames,'exact')), 
    return; 
end
po.('islibfunc') = -1; % cannot be determined

%-------------------------------------------
function po = AssignDefaultFcnUddClass(po,fnames);
if ~isempty(strmatch('uclass',fnames,'exact')), 
    return; 
end
po.('uclass') = 'function';

%-------------------------------------------
function po = AssignDefaultFcnFilename(po,fnames);
if ~isempty(strmatch('filename',fnames,'exact')), 
    return; 
end
po.('filename') = ''; % empty

%-------------------------------------------
function po = AssignDefaultFcnDeclaration(po,fnames)
if ~isempty(strmatch('funcdecl',fnames,'exact')), 
    return; 
end
po.('funcdecl') = ''; % empty

%-------------------------------------------
function po = AssignDefaultFcnInfo(po,fnames)
if ~isempty(strmatch('funcinfo',fnames,'exact')), 
    return; 
end
po.('funcinfo') = ''; % empty

% [EOF] parser_wrapper.m