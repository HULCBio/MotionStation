% WAVREAD   Microsoft WAVE (".wav")�T�E���h�t�@�C���̓ǂݍ���
% 
% Y = WAVREAD(FILE)�́A������FILE�Ŏw�肳�ꂽWAVE�t�@�C����ǂݍ��݁A�T
% ���v�����O���ꂽ�f�[�^��Y�ɏo�͂��܂��B�g���q���w�肳��Ă��Ȃ��ꍇ�́A
% ".wav"��t�������܂��B�U���l�́A�͈�[-1,+1]�ł��B
%
% [Y,FS,NBITS] = WAVREAD(FILE)�́A�w���c�P�ʂŃT���v�����O���[�g(FS)���o
% �͂��A�t�@�C�����̃f�[�^�𕄍������邽�߂Ɏg���T���v��������̃r�b�g��
% (NBITS)���o�͂��܂��B
%
% [...] = WAVREAD(FILE,N)�́A�t�@�C�����̊e�`�����l������A�ŏ���N�̃T
% ���v���݂̂��o�͂��܂��B
% 
% [...] = WAVREAD(FILE,[N1 N2])�́A�t�@�C�����̊e�`�����l����N1����N2�܂�
% �̃T���v���݂̂��o�͂��܂��B
% 
% SIZ = WAVREAD(FILE,'size')�́A���ۂ̃I�[�f�B�I�f�[�^�̑���ɁA�t�@�C
% �����ɂ���I�[�f�B�I�f�[�^�̃T�C�Y���A�x�N�g��SIZ = [samples channels]
% �Ƃ��ďo�͂��܂��B
%
% [Y,FS,NBITS,OPTS] = WAVREAD(...)�́AWAV�t�@�C�����Ɋ܂܂��t���I�ȏ�
% ����\����OPTS�ɏo�͂��܂��B���̍\���̂̓��e�́A�t�@�C�����ɈقȂ�܂��B
% ��ʂɎg����\���̂̃t�B�[���h���́A'.fmt'(�I�[�f�B�I�t�H�[�}�b�g��
% ��)��'.info'(�T�u�W�F�N�g�^�C�g���A�R�s�[���C�g�����L�q����e�L�X�g)��
% ���B
%
% �T���v��������32�r�b�g�܂ł̃}���`�`�����l���f�[�^���T�|�[�g���Ă��܂��B
% 
% ���ӁF���̃t�@�C�����[�_�́AMicrosoft PCM�f�[�^�t�H�[�}�b�g�݂̂�
%       �T�|�[�g���Ă��܂��Bwave-list �f�[�^�́A�T�|�[�g���Ă��܂���B
%
% �Q�l�FWAVWRITE, AUREAD, AUWRITE.


%   Author: D. Orofino
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.28 $  $Date: 2002/05/30 20:42:03 $

%   Copyright 1984-2004 The MathWorks, Inc.
