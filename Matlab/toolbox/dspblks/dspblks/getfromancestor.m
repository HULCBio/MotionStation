function paramOut = getfromancestor(blk,param_name,varssrc, maxcount)
% getFromAncestor - gets field value from ancestor block
%
% returns the mask variable from this block or from nearest 
% ancestor block containing parameter PARAM_NAME if such an
% ancestor block exists. If the search fails, return ''.

% if varssrc is set to 0 (default), then return the variable for the
% parameter, found in get_param(0
% if varssrc is set to 1, then return the block_data.cparams.ws.<param>
% variable for the parameter.
% if varssrc is set to 1, then return the block_data.cparams.str.<param>
% variable for the parameter.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 20:53:56 $

modelroot = bdroot(blk);

if nargin < 3,
    varssrc = 0;
end
if nargin < 4,
    maxcount = 6;
end


switch varssrc,
case 0,
    % get from block using get_param
    paramDef = '';
    fcn = @get_param;
case 1,
    % get from block using parameter passed in userdata 
    % block_data.cparams.ws.<param>
    paramDef = '';
    fcn = @get_str_param;
case 2,
    % get from block using parameter passed in userdata 
    % block_data.cparams.str.<param>
    paramDef = 0;
    fcn = @get_ws_param;
otherwise,
    error('Bad value for VARSRC.');
end

sle = sllasterror;
mle = lasterror;

count = 0;
while count < maxcount,
    count = count+1;
    try,
        paramOut = feval(fcn, blk, param_name);
        sllasterror(sle);
        lasterror(mle);
        return;
    catch,
        if(strmatch(blk,modelroot))
            sllasterror(sle);
            lasterror(mle);
            paramOut = paramDef;
            return;
        end
        blk = get_param(blk,'parent');
        sllasterror(sle);
        lasterror(mle);
        paramOut = paramDef;
        continue;
    end
end 
sllasterror(sle);
lasterror(mle);
paramOut = paramDef;

%-----------------------------------------------------------------------------
function parameter = get_ws_param(blk, param_name)

block_data = get_param(blk,'userdata');

% this relies on a try/catch being in the calling fcn
parameter = getfield(block_data.cparams.ws,param_name);

%-----------------------------------------------------------------------------
function parameter = get_str_param(blk, param_name)

block_data = get_param(blk,'userdata');
% this relies on a try/catch being in the calling fcn
parameter = getfield(block_data.cparams.str,param_name);
