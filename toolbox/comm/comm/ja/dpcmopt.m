% DPCMOPT �����p���X�����ϒ��p�����[�^���œK��
%
% PREDICTOR = DPCMOPT(TRAINING_SET, ORD) �́A�ݒ莟�� ORD �ƃg���[�j���O
% �Z�b�gTRAINING_SET ���g���āA�\���`�B�֐��𐄒肵�܂��B
%
% [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,LENGTH) �́A
% �Ή�����œK�����ꂽ CODEBOOK �� PARTITION ���o�͂��܂��BLENGTH �́A
% CODEBOOK �̒������L�q���鐮���ł��B
%
% [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,INI_CODEBOOK)
% �́ADPCM �ɑ΂��čœK�����ꂽ�\���`�B�֐� P_TRAINS, CODEBOOK, �����
% PARTITION ���쐬���܂��B�܂��A���͕ϐ�INI_CODEBOOK �ɂ́A�R�[�h�u�b�N
% �x�N�g���̏�������l���܂ރx�N�g���A�܂��́ACODEBOOK �̃x�N�g���T�C�Y��
% �w�肷��X�J�������̂ǂ��炩��ݒ肷�邱�Ƃ��ł��܂��B
%
% �Q�l�F LLOYDS.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
