% [gain,peakf]=dnorminf(sys,tol)
%
% ���̗��U���ԓ`�B�֐��̃s�[�N�Q�C�����v�Z���܂��B
%                                   -1
%             G (z) = D + C (zE - A)  B
%
% (A,E)���P�ʉ~��ɌŗL�l�������Ȃ��ꍇ�ɂ̂݁A�m�����͗L���ł��B
%
% ����:
%   SYS        G(z)��system�s��̋L�q(LTISYS���Q��)�B
%   TOL        �ڕW���ΐ��x(�f�t�H���g = 0.01)�B
%
% �o��:
%   GAIN       �s�[�N�Q�C��(G������ȂƂ��́ARMS�Q�C��)�B
%   PEAKF      ���̃m��������������g���B���Ȃ킿�A
%
%                               j*PEAKF
%                       || G ( e        ) ||  =  GAIN
%
%
% �Q�l�F    NORMINF.



% Copyright 1995-2002 The MathWorks, Inc. 
