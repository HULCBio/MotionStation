function [J,P] = deconvblind(varargin)
%DECONVBLIND Image restoration using blind deconvolution algorithm. 
%   [J,PSF] = DECONVBLIND(I,INITPSF) deconvolves image I using maximum
%   likelihood algorithm, returning both deblurred image J and a restored
%   point-spread function PSF. The resulting PSF is a positive array of
%   the same size as the INITPSF, normalized so its sum adds to 1. The
%   PSF restoration is affected strongly by the size of its initial
%   guess, INITPSF, and less by its values (an array of ones is a safer
%   guess).
%   
%   To improve the restoration, additional parameters can be passed in
%   (use [] as a place holder if an intermediate parameter is unknown):
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT,READOUT).
%
%   Additional constraints on PSF can be provided via a user supplied
%   function:
%   [J,PSF] = DECONVBLIND(...,FUN,P1,P2,...,PN)
%
%   FUN (optional) is a function describing additional constraints on the
%   PSF. There are four ways to specify FUN: as a function-handle, @, as
%   an inline object, or as a string containing either a function name or
%   a MATLAB expression. FUN is called at the end of each iteration. FUN
%   must accept the PSF as its first argument and may accept additional
%   parameters, P1, P2, ..., PN. FUN should return one argument, PSF,
%   that is the same size as the INITPSF, and satisfies the positivity
%   and normalization constraints.
%
%   NUMIT   (optional) is the number of iterations (default is 10).
%
%   DAMPAR  (optional) is an array that specifies the threshold deviation
%   of the resulting image from the image I (in terms of the standard 
%   deviation of Poisson noise) below which the damping occurs. The 
%   iterations are suppressed for the pixels that deviate within the 
%   DAMPAR value from their original value. This suppresses the noise 
%   generation in such pixels, preserving necessary image details
%   elsewhere. Default is 0 (no damping).
%
%   WEIGHT  (optional) is assigned to each pixel to reflect its recording
%   quality in the camera. A bad pixel is excluded from the solution by
%   assigning it zero weight value. Instead of giving a weight of one for
%   good pixels, you can adjust their weight according to the amount of
%   flat-field correction. Default is a unit array of the same size as 
%   input image I.
%
%   READOUT (optional) is an array (or a value) corresponding to the
%   additive noise (e.g., background, foreground noise) and the variance 
%   of the read-out camera noise. READOUT has to be in the units of the
%   image. Default is 0.
%
%
%   Note that the output image J could exhibit ringing introduced by the
%   discrete Fourier transform used in the algorithm. To reduce the
%   ringing use I = EDGETAPER(I,PSF) prior to calling DECONVBLIND.
%
%   Note also that DECONVBLIND allows you to resume deconvolution
%   starting from the results of an earlier DECONVBLIND run. To initiate
%   this syntax, the input I and INITPSF have to be passed in as cell
%   arrays, {I} and {INITPSF}. Then the output J and PSF become cell
%   arrays and can be passed as the input arrays into the next
%   DECONVBLIND call. The input cell array can contain one numeric array
%   (on initial call), or four numeric arrays (when it is the output from
%   a previous run of DECONVBLIND). The output J contains four elements,
%   where J{1}=I, J{2} is the image resulted from the last iteration,
%   J{3} is the image from one before last iteration, J{4} is an array
%   used internally by the iterative algorithm.
%
%   Class Support
%   -------------
%   I and INITPSF can be of class uint8, uint16, or double. DAMPAR and
%   READOUT have to be of the same class as the input image. Other inputs
%   have to be of class double. Output image J (or the first array of the
%   output cell) is of the same class as the input image I. Output PSF is
%   of class double.
%
%   Example
%   -------
%      
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .0001;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      WT = zeros(size(I));WT(5:end-4,5:end-4) = 1;
%      INITPSF = ones(size(PSF));
%      FUN = inline('PSF + P1','PSF','P1');
%      [J P] = deconvblind(BlurredNoisy,INITPSF,20,10*sqrt(V),WT,FUN,0);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(PSF,[]);
%                     title('True PSF');
%      subplot(223);imshow(J);
%                     title('Deblured Image');
%      subplot(224);imshow(P,[]);
%                     title('Recovered PSF');
%
%   See also DECONVWNR, DECONVREG, DECONVLUCY, EDGETAPER, PADARRAY,
%   PSF2OTF, OTF2PSF.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.4.4.3 $
%

