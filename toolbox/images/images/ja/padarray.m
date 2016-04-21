% PADARRAY �@�z��̕t��
%
% B = PADARRAY(A,PADSIZE) �́AA ��k�Ԗڂ̎����ɉ������APADSIZE(k) �̐�
% �̗��z�� A �ɕt�����܂��BPADSIZE �́A���̐����̃x�N�g���ł��B
%
% B = PADARRAY(A,PADSIZE,PADVAL) �́A��̕ς��� PADVAL(�X�J��)�� A ��
% �z��ɕt�����܂��B
%
% B = PADARRAY(A,PADSIZE,PADVAL,DIRECTION) �́A������ DIRECTION ���w��
% ���ꂽ������ A �ɕt�����܂��BDIRECTION �́A�ȉ��̕�����̈���g�p
% ���邱�Ƃ��ł��܂��B
%
% DIRECTION �ɑ΂��镶����F
%       'pre'         �e�����ɉ����āA�ŏ��̔z��v�f�̑O�ɕt��
%       'post'        �e�����ɉ����āA�Ō�̔z��v�f�̌�ɕt��
%       'both'        �e�����ɉ����āA�ŏ��̔z��v�f�̑O�ƁA�Ō�̔z��
%                     �v�f�̌�ɕt��
%
�f�t�H���g�ŁADIRECTION �� 'post' �ł��B
% 
% B = PADARRAY(A,PADSIZE,METHOD,DIRECTION) �́A�ݒ肵�� METHOD ���g���āA
% �z�� A �ɕt�����܂��BMETHOD �́A���̕�����̈���g�p���邱�Ƃ�
% �ł��܂��B
%
% METHOD �ɑ΂��镶����F
%     'circular'  -- A ������I�ɌJ��Ԃ�
%     'replicate' -- A �̊O���v�f���J��Ԃ�
%     'symmetric' -- A �����E����ɑΏ̂ɌJ��Ԃ�
%
% �N���X�T�|�[�g
% -------------
% ���l��t������ꍇ�AA �́A���l�܂��́Alogical �̂����ꂩ�ł��B
% 'circular', 'replicate', �܂��� 'symmetric' �̎�@��p���ĕt������
% �ꍇ�AA �́A�C�ӂ̃N���X�ł��BB �́AA �Ɠ����N���X�ł��B
%
% ���
% -------
% �x�N�g���̍ŏ���3�v�f��t�����܂��B�t������v�f�́A�z��̋����R�s�[��
% �������܂�ł��܂��B
%
%       b = padarray([1 2 3 4],3,'symmetric','pre')
%
% �z��̍ŏ��̎����̍Ō�� 3�v�f��t�����A2�Ԗڂ̎����̍Ō��2�v�f��t
% �����܂��B�t������l�Ƃ��āA�Ō�̔z��v�f�̒l���g���܂��B
%
%       B = padarray([1 2; 3 4],[3 2],'replicate','post')
%
% 3�����z��̊e������3�v�f��t�����܂��B�e�t������v�f�͒l0�ł��B
%
%       A = [1 2; 3 4];
%       B = [5 6; 7 8];
%       C = cat(3,A,B)
%       D = padarray(C,[3 3],0,'both')
%
% �Q�l�F CIRCSHIFT, IMFILTER.


%   Copyright 1993-2002 The MathWorks, Inc.  
