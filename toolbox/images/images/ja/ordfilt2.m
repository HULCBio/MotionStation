% ORDFILT2   2�����I�ɏ����t����ꂽ�f�[�^�ɑ΂��铝�v�t�B���^
%
% B=ORDFILT2(A,ORDER,DOMAIN) �́ADOMAIN ���̔�[���v�f�ɂ��w�肳�ꂽ
% �ߖT�̃\�[�g���ꂽ�W������ ORDER �Ԗڂ� A �̒��̊e�v�f�ƒu�������܂��B
%
% B = ORDFILT2(A,ORDER,DOMAIN,S) �́A���Z�I�ȃI�t�Z�b�g�Ƃ��āADOMAIN 
% �̔�[���l�ɑΉ����� S �̒l���g���܂��B���̂Ƃ��AS �́ADOMAIN �Ɠ���
% �傫���ł��B
% 
% B = ORDFILT2(...,PADOPT) �́A�ǂ̂悤�ɍs��̋��E��t�����邩�𐧌�
% ���܂��BPADOPT �ɂ́A'zeros'(�f�t�H���g)�A�܂��́A'symmetric' ��ݒ�
% �ł��܂��BPADOPT �� 'zeros' �̏ꍇ�AA �̋��E�ɂ�0���t������܂��B
% PADOPT �� 'symmetric' �̏ꍇ�AA �̋��E�őΏ̓I�Ɋg������܂��B
%
% �N���X�T�|�[�g
% -------------
% A �̃N���X�́Alogical, uint8�Auint16�A�܂��́Adouble �̃N���X�ł��B
% B �̃N���X�́AORDFILT2 �̉��Z�I�ȃI�t�Z�b�g�^���g���Ȃ�����A
% A �̃N���X�Ɠ����ł��B���̏ꍇ�AB �̃N���X�́Adouble �ł��B
%
% ����
% ----
% DOMAIN �́A�o�C�i���C���[�W���Z�ɑ΂��Ďg����\�������ꂽ�v�f�Ɠ���
% �ł��B����́A1��0�݂̂��܂ލs��ł��B���Ȃ킿�A1�̓t�B���^�����O���Z
% �ɑ΂��āA�ߖT���`���܂��B
%
% ���Ƃ��΁AB = ORDFILT2(A,5,ONES(3,3)) �́A3�s3��̃��f�B�A���t�B���^
% �����s���܂��B�܂��AB = ORDFILT2(A,1,ONES(3,3)) �́A3�s3��ɑ΂���
% �ŏ��l�����߂�t�B���^�ŁAB = ORDFILT2(A,9,ONES(3,3)) �́A�ő�l��
% ���߂�t�B���^�ł��BB = ORDFILT2(A,4,[0 1 0;1 0 1;0 1 0]) �́A�ߖT��
% �k�A���A��A���̒��̍ŏ��l��  A ���̗v�f�ƒu�������܂��B
%
% �Q�l�FMEDFILT2



%   Copyright 1993-2002 The MathWorks, Inc.  