%   References
%   ----------
%   "Acceleration of iterative image restoration algorithms, by D.S.C. Biggs 
%   and M. Andrews, Applied Optics, Vol. 36, No. 8, 1997.
%   "Deconvolutions of Hubble Space Telescope Images and Spectra",
%   R.J. Hanisch, R.L. White, and R.L. Gilliland. in "Deconvolution of Images 
%   and Spectra", Ed. P.A. Jansson, 2nd ed., Academic Press, CA, 1997.
%   "Light Microscopic Images Reconstructed by Maximum Likelihood
%   Deconvolution", Timothy J. Holmes et al. in "Handbook of 
%   Biological Confocal Microscopy", Ed. James B. Pawley, Plenum
%   Press, New York, 1995

% Parse inputs to verify valid function calling syntaxes and arguments
[J,P,NUMIT,DAMPAR,READOUT,WEIGHT,sizeI,classI,sizePSF,FunFcn,FunArg] = ...
    parse_inputs(varargin{:});

% 1. Prepare parameters for iterations
%
% Create indexes for image according to the sampling rate
idx = repmat({':'},[1 length(sizeI)]);

wI = max(WEIGHT.*(READOUT + J{1}),0);% at this point  - positivity constraint
fw = fftn(WEIGHT);
clear WEIGHT;
DAMPAR22 = (DAMPAR.^2)/2;

% 2. L_R Iterations
%
lambda = 2*any(J{4}(:)~=0);
for k = (lambda + 1) : (lambda + NUMIT),
    
  % 2.a Make an image and PSF predictions for the next iteration    
  if k > 2,% image
    lambda = (J{4}(:,1).'*J{4}(:,2))/(J{4}(:,2).'*J{4}(:,2) + eps);
    lambda = max(min(lambda,1),0);% stability enforcement
  end
  Y = max(J{2} + lambda*(J{2} - J{3}),0);% image positivity constraint
  
  if k > 2,% PSF
    lambda = (P{4}(:,1).'*P{4}(:,2))/(P{4}(:,2).'*P{4}(:,2) + eps);
    lambda = max(min(lambda,1),0);% stability enforcement
  end
  B = max(P{2} + lambda*(P{2} - P{3}),0);% PSF positivity constraint
  sumPSF = sum(B(:));
  B = B/(sum(B(:)) + (sumPSF==0)*eps);% normalization is a necessary constraint, 
  % because given only input image, the algorithm cannot even know how much
  % power is in the image vs PSF. Therefore, we force PSF to satisfy this 
  % type of normalization: sum to one.
  
  % 2.b  Make core for the LR estimation
  CC = corelucy(Y,psf2otf(B,sizeI),DAMPAR22,wI,READOUT,1,idx,[],[]);
  
  % 2.c Determine next iteration image & apply positivity constraint
  J{3} = J{2};
  H = psf2otf(P{2},sizeI);
  scale = real(ifftn(conj(H).*fw)) + sqrt(eps);
  J{2} = max(Y.*real(ifftn(conj(H).*CC))./scale,0);
  clear scale;
  J{4} = [J{2}(:)-Y(:) J{4}(:,1)];
  clear Y H;
  
  % 2.d Determine next iteration PSF & apply positivity constraint + normalization
  P{3} = P{2};
  H = fftn(J{3});
  scale = otf2psf(conj(H).*fw,sizePSF) + sqrt(eps);
  P{2} = max(B.*otf2psf(conj(H).*CC,sizePSF)./scale,0);
  clear CC H;
  
  sumPSF = sum(P{2}(:));
  P{2} = P{2}/(sumPSF + (sumPSF==0)*eps);
  
  if ~isempty(FunFcn),
    FunArg{1} = P{2};
    P{2} = feval(FunFcn,FunArg{:});
  end;
  P{4} = [P{2}(:)-B(:) P{4}(:,1)];
end
clear fw wI;

% 3. Convert the right array (for cell it is first array, for notcell it is
% second array) to the original image class & output the whole thing
num = 1 + strcmp(classI{1},'notcell');
if ~strcmp(classI{2},'double'),
  J{num} = changeclass(classI{2},J{num});
end

if num == 2,% the input & output is NOT a cell
  P = P{2};
  J = J{2};
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs 
function [J,P,NUMIT,DAMPAR,READOUT,WEIGHT,sizeI,classI,sizePSF,FunFcn,FunArg] ...
      = parse_inputs(varargin)
%
% Outputs:
% I=J{1}   the input array (could be any numeric class, 2D, 3D)
% P=P{1}   the operator that distorts the ideal image
%
% Defaults:
%
NUMIT = [];NUMIT_d = 10;% Number of  iterations, usually produces good
                        % result by 10.
