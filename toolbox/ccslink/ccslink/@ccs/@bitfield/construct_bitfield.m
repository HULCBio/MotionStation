function bb = construct_bitfield(bb,args)
% Private. Set properties of bitfield object.
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.6.2.2 $  $Date: 2004/04/08 20:45:38 $

% Defaults
bb.address = [0 0];           % Offset = 0, Page = 0
bb.timeout = 10.0;            % Default = 10 seconds
bb.endianness = 'little';

nargs = length(args);
% if( nargin < 2 | ~ishandle(cc) ),
%     error('A memory object can only be created from a valid link object, see CCSDSP');
% end

% Inherent DSP properties

% Process constructors input arguments if any
if nargin <= 1
    return;      % Use defualts
end
if(mod(nargs,2)~=0)
    error(['BITFIELD constructor requires property and value ', ...
            'arguments to be specified in pairs.']);
end

% Get property / value pairs from argument list
for i = 1:2:nargs,
    prop = lower(args{i});
    val  = args{i+1};
    
    % Argument checking
    if isempty(prop)  % ignore nulls
        continue;
    elseif ~ischar(prop),
        error('Property Name must be a string entry');
    end
    if ~isempty( strmatch(prop,{'name','link','endianness','address','size','timeout'},'exact'))
        bb.(prop)   = val;
        args{i}     = [];
        args{i+1}   = [];        
    elseif strcmp(prop,'location')
        args{i}     = [];
        args{i+1}   = [];        
        [bb.offset,bb.length] = parse_bitfield_info(val);
    end
   
end           
construct_memoryobj(bb,args);  % Call base constructor

%------------------------------------------------------
function [offset,bitflength] = parse_bitfield_info(info)
% Format of INFO:
%  'Bit Field Location (Address: 0x80004444 (0)) Type ((unsigned int:1:22))'

len     = length(info);
idx     = strfind(info,'Type');
info    = info(idx+7:len-2); % get rid of and text before 'Type ((' and of '))' and text after
idx     = strfind(info,':');
offset  = str2num( info(idx(1)+1:idx(2)-1) );
bitflength  = str2num( info(idx(2)+1:length(info)) );

% [EOF] construct_bitfield.m 