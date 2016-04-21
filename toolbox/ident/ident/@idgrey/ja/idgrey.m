% IDGREY �́AIDGREY ���f���\�����쐬���܂��B
%       
%   M = IDGREY(MfileName,ParameterVector,CDmfile)
%   M = IDGREY(MfileName,ParameterVector,CDmfile,...
%              FileArgument,Ts,'Property',Value,..)
%
%   M: ���[�U��`�̐��`���f���\�����L�q���� IDGREY ���f���I�u�W�F�N�g��
%      ���ďo��
%
% MfileName �́A�\�����L�q����m-�t�@�C�����ł��B���̃t�H�[�}�b�g�ɂȂ�
% �Ă��܂��B
%
%     [A,B,C,D,K,X0] = MfileName(ParameterVector,Ts,FileArgument)
%
% �����ŁA�o�͂́A�C�m�x�[�V�����^�Ő��`�V�X�e�����L�q���܂��B
%
%      xn(t) = A x(t) + B u(t) + K e(t) ;      x(0) = X0
%       y(t) = C x(t) + D u(t) + e(t)
%
% �A�����Ԃł��A���U���Ԃł��K�p�ł��܂��B�����ŁA���U���Ԃł́A
% xn(t) = x(t+Ts)�ł���A�A�����Ԃł́Axn(t) = d/dt x(t)�ł��B
%    
% ParameterVector�́A���f���s������肷��m�~�i���̃p�����[�^��(��)�x�N 
% �g���ł��B �����́A���肷�鎩�R�p�����[�^�ɑΉ����Ă��܂��B
% 
% CDmfile�́A���[�U�̋L�q����m-�t�@�C���ŘA��/���U���ԃ��f�����ǂ̂悤��
% ��舵�������w�肵�܂��B
% 
%      CDmfile = 'c'�́A��ɁA�A�����ԃ��f���s����o�͂��郆�[�Um-�t�@�C��
%                ���Ӗ����ATs �𖳎����܂��B
%                �V�X�e���̃T���v�����O�́A�����ꂽ�f�[�^�C���^�[�T���v��
%                ����ɏ]���A�c�[���{�b�N�X�̓����I�ȃA���S���Y���ɂ��
%                �s���܂��B(DATA.InterSample)
%      CDmfile = 'cd' �́A���� Ts = 0 �̏ꍇ�A�A�����ԏ�ԋ�ԃ��f���s��
%                �ŁATs > 0 �̏ꍇ�A�T���v�����O�Ԋu Ts �œ����闣�U��
%                �ԃ��f���s����o�͂���m-�t�@�C�����Ӗ����܂��B
%                ���̏ꍇ�A�T���v�����O���[�`���̃��[�U�̑I���́A
%                �c�[���{�b�N�X�̓����I�ȃT���v�����O�̃A���S���Y����
%                �㏑�����܂��B
%      CDmfile = 'd'�́Am�t�@�C�����ATs �̒l�Ɉˑ�����A�܂��́A�S���ˑ����Ȃ�
%                ���̂ǂ��炩�̏�Ԃł̗��U���ԃ��f���̍s�����ɏo�͂��邱��
%                �������܂��B 
% FileArgument�́A����K�؂ȕ��@�Ŏg�p�����m-�t�@�C���ւ̃G�L�X�g���̈� 
% ���ł�(�f�t�H���g�́A[])�B
%
% Ts �́A���f���̃T���v�����O�Ԋu�ł��B
% �f�t�H���g: CDmfile = 'd' �̏ꍇ�ATs = 1 
%             CDmfile = 'c' �܂��� 'cd'�̏ꍇ�ATs = 0  (�A�����ԃ��f��)
%
% IDGREY �v���p�e�B�̏ڍׂɂ��ẮAIDPROPS IDGREY �œ����܂��B


%   Copyright 1986-2001 The MathWorks, Inc.