DAMPAR =[];DAMPAR_d = 0;% No damping is default
WEIGHT =[];WEIGHT_d = 1;% All pixels are of equal quality, flat-field is one
READOUT=[];READOUT_d= 0;% Zero readout noise or any other
           % back/fore/ground noise associated with CCD camera.
           % Or the Image is corrected already for this noise by user.
FunFcn = '';FunFcn_d = '';
FunArg = {};FunArg_d = {};
funnum = [];funnum_d = nargin+1;

checknargin(2,inf,nargin,mfilename);% no constraint on max number because of FUN args

% First, assign the inputs starting with the cell/not cell image & PSF
%
switch iscell(varargin{1}) + iscell(varargin{2}),  
case 0, % no-cell array is used to do a single set of iterations
  classI{1} = 'notcell';  
  J{1} = varargin{1};% create a cell array in order to do the iterations
  P{1} = varargin{2};
case 1,
  msg = sprintf('In function %s, I and INITPSF must either both be cell arrays or both be numeric arrays.',...
                mfilename);
  eid = sprintf('Images:%s:IandInitpsfMustBeOfSameType',mfilename);
  error(eid,msg);
case 2,% input cell is used to resume the interrupted iterations or 
  classI{1} = 'cell';% to interrupt the iteration to resume them later
  J = varargin{1};
  P = varargin{2};
  if length(J)~=length(P),
    msg = sprintf('In function %s, I and INITPSF cell arrays must be of the same size.',mfilename);
    eid = sprintf('Images:%s:IandInitpsfMustBeOfSameSize',mfilename);      
    error(eid,msg);
  end
end;

% check the Image, which is the first array of the J-cell
[sizeI, sizePSF] = padlength(size(J{1}), size(P{1}));
classI{2} = class(J{1});

checkinput(J{1},{'uint8' 'uint16' 'double'},{'real' 'nonempty' 'finite'},mfilename,'I',1);

if prod(sizeI)<2,
  msg = sprintf('In function %s, input image must have at least two elements.',mfilename);
  eid = sprintf('Images:%s:inputImageMustHaveAtLeast2Elements',mfilename);
  error(eid,msg);
elseif ~isa(J{1},'double'),
  J{1} = im2double(J{1});
end

% check the PSF, which is the first array of the P-cell
checkinput(P{1},{'uint8' 'uint16' 'double'},{'real' 'nonempty' 'finite' 'nonzero'},mfilename,'INITPSF',1);

if prod(sizePSF)<2,
  msg = sprintf('In function %s, initial PSF must have at least two elements.',mfilename);
  eid = sprintf('Images:%s:initPSFMustHaveAtLeast2Elements',mfilename);
  error(eid,msg);
elseif ~isa(P{1},'double'),
  P{1} = double(P{1});
end

% now since the image&PSF are OK&double, we assign the rest of the J & P cells
len = length(J);
if len == 1,% J = {I} will be reassigned to J = {I,I,0,0}
  J{2} = J{1};
  J{3} = 0;
  J{4}(prod(sizeI),2) = 0;
  P{2} = P{1};
  P{3} = 0;
  P{4}(prod(sizePSF),2) = 0;
elseif len ~= 4,% J = {I,J,Jm1,gk} has to have 4 or 1 arrays
  msg = sprintf('In function %s, the input cells must consist of 1 or 4 numerical arrays.',mfilename);
  eid = sprintf('Images:%s:inputCellsMustBe1or4ElementNumArrays',mfilename);
  error(eid,msg);
else % check if J,Jm1,gk are double in the input cell
  if ~all([isa(J{2},'double'),isa(J{3},'double'),isa(J{4},'double')]),
      msg = sprintf(['In function %s, second, third, and forth array of the input image cell' ...
           ' have to be of class double.'],mfilename);
      eid = sprintf('Images:%s:ImageCellElementsMustBeDouble',mfilename);
      error(eid,msg);
  elseif ~all([isa(P{2},'double'),isa(P{3},'double'),isa(P{4},'double')]),
      msg = sprintf(['In function %s, second, third, and forth array of the input PSF cell' ...
                     ' have to be of class double.'],mfilename);   
      eid = sprintf('Images:%s:psfCellElementsMustBeDouble',mfilename);
      error(eid,msg);
  end
end; 

% Second, Find out if we have a function to put additional constraints on the PSF
%

