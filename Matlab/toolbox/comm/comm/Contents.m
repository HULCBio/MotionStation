% Communications Toolbox
% Version 3.0 (R14) 05-May-2004
%
% Signal Sources.
%   randerr      - Generate bit error patterns.
%   randint      - Generate matrix of uniformly distributed random integers.
%   randsrc      - Generate random matrix using prescribed alphabet.
%   wgn          - Generate white Gaussian noise.
%
% Performance Evaluation.
%   berawgn      - Bit error rate (BER) for uncoded AWGN channels.
%   bercoding    - Bit error rate (BER) for coded AWGN channels.
%   berconfint   - BER and confidence interval of Monte Carlo simulation.
%   berfading    - Bit error rate (BER) for Rayleigh fading channels.
%   berfit       - Fit a curve to nonsmooth empirical BER data.
%   bersync      - Bit error rate (BER) for imperfect synchronization.
%   biterr       - Compute number of bit errors and bit error rate.
%   distspec     - Compute the distance spectrum of a convolutional code.
%   eyediagram   - Generate an eye diagram.
%   noisebw      - Calculate the equivalent noise bandwidth of a digital lowpass filter.
%   scatterplot  - Generate a scatter plot.
%   semianalytic - Calculate bit error rate using the semianalytic technique.
%   symerr       - Compute number of symbol errors and symbol error rate.
%
% Source Coding.
%   arithdeco    - Decode binary code using arithmetic decoding.
%   arithenco    - Encode a sequence of symbols using arithmetic coding.
%   compand      - Source code mu-law or A-law compressor or expander.
%   dpcmdeco     - Decode using differential pulse code modulation.
%   dpcmenco     - Encode using differential pulse code modulation.
%   dpcmopt      - Optimize differential pulse code modulation parameters.
%   huffmandeco  - Huffman decoder. 
%   huffmandict  - Generate Huffman code dictionary for a source with known probability model. 
%   huffmanenco  - Huffman encoder. 
%   lloyds       - Optimize quantization parameters using the Lloyd algorithm.
%   quantiz      - Produce a quantization index and a quantized output value.
%
% Error-Control Coding.
%   bchdec       - BCH decoder.
%   bchenc       - BCH encoder.
%   bchgenpoly   - Generator polynomial of BCH code.
%   convenc      - Convolutionally encode binary data.
%   cyclgen      - Produce parity-check and generator matrices for cyclic code.
%   cyclpoly     - Produce generator polynomials for a cyclic code.
%   decode       - Block decoder.
%   encode       - Block encoder.
%   gen2par      - Convert between parity-check and generator matrices.
%   gfweight     - Calculate the minimum distance of a linear block code.
%   hammgen      - Produce parity-check and generator matrices for Hamming code.
%   rsdec        - Reed-Solomon decoder.
%   rsenc        - Reed-Solomon encoder.
%   rsdecof      - Decode an ASCII file that was encoded using Reed-Solomon code.
%   rsencof      - Encode an ASCII file using Reed-Solomon code.
%   rsgenpoly    - Produce Reed-Solomon code generator polynomial.
%   syndtable    - Produce syndrome decoding table.
%   vitdec       - Convolutionally decode binary data using the Viterbi algorithm.
%
% Interleaving/Deinterleaving
%   algdeintrlv     - Restore ordering of symbols.
%   algintrlv       - Reorder symbols using algebraically derived permutation table.
%   convdeintrlv    - Restore ordering of symbols permuted using shift registers.
%   convintrlv      - Permute symbols using a set of shift registers.
%   deintrlv        - Restore ordering of symbols.
%   intrlv          - Reorder sequence of symbols.
%   helintrlv       - Permute symbols using a helical array.
%   heldeintrlv     - Restore ordering of symbols permuted using HELINTRLV.
%   helscandeintrlv - Restore ordering of symbols in a helical pattern.
%   helscanintrlv   - Permute symbols in a helical pattern.
%   matdeintrlv     - Reorder symbols by filling a matrix by columns and emptying it by rows.
%   matintrlv       - Permute symbols by filling a matrix by rows and emptying it by columns.
%   muxdeintrlv     - Restore ordering of symbols using specified shift registers.
%   muxintrlv       - Permute symbols using shift registers with specified delays.
%   randdeintrlv    - Restore ordering of symbols using a random permutation.
%   randintrlv      - Reorder the symbols using a random permutation.
%
% Analog Modulation/Demodulation.
%   ammod        - Amplitude modulation.
%   amdemod      - Amplitude demodulation.
%   fmmod        - Frequency modulation.
%   fmdemod      - Frequency demodulation.
%   pmmod        - Phase modulation.
%   pmdemod      - Phase demodulation.
%   ssbmod       - Single sideband amplitude modulation.
%   ssbdemod     - Single sideband amplitude demodulation.
%
% Digital Modulation/Demodulation.
%   dpskmod      - Differential phase shift keying modulation.
%   dpskdemod    - Differential phase shift keying demodulation.
%   fskmod       - Frequency shift keying modulation.
%   fskdemod     - Frequency shift keying demodulation.
%   genqammod    - General quadrature amplitude modulation.
%   genqamdemod  - General quadrature amplitude demodulation.
%   modnorm      - Scaling factor for normalizing modulation output.
%   mskmod       - Minimum shift keying modulation.
%   mskdemod     - Minimum shift keying demodulation.
%   oqpskmod     - Offset quadrature phase shift keying modulation.
%   oqpskdemod   - Offset quadrature phase shift keying demodulation
%   pammod       - Pulse amplitude modulation.
%   pamdemod     - Pulse amplitude demodulation.
%   pskmod       - Phase shift keying modulation. 
%   pskdemod     - Phase shift keying demodulation. 
%   qammod       - Quadrature amplitude modulation.
%   qamdemod     - Quadrature amplitude demodulation.
%
% Pulse Shaping.
%   intdump      - Integrate and dump.
%   rcosflt      - Filter the input signal using a raised cosine filter.
%   rectpulse    - Rectangular pulse shaping.
%
% Special Filters.
%   hank2sys     - Convert a Hankel matrix to a linear system model.
%   hilbiir      - Hilbert transform IIR filter design.
%   rcosine      - Design raised cosine filter.
%
% Lower-Level Functions for Special Filters.
%   rcosfir      - Design a raised cosine FIR filter.
%   rcosiir      - Design a raised cosine IIR filter.
%
% Channels.
%   awgn         - Add white Gaussian noise to a signal.
%   bsc          - Model a binary symmetric channel.
%   rayleighchan - Construct a Rayleigh fading channel object.
%   ricianchan   - Construct a Rician fading channel object.
%   filter       - Filter a signal with a channel object.
%   reset        - Reset a channel object.
%
% Equalizers.  
%   lms         - Construct a least mean square (LMS) adaptive algorithm object.
%   signlms     - Construct a signed LMS adaptive algorithm object.
%   normlms     - Construct a normalized LMS adaptive algorithm object.
%   varlms      - Construct a variable step size LMS adaptive algorithm object.
%   rls         - Construct a recursive least squares (RLS) adaptive algorithm object.
%   cma         - Construct a constant modulus algorithm (CMA) object.
%   lineareq    - Construct a linear equalizer object.
%   dfe         - Decision feedback equalizer.
%   equalize    - Equalize a signal with an equalizer object.
%   reset       - Reset equalizer object.
%   mlseeq      - Equalize a linearly modulated signal using the Viterbi algorithm.
%  
% Galois Field Computations.
%   gf           - Create a Galois array.
%   gfhelp       - Provide a list of operators that are compatible with Galois arrays. 
%   convmtx      - Convolution matrix of Galois field vector.
%   cosets       - Produce cyclotomic cosets for a Galois field.
%   dftmtx       - Discrete Fourier transform matrix in a Galois field.
%   gftable      - Generate a file to accelerate Galois field computations.
%   isprimitive  - Check whether a polynomial over a Galois field is primitive.
%   minpol       - Find the minimal polynomial for a Galois element.
%   primpoly     - Find primitive polynomials for a Galois field.
%
% Computations in Galois Fields of Odd Characteristic.
%   gfadd        - Add polynomials over a Galois field.
%   gfconv       - Multiply polynomials over a Galois field.
%   gfcosets     - Produce cyclotomic cosets for a Galois field.
%   gfdeconv     - Divide polynomials over a Galois field.
%   gfdiv        - Divide elements of a Galois field.
%   gffilter     - Filter data using polynomials over a prime Galois field.
%   gflineq      - Find a particular solution of Ax = b over a prime Galois field. 
%   gfminpol     - Find the minimal polynomial of an element of a Galois field.
%   gfmul        - Multiply elements of a Galois field.
%   gfpretty     - Display a polynomial in traditional format.
%   gfprimck     - Check whether a polynomial over a Galois field is primitive.
%   gfprimdf     - Provide default primitive polynomials for a Galois field.
%   gfprimfd     - Find primitive polynomials for a Galois field.
%   gfrank       - Compute the rank of a matrix over a Galois field.
%   gfrepcov     - Convert one binary polynomial representation to another.
%   gfroots      - Find roots of a polynomial over a prime Galois field.
%   gfsub        - Subtract polynomials over a Galois field.
%   gftrunc      - Minimize the length of a polynomial representation.
%   gftuple      - Simplify or convert the format of elements of a Galois field.
%
% Utilities.
%   bi2de        - Convert binary vectors to decimal numbers.
%   de2bi        - Convert decimal numbers to binary numbers.
%   erf          - Error function.
%   erfc         - Complementary error function.
%   istrellis    - Check if the input is a valid trellis structure.
%   marcumq      - Generalized Marcum Q function.
%   mask2shift   - Convert mask vector to shift for a shift register configuration.
%   oct2dec      - Convert octal numbers to decimal numbers.
%   poly2trellis - Convert convolutional code polynomial to trellis description.
%   qfunc        - Q function.
%   qfuncinv     - Inverse Q function.
%   shift2mask   - Convert shift to mask vector for a shift register configuration.
%   vec2mat      - Convert a vector into a matrix.
%
% Graphical User Interface.
%   bertool      - Bit Error Rate Analysis Tool.
%
% See also COMMDEMOS, SIGNAL.

% Copyright 1996-2004 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.1.6.10 $Date: 2004/01/26 23:19:20 $
