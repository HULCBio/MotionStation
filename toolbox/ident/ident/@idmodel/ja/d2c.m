%D2C �́A���f����A�����Ԍn�ɕϊ����܂��B
%
% MC = D2C(MD)
%
% MD: IDMODEL �I�u�W�F�N�g�Ƃ��ė^�����闣�U���ԃ��f��
% MC: IDMODEL ���f���I�u�W�F�N�g MD �̘A�����ԕϊ��n
%
% �ϊ��́A���f���𐄒肵���f�[�^�̓��͂̓����T���v���̋����Ɉˑ����A
% '�[�����z�[���h' ���A'�ꎟ�z�[���h'���g�p���܂��B(IDDATA �I�u�W�F�N�g
% �� 'InterSample' �v���p�e�B�́AMD.EstimationInfo �� 'DataInterSample'
% �t�B�[���h�ɋL�^����Ă��܂�)
% ���肳��Ȃ����f���ɑ΂��ẮA'zoh' ���g���܂��B
%
% ���͈������� 'ZOH'�A�܂��� 'FOH' ���܂܂��ƁA�����̃f�t�H���g��
% �㏑������܂��B
%
% ���f�� MD ��������� (nk>1) ����̒x�������ꍇ�A�x��������������A
% �ϊ���̃��f�� MC ��(�����Ȃނ�����) 'InputDelay' �Ƃ��ĕt������܂��B
%
% IDPOLY ���f���́AIDPOLY ���f���ŏo�͂���܂��B
% IDSS ���f���́AIDSS ���f���ŏo�͂���܂����A'Structured' �p�����g��
% �[�[�V������ 'Free' �ɕύX����܂��B
% IDGREY ���f���́A'CDmfile' == 'cd' �̏ꍇ IDGREY�ŏo�͂���A���̑���
% �ꍇ IDSS �ŏo�͂���܂��B
%
% IDPOLY ���f���ɑ΂��āAMD �̋����U�s�� P �͐��l�����𗘗p���ĕϊ�����
% �܂��B�����̂��߂ɗ��p�����X�e�b�v�T�C�Y�́AM�t�@�C�� NUDERST �ŗ^
% �����܂��BIDSS, IDARX, IDGREY ���f���ɑ΂��āA�����U�s��͈ێ�����
% �܂����A���o�̓v���p�e�B�Ɋւ��鋤���U��񂪕t������܂��B
%
% �����U���̕ϊ���}������(�ꍇ�ɂ���Ă͕K�v��������܂���)���߂�
% �́AD2C(MD,'CovarianceMatrix','None') �𗘗p���܂��B�C�ӂ̏ȗ��`����
% �\�ł���A���l�̌��ʂ𓾂邽�߂ɁAD2C �����s����O�ɁA
% SET(MD,'Cov','No') �����s���Ă������Ƃ��ł��܂��B
%
% �x�����ߎ����邽�߂ɁA�ނ����ԂƂ��ĕt����������A���̂悤�ɗ��p
% ���܂��B
%     D2C(MD,'InputDelay',0)
% �C�ӂ̕��@�ŁA('Cov','None') �𕹗p���邱�Ƃ��ł��܂��B
%
% Control System Toolbox ���C���X�g�[������Ă���ꍇ�A
%     MC = D2C(MD,METHOD)
% �𗘗p���邱�Ƃ��ł��܂��B�����ŁAMETHOD �́A'tustin', 'prewarp', 
% 'matched' �̂����ꂩ�ł���A�ϊ��́A�Ή������@�𗘗p���܂��B
% HELP SS/D2C ���Q�Ƃ��Ă��������B�����U���͕ϊ�����܂���B
%
% ����: �ϊ��͈������ɂȂ�܂��B���̎��ɂƌ��_�ɁA1�̋ɂ����������N��
%       ���܂��B�}�j���A�����Q�Ƃ��Ă��������B
%
%   �Q�l:  IDMODEL/C2D


%   L. Ljung 10-1-86,4-20-87,8-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
