function varargout = dspblkolapfilt(action,varargin)
%DSPBLKOLAPFILT Mask helper function for freq-domain filter blocks.
%   Used for both the Overlap-Add and Overlap-Save Filter blocks.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/04/14 21:00:21 $

if nargin==0, action = 'dynamic'; end
blk = gcb;

switch action
case 'dynamic'
        % No actions required
        
case 'init'
        % Get parameters from block:
        nfft_in = varargin{1};
        b = varargin{2};
        % Check data type of b
        sing_flag = 0;
        if isa(b, 'single')
          b = double(b);
          sing_flag = 1;
        end
        
        % Compute constants for underlying blocks:
        N = 2.^nextpow2(nfft_in);
        H = freqz(b,1,N,'whole');
        M = length(b);
        L = N-M+1;
        
        % Set the conjugate-symmetric checkbox on the
        % IFFT block, which implicitly sets the complexity
        % of the IFFT result, as follows:
        %
        % Real input, real filter
        %   - conjugate symmetric IFFT
        %   - output is automatically real
        %
        % Complex input, real filter
        % Real input, complex filter
        % Complex input, complex filter
        %   - non-conjugate-symmetric IFFT
        %   - output is complex
        
        IFFTblk = [blk '/IFFT'];
        orig_cs = get_param(IFFTblk,'cs_in');  % IFFT conj-symmetry checkbox
        outCplx = strcmp(get_param(blk,'output_complexity'),'Complex');
        if outCplx,
                new_cs='off';
        else
                new_cs='on';
        end
        if ~strcmp(orig_cs, new_cs),
                set_param(IFFTblk,'cs_in',new_cs);
        end
        
        % Return results to block mask:
        if sing_flag
          H = single(H);
        end
        results = {N,H,M,L};
        varargout(1:nargout) = results(1:nargout);
end

% [EOF] dspblkolapfilt.m
