% [gain,peakf]=norminf(sys,tol)
%
% ���g�������̃s�[�N�Q�C�����v�Z���܂��B
%                                   -1
%             G (s) = D + C (sE - A)  B
%
% (A,E)����������ɌŗL�l�������Ȃ��ꍇ�ɂ̂݁A�m�����͗L���ł��B
%
% ����:
%   SYS        G(s)�̃V�X�e���s��̋L�q(LTISYS���Q��)�B
%   TOL        �ڕW���ΐ��x(�f�t�H���g = 0.01)�B
%
% �o��:
%   GAIN       �s�[�N�Q�C��(G������Ȃ��RMS�Q�C��)�B
%   PEAKF      �m�������B���������g���B���̂悤�ɂȂ�܂��B
%
%                     || G ( j * PEAKF ) ||  =  GAIN
%
% �Q�l�F    DNORMINF, QUADPERF, MUPERF.



% Copyright 1995-2002 The MathWorks, Inc. 
