function B = morphop(varargin)
%MORPHOP Dilate or erode image.
%   B = MORPHOP(OP_TYPE,A,SE,...) computes the erosion or dilation of A,
%   depending on whether OP_TYPE is 'erode' or 'dilate'.  SE is a
%   STREL array or an NHOOD array.  MORPHOP is intended to be called only
%   by IMDILATE or IMERODE.  Any additional arguments passed into
%   IMDILATE or IMERODE should be passed into MORPHOP following SE.  See
%   the help entries for IMDILATE and IMERODE for more details about the
%   allowable syntaxes.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2003/08/23 05:54:21 $

[A,se,pre_pad,...
 pre_pack,post_crop,post_unpack,op_type,is_packed,...
 unpacked_M,mex_method] = ParseInputs(varargin{:});

num_strels = length(se);

if pre_pad
    % Find the array offsets and heights for each structuring element
    % in the sequence.
    offsets = cell(1,num_strels);
    for k = 1:num_strels
        offsets{k} = getneighbors(se(k));
    end
    
    % Now compute how padding is needed based on the strel offsets.
    [pad_ul, pad_lr] = PadSize(offsets,op_type);
    P = length(pad_ul);
    Q = ndims(A);
    if P < Q
        pad_ul = [pad_ul zeros(1,Q-P)];
        pad_lr = [pad_lr zeros(1,Q-P)];
    end
    
    if is_packed
        % Input is packed binary.  Adjust padding appropriately.
        pad_ul(1) = ceil(pad_ul(1) / 32);
        pad_lr(1) = ceil(pad_lr(1) / 32);
    end

    if strcmp(op_type, 'dilate')
        pad_val = -Inf;
    else
        pad_val = Inf;
    end
    if islogical(A)
        % Use 0s and 1s instead of plus/minus Inf.
        pad_val = max(min(pad_val, 1), 0);
    end
    
    A = padarray(A,pad_ul,pad_val,'pre');
    A = padarray(A,pad_lr,pad_val,'post');
end

if pre_pack
    unpacked_M = size(A,1);
    A = bwpack(A);
end


%
% Apply the sequence of dilations/erosions.
%
B = A;
for k = 1:num_strels
    B = morphmex(mex_method, B, double(getnhood(se(k))), getheight(se(k)), unpacked_M);
end

%
% Image postprocessing steps.
%
if post_unpack
    B = bwunpack(B,unpacked_M);
end

if post_crop
    % Extract the "middle" of the result; it should be the same size as
    % the input image.
    idx = cell(1,ndims(B));
    for k = 1:ndims(B)
        P = size(B,k) - pad_ul(k) - pad_lr(k);
        first = pad_ul(k) + 1;
        last = first + P - 1;
        idx{k} = first:last;
    end
    B = B(idx{:});
end


%%%%%%%%%% ParseInputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A,se,pre_pad,pre_pack, ...
          post_crop,post_unpack,op_type,input_is_packed, ...
          unpacked_M,mex_method] = ParseInputs(A,se,op_type,func_name,varargin)

checknargin(2,5,nargin-2,func_name);

% Get the required inputs and check them for validity.
se = strelcheck(se,func_name,'SE',2);

A = CheckInputImage(A, func_name);

% Process optional arguments.
[padopt,packopt,unpacked_M] = ProcessOptionalArgs(func_name, varargin{:});
if strcmp(packopt,'ispacked')
    CheckUnpackedM(unpacked_M, size(A,1));
end

%
% Figure out the appropriate image preprocessing steps, image 
% postprocessing steps, and MEX-file method to invoke.
%
% First, find out the values of all the necessary predicates.
% 
se = getsequence(se);
num_strels = length(se);
strel_is_all_flat = all(isflat(se));
input_numdims = ndims(A);
strel_is_single = num_strels == 1;
class_A = class(A);
input_is_uint32 = strcmp(class_A,'uint32');
input_is_packed = strcmp(packopt,'ispacked');
input_is_logical = islogical(A);
input_is_2d = ndims(A) == 2;
output_is_full = strcmp(padopt,'full');

strel_is_all_2d = true;
for k = 1:length(se)
    if (ndims(getnhood(se(k))) > 2)
        strel_is_all_2d = false;
        break;
    end
end

%
% Check for error conditions related to packing
%
if input_is_packed && strcmp(op_type, 'erode') && (unpacked_M < 1)
    eid = sprintf('Images:%s:missingPackedM', func_name);  
    error(eid, '%s', 'M must be provided for packed erosion.');
end
if input_is_packed && ~strel_is_all_2d
    eid = sprintf('Images:%s:packedStrelNot2D', func_name);
    error(eid, '%s %s', 'Cannot perform packed erosion or dilation unless', ...
          ' structuring element is 2-D.');
end
if input_is_packed && ~input_is_uint32
    eid = sprintf('Images:%s:invalidPackedInputType', func_name);
    error(eid, '%s %s', 'Input image must be uint32 for packed erosion or ', ...
          'dilation.');
