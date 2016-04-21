function [X, map] = readpnm(filename)
%READPNM Read image data from a PPM/PGM/PBM file.
%
%   [X, MAP] = READPNM(FILENAME) reads image data from a PPM, PGM or PBM
%   file.  X is an M-by-N array for PBM (bitmap) and PGM (grayscale) images
%   and an M-by-N-by-3 array for PPM (pixmap) images.  PPM, PGM, and PBM
%   images have no colormap so MAP is always empty.
%
%   PNM is not an image format by itself but means any of PPM, PGM, and PBM.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   The PPM/PGM/PBM file formats are described in the UNIX manual pages
%   ppm(5), pgm(5) and pbm(5).  A commonly used extension is to use 16 bits
%   pr color component with raw (binary) PPM and PGM images.  To my
%   knowledge, multi-byte color component values are always stored using
%   big-endian byte order.
%
% Author:      Peter J. Acklam
% E-mail:      pjacklam@online.no

%  Copyright 2001-2002 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:51 $

   info = impnminfo(filename);

   X     = [];
   map   = [];

   filename = info.Filename;
   format   = lower(info.Format);
   width    = info.Width;
   height   = info.Height;
   maxval   = info.MaxValue;
   encoding = info.Encoding;
   offset   = info.ImageDataOffset;

   % Number of channels (planes) in the image.
   channels = 1;
   if strcmp(format, 'ppm');
      channels = 3;
   end

   % Open file for reading.  The PBM/PGM/PPM format doesn't allow multi-byte
   % values, but some extensions do allow this, and they use big-endian.
   [fid, msg] = fopen(filename, 'r', 'ieee-be');
   if fid < 0
      error('MATLAB:readpnm:fileOpen', ...
            [filename ': ' msg]);
   end

   % Seek forward to the image data.
   fseek(fid, offset, 0);

   switch encoding

      case 'rawbits'

         % Get precision string for FREAD and number of bytes pr color
         % component value.
         if maxval <= 255
            precision = '*uint8';
         elseif maxval <= 65535
            precision = '*uint16';
         else
            error('MATLAB:readpnm:badMaxval', ...
                  '%s: maxval of %d not supported', filename, maxval);
         end

         % Figure out how many values FREAD must read.

         %
         % paddedWidth    - width of image including padding
         % valWidth       - number of values required to store one scanline
         % numVals        - number of values required to store all scanlines
         %
         switch format
            case 'pbm'
               % raw PBM files use a whole number of bytes for each scanline
               valWidth = ceil(width/8);
               paddedWidth = 8*valWidth;
               numVals = valWidth*height;
            case {'pgm' 'ppm'}
               numVals = height*width*channels;
         end

         % Read the data.
         [X, count] = fread(fid, numVals, precision);

         % The next read should not return any data.  If it does, then there is
         % trailing garbage at the end of the file.  This may indicate a
         % corrupt image (e.g., that each LF has been converted to CR+LF).
         if length(fread(fid, 1, 'char'));
            warning('MATLAB:readpnm:extraData', ...
                    [filename ': file contains extra data.']);
         end

         % Close the file.
         fclose(fid);

         if count < numVals
            warning('MATLAB:readpnm:unexpectedEOF', ...
                    [filename ': file ended while reading image data.']);
            % Fill in the missing values with zeros.
            X(numVals) = 0;
         end

         % Reshape arrays to correct size.
         switch format
            case 'pbm'
               XX = reshape(X, [valWidth height]).';
               XX = bitxor(XX, 255);    % PBM: white=0, black=1, so invert.

               X = logical(repmat(uint8(0), [height paddedWidth]));
               X(:,1:8:end) = bitget(XX, 8);
               X(:,2:8:end) = bitget(XX, 7);
               X(:,3:8:end) = bitget(XX, 6);
               X(:,4:8:end) = bitget(XX, 5);
               X(:,5:8:end) = bitget(XX, 4);
               X(:,6:8:end) = bitget(XX, 3);
               X(:,7:8:end) = bitget(XX, 2);
               X(:,8:8:end) = bitget(XX, 1);

               if width < paddedWidth
                  X = X(:,1:width);     % remove padding
               end

               return

            case {'pgm' 'ppm'}
               X = reshape(X, [channels width height]);
               X = permute(X, [3 2 1]);

         end

      case 'ASCII'

         % initialize output array
         if maxval <= 255
            X = repmat(uint8(0), [height channels width]);
         elseif maxval <= 65535
            X = repmat(uint16(0), [height channels width]);
         else
            X = zeros([height channels width]);
         end

         % since FREAD (used by PNMGETI) returns double arrays, read one
         % scanline at a time to save memory
         valWidth = width*channels;
         for row = 1:height
            % Get data and number of values read.
            [data, count] = pnmgeti(fid, valWidth);
            X(row,1:count) = data;

            % Display warning and break out if file is truncated.
            if count < valWidth
               warning('MATLAB:readpnm:unexpectedEOF', ...
                       [filename ': file ended while reading image data.']);
               break
            end
         end

         fclose(fid);

         X = permute(X, [1 3 2]);

      otherwise
         error('MATLAB:readpnm:badEncoding', ...
               [filename ': unrecognized ''encoding'' field']);
   end

   % PBM: white=0, black=1, so invert.  After that, no further processing
   % required, so break out.
   if strcmp(format, 'pbm')
      X = ~X;
      return
   end

   % With MATLAB images, the the minimum pixel value is always zero, the
   % maximum pixel value is 255 for uint8 arrays, 65535 for uint16 arrays
   % and 1 for double arrays.  In PPM and PGM images, the maximum pixel
   % value might be any positive integer, so we might need to scale the
   % pixel values.  If MAXVAL = 2^N-1, for some integer N, we use bit
   % shuffling to avoid temporary conversion to double.  Otherwise we
   % convert to double and perform the necessary arithmetic operations.

   if maxval <= 255
      % Scale from 0..MAXVAL to 0..255 and store as uint8.
      switch maxval
         case 1         % = 2^1-1
            X = bitor(bitshift(X, 1), X);                   % 1 -> 3
            X = bitor(bitshift(X, 2), X);                   % 3 -> 15
            X = bitor(bitshift(X, 4), X);                   % 15 -> 255
         case 3         % = 2^2-1
            X = bitor(bitshift(X, 2), X);                   % 3 -> 15
            X = bitor(bitshift(X, 4), X);                   % 15 -> 255
         case 7         % = 2^3-1
            X = bitor(bitshift(X, 3), X);                   % 7 -> 63
            X = bitor(bitshift(X, 2), bitshift(X, -4));     % 63 -> 255
         case 15        % = 2^4-1
            X = bitor(bitshift(X, 4), X);                   % 15 -> 255
         case 31        % = 2^5-1
            X = bitor(bitshift(X, 3), bitshift(X, -2));     % 31 -> 255
         case 63        % = 2^6-1
            X = bitor(bitshift(X, 2), bitshift(X, -4));     % 63 -> 255
         case 127       % = 2^7-1
            X = bitor(bitshift(X, 1), bitshift(X, -6));     % 127 -> 255
         case 255       % = 2^8-1
            % nothing to do
         otherwise
            X = uint8(round(255/maxval*double(X)));
      end
   elseif maxval <= 65535
      % Scale from 0..MAXVAL to 0..65535 and store as uint16.
      switch maxval
         case 511       % = 2^9-1
            X = bitor(bitshift(X, 7), bitshift(X, -2));     % 511 -> 65535
         case 1023      % = 2^10-1
            X = bitor(bitshift(X, 6), bitshift(X, -4));     % 1023 -> 65535
         case 2047      % = 2^11-1
            X = bitor(bitshift(X, 5), bitshift(X, -6));     % 2047 -> 65535
         case 4095      % = 2^12-1
            X = bitor(bitshift(X, 4), bitshift(X, -8));     % 4095 -> 65535
         case 8191      % = 2^13-1
            X = bitor(bitshift(X, 3), bitshift(X, -10));    % 8191 -> 65535
         case 16383     % = 2^14-1
            X = bitor(bitshift(X, 2), bitshift(X, -12));    % 16383 -> 65535
         case 32767     % = 2^15-1
            X = bitor(bitshift(X, 1), bitshift(X, -14));    % 32767 -> 65535
         case 65535     % = 2^16-1
            % nothing to do
         otherwise
            X = uint16(round(65535/maxval*double(X)));
      end
   else
      % Scale from 0..MAXVAL to 0..1 and store as double.
      X = double(X)/maxval;
   end
