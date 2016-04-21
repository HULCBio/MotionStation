% Communications Blockset mask helper functions.
% 
%  Mask helper functions 
%
%   COMM SOURCES LIBRARY:
%   ---------------------
%   commblkpnseq2              - PN Sequence Generator
%   commblkgcgen               - Gold Sequence Generator
%   commblkksgen               - Kasami Sequence Generator
%   commblkhcgen               - Hadamard Code Generator
%   commblkovsfcgen            - OVSF Code Generator
%   commblkwcgen               - Walsh Code Generator
%   commblkbcgen               - Barker Code Generator
%   commblkuniformsrc2         - Uniform Noise Generator
%   commblkgaussiansrc2        - Gaussian Noise Generator
%   commblkrayleighsrc2        - Rayleigh Noise Generator
%   commblkriciansrc2          - Rician Noise Generator
%   commblkrandintsrc2         - Random Integer Generator
%   commblkpoissrc             - Poisson Integer Generator
%   commblkerrpatgen           - Binary Error Pattern Generator
%   commblkbernoullisrc2       - Bernoulli Binary Generator
%
%   COMM SINKS LIBRARY:
%   -------------------
%   commblkerrrate             - Error Rate Calculation
%   commblkeyescat2            - Discrete-Time Eye and Scatter Diagrams
%
%   ERROR DETECTION AND CORRECTION LIBRARY:
%   ---------------------------------------
%   commblkcrcgen              - Cyclic-Redundancy-Check Generator/Syndrome Detector
%   commblksbchdec             - BCH Decoder
%   commblkrsencoder           - Integer-Input Reed-Solomon Encoder 
%   commblkrsdecoder           - Integer-Output Reed-Solomon Decoder 
%   commblkrsencbin            - Binary-Input Reed-Solomon Encoder 
%   commblkrsdecbin            - Binary-Output Reed-Solomon Decoder 
%   commblkconvcod             - Convolutional Encoder
%   commblkviterbi             - Viterbi Decoder 
%   commblkapp                 - APP Decoder 
%
%   INTERLEAVING LIBRARY:
%   ---------------------
%   commblkinterl              - Interleaver/Deinterleaver
%   commblkalgintrlvr          - Algebraic Interleaver/Deinterleaver
%
%   DIGITAL BASEBAND MODULATION LIBRARY:
%   ------------------------------------
%   commblkpammod              - Digital Baseband M-PAM Modulator/Demodulator
%   commblkqammod              - Digital Baseband M-QAM Modulator/Demodulator
%   commblkpskmod              - Digital Baseband M-PSK & M-DPSK Modulator/Demodulator
%   commblkqpskmod             - Digital Baseband QPSK & DQPSK Modulator/Demodulator
%   commblkfskdemod            - Digital Baseband FSK Demodulator
%   commblkfskmod              - Digital Baseband FSK Modulator
%   commblkcpmdemod            - Digital Baseband CPM Demodulator
%   commblkcpmmod              - Digital Baseband CPM Modulator
%   commblkgmskdemod           - Digital Baseband GMSK Demodulator
%   commblkgmskmod             - Digital Baseband GMSK Modulator
%   commblkmskdemod            - Digital Baseband MSK Demodulator
%   commblkmskmod              - Digital Baseband MSK Modulator
%   commblkcpfskdemod          - Digital Baseband CPFSK Demodulator
%   commblkcpfskmod            - Digital Baseband CPFSK Modulator
%   commblkdyampmdemod         - Digital Baseband AM & PM Demodulator 
%   commblkdyampmmod           - Digital Baseband AM & PM Modulator
%   commblkgentcmdec           - Digital Baseband General TCM Decoder
%   commblkgentcmenc           - Digital Baseband General TCM Encoder
%   commblkpsktcmdec           - Digital Baseband M-PSK TCM Decoder
%   commblkpsktcmenc           - Digital Baseband M-PSK TCM Encoder
%   commblkqamtcmdec           - Digital Baseband M-QAM TCM Decoder
%   commblkqamtcmenc           - Digital Baseband M-QAM TCM Encoder
%
%   FILTERS LIBRARY:
%   ----------------
%   commblkwininteg            - Windowed Integrator
%   commblkrectpulse           - Ideal Rectangular Pulse Filter
%   commblkrcfilt              - Raised Cosine Transmit/Receive Filter
%   commblkgaussfilt           - Gaussian Filter
%
%   CHANNELS LIBRARY:
%   -----------------
%   commblkawgnchan2           - AWGN Channel
%   commblkfadingchan2         - Multipath Fading Channel
%   commblkrayleighchan2       - Multipath Rayleigh Fading Channel
%   commblkricianchan2         - Rician Fading Channel
%   commblkbschan              - Binary Symmetric Channel
%
%   SYNCHRONIZATION LIBRARY:
%   ------------------------
%   commblksqtimrec2           - Squaring Timing Recovery
%
%   EQUALIZERS LIBRARY:
%   -------------------
%   commblklineqmasklms        - LMS, Sign, Normalized Linear Equalizers
%   commblklineqmaskrls        - RLS Linear Equalizer 
%   commblklineqmaskvarlms     - Variable Step LMS Linear Equalizer
%   commblkdfeeqlms            - LMS Decision Feedback Equalizer
%   commblkdfeeqrls            - RLS Decision Feedback Equalizer
%   commblkmlseeq              - MLSE Equalizer
%
%   SEQUENCE OPERATIONS LIBRARY:
%   -----------------------------
%   commblkwint                - Windowed Integrator
%   commblkdrpt2               - Derepeat
%   commblkscram2              - Scrambler/Descrambler
%   commblkselect              - Puncture/Insert Zero
%
%   UTILITY FUNCTIONS LIBRARY:
%   --------------------------
%   commblkalignsigs           - Align Signals
%   commblkfinddelay           - Find Delay
%   commblkmapdata             - Data Mapper
%
%  See also COMMBLKS, COMMMEX, COMMBLKSDEMOS, COMM. 

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.19.4.2 $  $Date: 2004/03/30 13:03:14 $