% TH2ARX THETA �t�H�[�}�b�g���f����ARX���f���ɕϊ�
% 
%   [A, B]=TH2ARX(TH)
%
%   TH   : THETA �t�H�[�}�b�g�Œ�`���ꂽ���f���\��(THETA �Q��)
%
%   A, B : ARX �\�����`����s��:
%
%          y(t) + A1 y(t-1) + .. + An y(t-n) = ...
%                  B0 u(t) + ..+ B1 u(t-1) + .. Bm u(t-m)
%
%          A = [I A1 A2 .. An],  B=[B0 B1 .. Bm]
%
%
% [A, B, dA, dB] = TH2ARX(TH)�Ǝ��s����ƁAA, B �̕W���΍��� dA, dB �ɏo
% �͂��܂��B
%
% �Q�l:    ARX2TH, ARX

%   Copyright 1986-2001 The MathWorks, Inc.
