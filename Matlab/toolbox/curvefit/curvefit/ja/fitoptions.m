% FITOPTIONS  Fit options �I�u�W�F�N�g�̍쐬/�C��
% F = FITOPTIONS(LIBNAME) �́A���C�u�������f�� LIBNAME �ɑ΂��āA�f�t�H
% ���g�l���I�v�V�����p�����[�^�Ƃ��Ďg���āAfitoptions �I�u�W�F�N�g F 
% ���쐬���܂��BLIBNAME �̏ڍ׏��́ACFLIBHELP ���Q�Ƃ��Ă��������B
%
% F = FITOPTIONS(LIBNAME,'PARAM1',VALUE1,'PARAM2',VALUE2,...) �́A���C�u
% �������f�� LIBNAME �ɑ΂��āA�w�肵���p�����[�^�Ɏw�肵���l���g���āA�f
% �t�H���g�� fitoptions �I�u�W�F�N�g���쐬���܂��B
%
% F = FITOPTIONS('METHOD',VALUE) �́AVALUE �Ŏw�肵�����@���g���āA�f�t�H
% ���g�� fitoptions �I�u�W�F�N�g���쐬���܂��BVALUE �őI���\�Ȓl�́A��
% ���̂��̂ł��B
%
%      NearestInterpolant     - �ŋߖT���}
%      LinearInterpolant      - ���`���}
%      PchipInterpolant       - �敪�I�L���[�r�b�N�G���~�[�g���}
%      CubicSplineInterpolant - �L���[�r�b�N�X�v���C�����}
%      SmoothingSpline        - �������X�v���C�� 
%      LinearLeastSquares     - ���`�ŏ����
%      NonlinearLeastSquares  - ����`�ŏ����
%
% VALUE �ւ̓��͂́A���ׂĂ̕�������͂���K�v�͂Ȃ��A���j�[�N�Ɏ��ʂł�
% �镶�����ŏ\���ł��B�܂��A�啶���A�������̋�ʂ͂���܂���B
%
% F = FITOPTIONS('METHOD',VALUE1,'PARAM2',VALUE2,...) �́A�f�t�H���g�� 
% fitoptions �I�u�W�F�N�g�ɑ΂��āA�ݒ肵���p�����[�^���ɑ΂��āAVAL-
% UE... �Őݒ肵���l�ŏ��������܂��B
%
% F = FITOPTIONS(OLDF,NEWF) �́A������ fitoptions �I�u�W�F�N�g OLDF �ƐV
% ���� fitoptions �I�u�W�F�N�g NEWF ��g�ݍ��킹�܂��BOLDF �� NEWF ���A
% ����'Method' �̏ꍇ�A��łȂ��l������ NEWF �̒��̂������̃p�����[�^
% �́AOLDF �̒��̑Ή�����Â��p�����[�^�����������܂��BOLDF �� NEWF ����
% �Ȃ�'Method' �����ꍇ�AF �́AOLDF �Ɠ��� Method �������ANEWF �� 'Nor-
% malize', 'Exclude', 'Weights' �t�B�[���h���AOLDF �̂��̂ɑ���A�g��
% ��܂��B
%
% F = FITOPTIONS(OLDF,'PARAM1',VALUE1,'PARAM2',VALUE2,...) �́Afitoptions
% �I�u�W�F�N�g OLDF �ɑ΂��āA�w�肵���p�����[�^�ƒl�ŏ������������̂ŁA�V
% ���� fitoptions �I�u�W�F�N�g���쐬���܂��B
%
% F = FITOPTIONS �́A���ׂẴt�B�[���h���f�t�H���g�l�ɐݒ肳��AMethod 
% �p�����[�^���A'None' �ł��� fitoptions �I�u�W�F�N�g F ���쐬���܂��B
%
% ���ׂĂ� FITOPTIONS �I�u�W�F�N�g�́A���̃p�����[�^�������Ă��܂��B
%
%    Normalize - �f�[�^�̒��S���ړ�������A�X�P�[�����O���邩�ۂ���ݒ�
%                 [{'off'} | 'on']
%    Exclude   - �f�[�^���폜�����x�N�g�����I���W�i���f�[�^�Ɠ���������
%                �x�N�g���ɂ���
%                [{[]} | �폜�����v�f����1�ɐݒ肵���_���x�N�g��]
%    Weights   - �f�[�^�Ɠ��������̏d�݃x�N�g��
%                [{[]} | ���̗v�f�����x�N�g��] 
%    Method    - FIT �Ŏg�p���� Method
%
% Method �l�Ɉˑ����āAfitoptions �I�u�W�F�N�g�́A���̃p�����[�^������
% �Ƃ��ł��܂��B
%
% Method ���ANearestInterpolant, LinearInterpolant, PchipInterpolant, Cu-
% bicSplineInterpolant �̂����ꂩ�̏ꍇ�A�t���I�ȃp�����[�^�͂���܂���B
%
% Method ���ASmoothingSpline �̏ꍇ�A���̕t���I�ȃp�����[�^�����݂��܂��B
%      SmoothingParam - �������p�����[�^ [{NaN} | [0,1] �̊Ԃ̒l]
%                       NaN �́AFIT �̊ԁA�v�Z����邱�Ƃ��Ӗ����܂��B
%
% Method ���ALinearLeastSquares �̏ꍇ�A���̕t���I�ȃp�����[�^�����݂�
% �܂��B
%
%      Robust    - ���o�X�g��@���g�p���邩�ۂ� [{'off'} | 'on']
%      Lower     - �ߎ�����W���ɓK�p���鉺���p�̃x�N�g��
%                  [{[]} | �W���̐��𒷂��Ƃ���x�N�g��]
%      Upper     - �ߎ�����W���ɓK�p���鋛�E���p�̃x�N�g��
%                  [{[]} | �W���̐��𒷂��Ƃ���x�N�g��]
%
% Method ���ANonlinearLeastSquares �̏ꍇ�A���̕t���I�ȃp�����[�^����
% �݂��܂��B
%
%      Robust    - ���o�X�g��@���g�p���邩�ۂ� [{'off'} | 'on']
%      Lower     - �ߎ�����W���ɓK�p���鉺���p�̃x�N�g��
%                  [{[]} | �W���̐��𒷂��Ƃ���x�N�g��]
%      Upper     - �ߎ�����W���ɓK�p���鋛�E���p�̃x�N�g��
%                  [{[]} | �W���̐��𒷂��Ƃ���x�N�g��]
%     StartPoint    - FIT ���ŁA�X�^�[�g�_��v�f�Ƃ���x�N�g��
%                     [{[]} | �W���̐��𒷂��Ƃ���x�N�g��]
%     Algorithm     - FIT �Ɏg�p����A���S���Y��
%                     [{'Levenberg-Marquardt'} | 'Gauss-Newton' | 
%                      'Trust-Region']
%     DiffMaxChange - �L�������ŁA�W���ɓK�p�\�ȍő�ω���
%                     ���z [���̃X�J�� | {1e-1}]
%     DiffMinChange - �L�������ŁA�W���ɓK�p�\�ȍŏ��ω���
%                     ���z [���̃X�J�� | {1e-8}]
%     Display       - �\�����x�� ['off' | 'iter' | {'notify'} | 'final']
%     MaxFunEvals   - �֐�(���f��)�̌v�Z�̋��e�ő��
%                     [���̐���]
%     MaxIter       - �J��Ԃ��v�Z�̋��e�ő��[���̐���]
%     TolFun        - �֐�(���f��)�l�Ɋւ���I���Ɋւ���g�������X
%                     [���̃X�J�� | {1e-6}]
%     TolX          - �W���Ɋւ���I���g�������X
%                     [���̃X�J�� | {1e-6}]
%
% ���ׂĂ̕�������͂���K�v�͂Ȃ��A���j�[�N�Ɏ��ʂł��镶�����ŏ\���ł��B
% �܂��A�啶���A�������̋�ʂ͂���܂���B
%
% �Q�l FITTYPE, CFLIBHELP

% $Revision: 1.2.4.2 $
%   Copyright 2001-2004 The MathWorks, Inc.
