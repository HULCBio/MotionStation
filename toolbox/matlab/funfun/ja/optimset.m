% OPTIMSET   OPTIM OPTIONS�\���̂̍쐬/�ύX
%
% OPTIONS = OPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) �́A�w��
% �����p�����[�^�ƒl�̑g�����œK���I�v�V�����\����OPTIONS���쐬���܂��B
% �w�肳��Ă��Ȃ��p�����[�^�́A[] �ɐݒ肳��܂�( [] �̃p�����[�^�l�́A
% OPTIONS���œK���֐��ɓn�����Ƃ��Ƀf�t�H���g�l�𗘗p���܂�)�B�p��
% ���[�^����ӓI�Ɏ��ʂ��铪�������^�C�v���邾���Őݒ肷�邱�Ƃ��ł��܂��B
% �p�����[�^���̑啶���Ə������̋�ʂ͖�������܂��B
% 
% ����: ������̒l�́A�啶���Ə���������ʂ��銮�S�ȕ����񂪕K�v�ł��B
% �������Ȃ������񂪎w�肳�ꂽ�ꍇ�́A�f�t�H���g�l���g���܂��B
%   
% OPTIONS = OPTIMSET(OLDOPTS,'PARAM1',VALUE1,...) �́A�w�肵���l��
% �ύX���ꂽ�p�����[�^�l������ OLDOPTS �̃R�s�[���쐬���܂��B
%   
% OPTIONS = OPTIMSET(OLDOPTS,NEWOPTS) �́A�����̃I�v�V�����\����
% OLDOPTS �ƐV�K�̃I�v�V�����\���� NEWOPTS ���������܂��BNEWOPTS 
% �̋�̒l�łȂ��p�����[�^�́AOLDOPTS ���̑Ή�����Â��p�����[�^����
% �������܂��B
%   
% OPTIMSET �́A���͂Əo�͈�����ݒ肵�Ȃ��ꍇ�́A���ׂẴp�����[�^��
% �Ƃ����̎�蓾��l��\�����܂��B���̃I�v�V�������g���S�Ă̊֐��ɑ΂�
% �ăf�t�H���g�l�������ꍇ�́A�f�t�H���g�� {} �ɕ\�����܂��B����̊֐���
% �΂���I�v�V������\������ɂ́AOPTIMSET(OPTIMFUNCTION) �𗘗p��
% �܂��B
%
% OPTIONS = OPTIMSET �́A���͈�����ݒ肵�Ȃ��ꍇ�́A���ׂẴt�B�[
% ���h�� [] �ɐݒ肳��Ă���I�v�V�����\����OPTIONS���쐬���܂��B
%
% OPTIONS = OPTIMSET(OPTIMFUNCTION) �́AOPTIMFUNCTION�Ƃ���
% ���O�̍œK���֐��Ɋ֘A���邷�ׂẴp�����[�^���ƃf�t�H���g�l�����I
% �v�V�����\���̂��쐬���܂��B���Ƃ��΁A
%           optimset('fminbnd') 
% �܂���
%           optimset(@fminbnd)
% �́A�֐� 'fminbnd' �Ɋ֘A���邷�ׂẴp�����[�^���ƃf�t�H���g�l���܂�
% �I�v�V�����\���̂��o�͂��܂��B
% 
%
%MATLAB �� OPTIMSET PARAMETERS
%Display - �\�����x�� [ off | iter | notify | final ]
%MaxFunEvals - �֐��]���̉\�ȍő吔
%                     [ ���̐��� ]
%MaxIter - �J��Ԃ��\�ȍő吔 [ ���̃X�J���[ ]
%TolFun - �֐��l�̏I�����e�l [ ���̃X�J���[ ]
%TolX - X �� �I�����e�l [ ���̃X�J���[ ]
%FunValCheck - ���[�U���^�����֐�����ANaN �܂��� ���f���ȂǁA�����Ȓl���`�F�b�N

%              [ {off} | on ]
%OutputFcn - �C���X�g�[���ł���o�͊֐���  [ function ]
%          ���̏o�͊֐��́A�e�J��Ԃ��̌�A�\���o�ɂ��R�[������܂��B
%
% ����: OPTIMIZATION TOOLBOX �� OPTIMSET �p�����[�^�����邽�߂ɂ́A
%       (Optimization Toolbox ���C���X�g�[�����Ă���ꍇ), ���̂悤��
%       ���͂��Ă��������B
%             help optimoptions
%
% ���
%   fzero �̃f�t�H���g�̃I�v�V�������g�p���ăI�v�V�����𐶐�����ꍇ
%     options = optimset('fzero');
%   1e-3 �� TolFun �g�p���ăI�v�V�����\���̂𐶐�����ꍇ
%     options = optimset('TolFun',1e-3);
%   �I�v�V������ Display �l�� 'iter' �ɕύX����ꍇ
%     options = optimset(options,'Display','iter');
%
% �Q�l OPTIMGET, FZERO, FMINBND, FMINSEARCH, LSQNONNEG.

%   Copyright 1984-2003 The MathWorks, Inc.
  