function_classes = {'inline','function_handle','char'};
idx = [];
for n = 3:nargin,
  idx = strmatch(class(varargin{n}),function_classes);
  if ~isempty(idx),
    [FunFcn,msg] = fcnchk(varargin{n}); %only works on char, making it inline
    if ~isempty(msg),
        if isstruct(msg)
            eid = 'Images:deconvblind:invalidFun';
            error(eid, '%s', msg);
        else
            eid = sprintf('Images:%s:fcnchkError', mfilename);
            error(eid,msg);
        end
    end
    FunArg = [{0},varargin(n+1:nargin)];
    try % how this function works, just in case.
      feval(FunFcn,FunArg{:});
    catch
      Ftype = {'inline object','function_handle','expression ==>'};
      Ffcnstr = {' ',' ',varargin{n}};
      msg = sprintf(['DECONVBLIND cannot continue because user supplied' ...
                   ' %s %s\n failed with the error below.\n\n%s '],  ...
               Ftype{idx},Ffcnstr{idx},lasterr); 
      eid=sprintf('Images:%s:userSuppliedFcnFailed',mfilename);
      error(eid,msg)
    end
    funnum = n;
    break
  end
end

if isempty(idx),
  FunFcn = FunFcn_d;
  FunArg = FunArg_d;
  funnum = funnum_d;
end

%
% Third, Assign the inputs for general deconvolution:
%
checknargin(3,7,funnum,mfilename);
switch funnum,
case 4,%                      deconvblind(I,PSF,NUMIT,fun,...)
  NUMIT = varargin{3};
case 5,%                 deconvblind(I,PSF,NUMIT,DAMPAR,fun,...)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
case 6,%                 deconvblind(I,PSF,NUMIT,DAMPAR,WEIGHT,fun,...)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
  WEIGHT = varargin{5};
case 7,%                 deconvblind(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT,fun,...)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
  WEIGHT = varargin{5};
  READOUT = varargin{6};
end

% Forth, Check validity of the gen.conv. input parameters: 
%
% NUMIT check number of iterations
if isempty(NUMIT),
  NUMIT = NUMIT_d;
else  %verify validity
    checkinput(NUMIT,{'double'},{'scalar' 'positive' 'integer' 'finite'},mfilename,'NUMIT',3);
end

% DAMPAR check damping parameter
if isempty(DAMPAR),
  DAMPAR = DAMPAR_d;
elseif (numel(DAMPAR)~=1) && ~isequal(size(DAMPAR),sizeI),
  eid=sprintf('Images:%s:damparMustBeSizeOfInputImage',mfilename);
  error(eid,'If not a scalar, DAMPAR has to be size of the input image.');
elseif ~isa(DAMPAR,classI{2}),
  eid=sprintf('Images:%s:damparMustBeSameClassAsInputImage',mfilename);    
  error(eid,'DAMPAR has to be of the same class as the input image.');
elseif ~strcmp(classI{2},'double'),
  DAMPAR = im2double(DAMPAR);
end    

if ~isfinite(DAMPAR),
  eid=sprintf('Images:%s:damparMustBeFinite',mfilename);    
  error(eid,'DAMPAR has to be finite.');
end

% WEIGHT check weighting
if isempty(WEIGHT),
    WEIGHT = repmat(WEIGHT_d,sizeI);
else
    numw = numel(WEIGHT);
    checkinput(WEIGHT,{'double'},{'finite'},mfilename,'WEIGHT',5);
    if (numw ~= 1) && ~isequal(size(WEIGHT),sizeI),
        eid=sprintf('Images:%s:weightMustBeSizeOfInputImage',mfilename);
        error(eid,'If not a scalar, WEIGHT has to have size of the input image.');
    elseif numw == 1,
        WEIGHT = repmat(WEIGHT,sizeI);
    end;
end

% READOUT check read-out noise
if isempty(READOUT),
  READOUT = READOUT_d;
elseif (numel(READOUT)~=1) && ~isequal(size(READOUT),sizeI),
  eid=sprintf('Images:%s:readoutMustBeSizeOfInputImage',mfilename);
  error(eid,'If not a scalar, READOUT has to be size of the input image.');
elseif ~isa(READOUT,classI{2}),
  eid=sprintf('Images:%s:readoutMustBeSameClassAsInputImage',mfilename);
  error(eid,'READOUT has to be of the same class as the input image.');
elseif ~strcmp(classI{2},'double'),
  READOUT = im2double(READOUT);
end
if ~isfinite(READOUT),
  eid=sprintf('Images:%s:readoutMustBeFinite',mfilename);    
  error(eid,'READOUT has to be finite.');
end;
