% BBDESIGN   Box-Behnken �v����쐬
%
% D=BBDESIGN(NFACTORS) �́A�v��NFACTORS�ɑ΂���Box-Behnken �v��𐶐�
% ���܂��B�o�͍s��D�́AN�~NFACTORS�ł��B�����ŁAN �́A�v��̓_���ł��B
% �e�s�ɂ́A-1 �� 1�̊ԂɂȂ�悤�ɃX�P�[�����ꂽ���ׂĂ̗v���ɑ΂���
% �ݒ�����X�g���Ă��܂��B 
%
% D=BBDESIGN(NFACTORS,'PNAME1',pvalue1,'PNAME2',pvalue2,...)�ɂ��A
% �ǉ��̃p�����[�^�Ƃ��̒l���w�肷�邱�Ƃ��ł��܂��B�g�p�\�ȃp�����[�^
% �́A���̂Ƃ���ł��B
% 
%       �p�����[�^   �l
%       'center'     �܂ނ��Ƃ̂ł���center�_�̐�
%       'blocksize'  �u���b�N���Ŏg�p�ł���_�̍ő吔
%
% [D,BLK]=BBDESIGN(...) �́Ablocked�v������߂܂��B�o�̓x�N�g�� BLK �́A
% �u���b�N���̃x�N�g���ł��B
%
% Box �� Behnken �́A�v���̐���3-7, 9-12, ���邢�́A16�ɓ������ꍇ�̌v���
% �񏥂��܂����B���̊֐��́A�����̌v����쐬���܂��B���̒l��NFACTORS��
% �΂��āABox �� Behnken �ɂ��\�ɂ���Ă��Ȃ��ꍇ�ł������A���̊֐��́A
% ���l�̕��@���g���āA�\�������v����쐬���܂��B�������A�����͑傫
% �����邽�ߎ��p�I�łȂ��\��������܂��B
%
% �Q�l : CCDESIGN, ROWEXCH, CORDEXCH.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:08:58 $