end
if input_is_packed && ~strel_is_all_flat
    eid = sprintf('Images:%s:nonflatStrelPacked', func_name);
    error(eid, '%s %s', 'Structuring element must be flat for packed ', ...
          'erosion or dilation.');
end
if input_is_packed && (input_numdims > 2)
    eid = sprintf('Images:%s:packedImageNot2D', func_name);
    error(eid, '%s %s','Cannot perform packed erosion or dilation unless ', ...
          'input image is 2-D.');
end
if input_is_packed && output_is_full
    eid = sprintf('Images:%s:packedFull', func_name);
    error(eid, '%s %s', 'Cannot perform packed erosion or dilation with ', ...
          'the ''full'' option.');
end

%
% Next, use predicate values to determine the necessary
% preprocessing and postprocessing steps.
%

% If the user has asked for full-size output, or if there are multiple
% and/or decomposed strels, then pre-pad the input image.
pre_pad = ~strel_is_single | output_is_full;

% If the input image is logical, then the strel must be flat.
if input_is_logical && ~strel_is_all_flat
    msgId = sprintf('Images:%s:binaryWithNonflatStrel', func_name);
    error(msgId,'Function %s cannot perform dilate a binary image with a nonflat structuring element.', ...
          func_name);
end

% If the input image is logical and not packed, and if there are multiple
% all-flat strels, the prepack the input image.
pre_pack = ~strel_is_single & input_is_logical & input_is_2d & ...
    strel_is_all_flat & strel_is_all_2d;

% If we had to pre-pad the input but the user didn't specify the 'full'
% option, then crop the image before returning it.
post_crop = pre_pad & ~output_is_full;

% If this function pre-packed the image, unpack it before returning it.
post_unpack = pre_pack;

%
% Finally, determine the appropriate MEX-file method to invoke.
%
if pre_pack || strcmp(packopt,'ispacked')
    mex_method = sprintf('%s_binary_packed',op_type);
    
elseif input_is_logical
    mex_method = sprintf('%s_binary',op_type);
    
elseif strel_is_all_flat
    mex_method = sprintf('%s_gray_flat',op_type);
    
else
    mex_method = sprintf('%s_gray_nonflat',op_type);
end

%%%%%%%%%% ProcessOptionalArgs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [padopt,packopt,unpacked_M] = ProcessOptionalArgs(func_name, varargin)

% Default values
padopt = 'same';
packopt = 'notpacked';
unpacked_M = -1;
check_M = false;

allowed_strings = {'same','full','ispacked','notpacked'};

for k = 1:length(varargin)
    if ischar(varargin{k})
        string = checkstrs(varargin{k}, allowed_strings, ...
                           func_name, 'OPTION', k+2);
        switch string
         case {'full','same'}
          padopt = string;
          
         case {'ispacked','notpacked'}
          packopt = string;
          
        end
        
    else
        unpacked_M = varargin{k};
        check_M = true;
        M_pos = k+2;
    end
end

if check_M
    checkinput(unpacked_M, {'double'}, {'real' 'nonsparse' 'scalar' 'integer' 'nonnegative'}, ...
               func_name, 'M', M_pos);
end

%%%%%%%%%% CheckInputImage %%%%%%%%%%%%%%%%%%%%%%%
function B = CheckInputImage(A,op_function)

B = A;

checkinput(A, {'numeric' 'logical'}, {'real' 'nonsparse'}, ...
           op_function, 'IM', 1);

%%%%%%%%%% CheckUnpackedM %%%%%%%%%%%%%%%%%%%%
function CheckUnpackedM(unpacked_M, M)

if unpacked_M >= 0
    d = 32*M - unpacked_M;
    if (d < 0) || (d > 31)
        eid = 'Images:imerode:inconsistentUnpackedM';
        msg = 'M is not consistent with the row dimension of the image.';
        error(eid,'%s',msg);
    end
end

%%%%%%%%%% PadSize %%%%%%%%%%%%%%%%%%%%%%%%%%
function [pad_ul, pad_lr] = PadSize(offsets,op_type)

if isempty(offsets)
    pad_ul = zeros(1,2);
    pad_lr = zeros(1,2);

else
    num_dims = size(offsets{1},2);
    for k = 2:length(offsets)
        num_dims = max(num_dims, size(offsets{k},2));
    end
    for k = 1:length(offsets)
        offsets{k} = [offsets{k} zeros(size(offsets{k},1),...
                                       num_dims - size(offsets{k},2))];
    end
    
    pad_ul = zeros(1,num_dims);
    pad_lr = zeros(1,num_dims);
    
    for k = 1:length(offsets)
        offsets_k = offsets{k};
        if ~isempty(offsets_k)
            pad_ul = pad_ul + max(0, -min(offsets_k,[],1));
            pad_lr = pad_lr + max(0, max(offsets_k,[],1));
        end
    end
    
    if strcmp(op_type,'erode')
        % Swap
        tmp = pad_ul;
        pad_ul = pad_lr;
        pad_lr = tmp;
    end
end
