% RESHAPE   �z��̃T�C�Y�̕ύX
% 
% RESHAPE(X,M,N)�́AX���������ɗv�f���g����M�sN��̍s����o�͂��܂��B
% X��M*N�̗v�f�������Ă��Ȃ���΁A�G���[�ƂȂ�܂��B
%
% RESHAPE(X,M,N,P,...)�́AX�Ɠ����v�f�������A�T�C�Y��M*N*P*..�ł��鑽��
% ���z����o�͂��܂��BM*N*P*...�́APROD(SIZE(X))�Ɠ����łȂ���΂Ȃ�܂�
% ��B
%
% RESHAPE(X,[M N P ...])�́ARESHAPE(X,M,N,P,...)�Ɠ����ł��B
%
% RESHAPE(X,...,[],...) �́A[]�ŕ\�킳��鎟���̒������A�������̐ς��A
% PROD(SIZE(X)) �Ɠ������Ȃ�悤�Ɍv�Z���܂��BPROD(SIZE(X))�́A���m�̎���
% ���̐ςŊ���؂��K�v������܂��B�����Ƃ��ẮA[]��1��̂ݎg�����Ƃ���
% ���܂��B
%
% ��ʂɁARESHAPE(X,SIZ)��X�Ɠ����v�f�������A�T�C�Y��SIZ�ł���N�����z��
% ���o�͂��܂��BPROD(SIZ)�́APROD(SIZE(X))�Ɠ����łȂ���΂Ȃ�܂���B 
%
% �Q�l�FSQUEEZE, SHIFTDIM, COLON.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:46 $
%   Built-in function.
