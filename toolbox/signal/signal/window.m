function varargout = window(wname,N,varargin)
%WINDOW Window function gateway.
%   WINDOW(@WNAME,N) returns an N-point window of type specified
%   by the function handle @WNAME in a column vector.  @WNAME can
%   be any valid window function name, for example:
%
%   @bartlett       - Bartlett window.
%   @barthannwin    - Modified Bartlett-Hanning window. 
%   @blackman       - Blackman window.
%   @blackmanharris - Minimum 4-term Blackman-Harris window.
%   @bohmanwin      - Bohman window.
%   @chebwin        - Chebyshev window.
%   @flattopwin     - Flat Top window.
%   @gausswin       - Gaussian window.
%   @hamming        - Hamming window.
%   @hann           - Hann window.
%   @kaiser         - Kaiser window.
%   @nuttallwin     - Nuttall defined minimum 4-term Blackman-Harris window.
%   @parzenwin      - Parzen (de la Valle-Poussin) window.
%   @rectwin        - Rectangular window.
%   @tukeywin       - Tukey window.
%   @triang         - Triangular window.
%
%   WINDOW(@WNAME,N,OPT) designs the window with the optional input argument
%   specified in OPT. To see what the optional input arguments are, see the help
%   for the individual windows, for example, KAISER or CHEBWIN.
%
%   WINDOW launches the Window Design & Analysis Tool (WinTool).
%
%   EXAMPLE: 
%      N  = 65;
%      w  = window(@blackmanharris,N);
%      w1 = window(@hamming,N);
%      w2 = window(@gausswin,N,2.5);
%      plot(1:N,[w,w1,w2]); axis([1 N 0 1]);
%      legend('Blackman-Harris','Hamming','Gaussian');
% 
%   See also BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, BOHMANWIN, 
%            CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER, NUTTALLWIN, PARZENWIN, 
%            RECTWIN, TRIANG, TUKEYWIN, WINTOOL.

%    Author(s): P. Costa 
%    Copyright 1988-2002 The MathWorks, Inc.
%    $Revision: 1.14 $  $Date: 2002/11/21 15:46:59 $ 

if nargin == 0,
    wintool;
    w = [];
else
    % Create an N-point window specified in wname
    error(nargchk(2,inf,nargin)); % Function handle and order are required
    w = feval(wname,N,varargin{:});
end

if nargout > 0,
    varargout{1} = w;
end

% [EOF]
