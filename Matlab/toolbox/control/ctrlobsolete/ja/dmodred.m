% DMODRED   ���U���ԃ��f���̏�Ԃ̒᎟����
%
% [Ab,Bb,Cb,Db] = DMODRED(A,B,C,D,ELIM) �́A�x�N�g�� ELIM �Őݒ肳���
% ��Ԃ��폜���邱�Ƃɂ��A���f���̎�����ጸ���܂��B��ԃx�N�g���́A
% �ێ��������̂� X1 �ɁA�폜������̂� X2 �ƕ������܂��B
%
%    A = |A11  A12|      B = |B1|    C = |C1 C2|
%        |A21  A22|          |B2|
%    
%    x[n+1] = Ax[n] + Bu[n],   y[n] = Cx[n] + Du[n]
%
% X2[n+1] �́AX2[n] �ɐݒ肳��A���ʂ̕������� X1 �ɂ��ĉ����܂��B
% ���ʂ̃V�X�e���́A��菭�Ȃ���Ԑ� LENGTH(ELIM) �ɂȂ�AELIM ��
% ��ԗʂ́A���ɍ������g���������̂ƍl���邱�Ƃ��ł��܂��B
%
% �Q�l : DBALREAL, BALREAL, MODRED


%   J.N. Little 9-4-86
%   Revised 8-26-87 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:50 $
