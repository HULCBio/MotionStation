% AR �́A��X�̃A�v���[�`���g���āA�M���� AR ���f�����v�Z���܂��B
%   Model = AR(Y,N)    
%   TH = AR(Y,N,Approach)  
%   TH = AR(Y,N,Approach,Win)
%
%   Model: AR ���f���̐��肵���p�����[�^���g���āAIDPOLY ���f���Ƃ��ďo
%          �͂���܂��B�ڍׂ́AHELP IDPOLY ���Q�ƁB
%
%   Y    : ���f�����Ɏg�p���鎞�n��ŁAIDDATA �I�u�W�F�N�g�ł�(HELP ID-
%           DATA���Q��)�B
%   N    : AR-���f���̎���
%   Approach: �g�p�����@�ŁA���̂����ꂩ��I�����Ă��������B
%      'fb' : �O���A����A�v���[�`(�f�t�H���g)
%      'ls' : �ŏ����@
%      'yw' : Yule-Walker �@
%      'burg': Burg �@
%      'gl' : �􉽊w�I�i�q�@
%    �㔼2�́A���ˌW���Ƒ����֐����A[Model ,REFL] = AR(y,n,approach) 
%    �̌^�ŁA���� REFL �ɏo�͂���܂��B��̈����̍Ō��0��t������(����
%    ���΁A'burg0')�ƁA�����U�̌v�Z���ȗ�����܂��B
%   Win    : �g�p����E�C���h�E�ŁA���̂����ꂩ��I�����Ă��������B
%      'now' : �E�C���h�E���g�p���Ȃ�(approach='yw' �̂Ƃ��ȊO�́A�f�t�H
%              ���g)
%      'prw' : �����̑O�ɃE�C���h�E��K�p
%      'pow' : �����̌�ɃE�C���h�E��K�p
%      'ppw' : �����̑O�ƌ�ɃE�C���h�E��K�p
%
% �v���p�e�B/�l�̑g�Ƃ��ẮA'MaxSize'/maxsize �� 'Ts'/Ts �́A�v���p�e�B
% MaxSize��ݒ肵(IDPROPS ALG���Q��)�A�f�[�^�̃T���v�����O�Ԋu���㏑������
% ���߂ɁA�ǉ��\�ł��B
% ��FModel = AR(Y,N,Approach,'MaxSize',500)�B
%
% �Q�l�F IVAR 
%        ���o�͂̏ꍇ�́AARX �� N4SID



%   Copyright 1986-2001 The MathWorks, Inc.
