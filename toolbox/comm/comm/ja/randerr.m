% RANDERR �r�b�g���p�^�[���̍쐬
%
% OUT = RANDERR(M) �́A�e�s�Ɉ��"1"�������_���ɔz�u���� M �s M ���
% �o�C�i���s����쐬���܂��B
%
% OUT = RANDERR(M,N) �́A�e�s�Ɉ��"1"�������_���ɔz�u���� M �s N ���
% �o�C�i���s����쐬���܂��B
%
% OUT = RANDERR(M,N,ERRORS)  �́AERRORS �Őݒ肳�ꂽ�s��"1"��z�u���� 
% M �s N ��̃o�C�i���s����쐬���܂��B
%
% ERRORS �́A�X�J���A�s�x�N�g���A�܂��́A2�s�̍s��̂����ꂩ�ł��B:
% �X�J��    : ERRORS ���X�J���̏ꍇ�A�e�s�̒��Őݒ肷��"1"�̐��́AERRORS
%             �Œ�`����܂��B
% �x�N�g��  : ERRORS ���s�x�N�g���̏ꍇ�A���̗v�f���g���āA"1"��ݒ肷��
%             �g�p�\�Ȑ���ݒ肵�܂��B���̃x�N�g�����Ɋ܂܂��"1"�̐�
%             ��\���l���A�������m���Ő����܂��B
% 2�s�̍s�� : ERRORS ��2�s�̍s��̏ꍇ�A�ŏ��̍s��"1"�̐����A2�Ԗڂ̍s��
%             �X�ɑΉ����鐔�̐�����m����ݒ肵�Ă��܂��BERRORS ��2�s
%             �ڂ̗v�f�̘a��1�ɂȂ�K�v������܂��B
%
% OUT = RANDERR(M,N,ERRORS,STATE) �́ARAND �̏�Ԃ� STATE �Ƀ��Z�b�g���܂��B
%
% ���̊֐��́A��萧�䕄�����̃e�X�g�ɗL�p�ł��B
%
% ���F
%    >> out = randerr(2,5)          >> out = randerr(2,5,2)  
%    out =                              out =
%         0    0    0    1    0              0    0    1    0    1
%         1    0    0    0    0              0    1    1    0    0
%                                                               
%    >> out = randerr(2,5,[1 3])    >> out = randerr(2,5,[1 3;0.8 0.2]) 
%    out =                              out =
%         1    0    1    1    0              0    1    0    0    0
%         1    0    0    0    0              0    0    0    1    0
%
% �Q�l�F RAND, RANDSRC, RANDINT.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:05 $
