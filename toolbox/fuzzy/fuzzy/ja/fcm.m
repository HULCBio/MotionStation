% FCM �t�@�W�Bc-means �N���X�^�����O�ɂ��f�[�^�Z�b�g�̃N���X�^�����O
%
% [CENTER, U, OBJ_FCN] = FCM(DATA, N_CLUSTER) �́A�f�[�^�Z�b�gDATA����
% N_CLUSTER�̃N���X�^���������܂��BDATA��M�sN��̃T�C�Y�̏ꍇ�AM��
% �f�[�^�|�C���g���AN�͊e�f�[�^�|�C���g�̍��W���ɂȂ�܂��B�e�N���X�^�[
% �Z���^�̍��W�́ACENTER�s��̗�ɏo�͂���܂��B�����o�V�b�v�֐��s��U��
% �e�N���X�^�̊e�f�[�^�|�C���g�̃����o�V�b�v�̃O���[�h���܂݂܂��B
% 0��1�̒l�́A�m�[�����o�V�b�v�A�t�������o�V�b�v���Ӗ����܂��B�O���[�h��
% 0����1�̊Ԃ̒l�ŁA�f�[�^�|�C���g���N���X�^���ɕ��������o�V�b�v��������
% �����܂��B�e�J��Ԃ��ɂ����āA�ړI�֐����ŏ��ɂ���œK�ȃN���X�^�ʒu��
% �������܂��B���ʂ�OBJ_FCN�ɏo�͂���܂��B
% 
% [CENTER, ...] = FCM(DATA,N_CLUSTER,OPTIONS) �̓N���X�^�����O�v���Z�X
% �̃I�v�V�����x�N�g�����w�肵�܂��B
% OPTIONS(1) : �����s��U�ɑ΂���x�L��(�f�t�H���g: 2.0)
% OPTIONS(2) : �J��Ԃ��̍ő��(�f�t�H���g: 100)
% OPTIONS(3) : ���Ǔx�ɂ��I����l(�f�t�H���g: 1e-5)
% OPTIONS(4) : �J��Ԃ��񐔂̕\��(�f�t�H���g: 1)
% �N���X�^�����O�v���Z�X�́A�J��Ԃ��̍ő�񐔂ɓ��B�������_�A�܂��͖ړI
% �֐��̉��P�����Ǔx�ɂ��I����l�Ŏw�肵���l��菬�����ꍇ�I�����܂��B
% �f�t�H���g�l�̗��p�ɂ�NaN�𗘗p���܂��B
% 
% ��
%       data = rand(100,2);
%       [center,U,obj_fcn] = fcm(data,2);
%       plot(data(:,1), data(:,2),'o');
%       hold on;
%       maxU = max(U);
%       % Find the data points with highest grade of membership in cluster 1
%       index1 = find(U(1,:) == maxU);
%       % Find the data points with highest grade of membership in cluster 2
%       index2 = find(U(2,:) == maxU);
%       line(data(index1,1),data(index1,2),'marker','*','color','g');
%       line(data(index2,1),data(index2,2),'marker','*','color','r');
%       % Plot the cluster centers
%       plot([center([1 2],1)],[center([1 2],2)],'*','color','k')
%       hold off;
%
% �Q�l    FCMDEMO, INITFCM, IRISFCM, DISTFCM, STEPFCM.



%   Copyright 1994-2002 The MathWorks, Inc. 
