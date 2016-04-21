% LU   �s���LU����
% 
% [L,U] = LU(X) �́AX = L*U �ƂȂ��O�p�s��� U �Ɋi�[���A"�S���I�ȉ��O�p
% �s��"(���Ȃ킿�A���O�p�s��ƒu���s��̐�)�� L �Ɋi�[���܂��BX �́A�����s
% ��łȂ���΂Ȃ�܂���B
%
% [L,U,P] = LU(X) �́AP*X = L*U �ƂȂ�P�ʉ��O�p�s�� L�A��O�p�s�� U�A�u��
% �s�� P ���o�͂��܂��B
%
% Y = LU(X) �́AX ���t���̏ꍇ�ALAPACK��DGETRF�܂���ZGETRF���[�`������o��
% ��Ԃ��܂��BX ���X�p�[�X�̏ꍇ�AY �͌����ɏ�O�p�s��Ɠ����s��ɑg�ݍ���
% �ꂽ���O�p�s�� L ���܂݂܂��B�t���ŃX�p�[�X�̏ꍇ�A�u�����͎����܂��B
%
% [L,U,P,Q] = LU(X) �́A��ł͂Ȃ��X�p�[�X X �ɑ΂��� P*X*Q = L*U �ƂȂ�
% �P�ʉ��O�p�s�� L�A��O�p�s��s�� U�A�u���s�� P �Ɨ���ēx���ёւ����s�� 
% Q ���o�͂��܂��B�����UMFPACK���g�p���Ă���A���̍\���������Ɏ��Ԃ�
% �������������悭�ACOLAMD ���g�p�����Ƃ������悭�Ȃ�܂��B
%
% [L,U,P] = LU(X,THRESH) �́A�X�p�[�X�s����ł̃s�{�b�g�𐧌䂵�܂��B
% THRESH �́A[0,1] �ł̃s�{�b�g�̂������l�ł��B��̑Ίp�v�f�����̗��
% �]�Ίp�v�f�̑傫���� THRESH �{��菬�����Ƃ��ɁA�s�{�b�g���s���܂��B
% THRESH ��0�̏ꍇ�́A�����I�ɑΊp�s�{�b�g���s���܂��B�f�t�H���g�́A
% THRESH ��1�ł��B

% [L,U,P,Q] = LU(X,THRESH) �́AUMFPACK ���ł̃s�{�b�g�𐧌䂵�܂��B
% THRESH �́A[0,1] �ł̃s�|�b�g�̂������l�ł��B�s�{�b�g�� j �ɂ���āA
% UMFPACK�̓s�{�b�g���̂����Ƃ��X�p�[�X�ƂȂ�s i ��I�����A�s�{�b�g��
% �G���g���̐�Βl���� j �̍ő�̃G���g���� THRESH �{�Ɠ���������ȏ�
% �ɂȂ�悤�ɂ��܂��BL �̃G���g���̐U���� 1/THRESH �ɐ�������Ă��܂��B
% 1.0�̒l�́A�]���̕����I�ȃs�{�b�g���s�������ʂł��B�f�t�H���g�l��0.1
% �ł��B��菬���Ȓl�́A�X�p�[�X��LU�����Ȃ�X��������܂��A���͕s���m��
% �Ȃ�܂��B���傫�Ȓl�́A��萳�m�ȉ��𓱂����Ƃ��ł�(��ɂł͂���
% �܂���)�A�ʏ�A��Ƃ̑����͑������܂��B
%
% �Q�l�FCOLAMD, LUINC, QR, RREF, UMFPACK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:57 $
%   Built-in function.

