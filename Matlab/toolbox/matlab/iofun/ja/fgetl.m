% FGETL   �s�̏I�[�q�Ȃ��ŁA�t�@�C���̂��̍s��1�̕����Ƃ��ďo��
% 
% TLINE = FGETL(FID) �́A�w���q FID �����t�@�C���̂��̍s���AMATLAB
% ������Ƃ��ďo�͂��܂��B�s�̏I�[�q�͊܂܂�܂���B�s�̏I�[�q�t����
% ���̍s�𓾂邽�߂ɂ́AFGETS ���g���Ă��������B�t�@�C���̏I�[(EOF)
% �݂̂�����ꍇ�́A-1���o�͂���܂��B
%
% FGETL �́A�e�L�X�g�t�@�C���݂̂̎g�p���Ӑ}���Ă��܂��B���̍s������
% �L�����N�^�������Ȃ��o�C�i���t�@�C���̏ꍇ�́AFGETL �͎��s�Ɏ��Ԃ�
% ������܂��B
%
% ���
%       fid=fopen('fgetl.m');
%       while 1
%           tline = fgetl(fid);
%           if ~isstr(tline), break, end
%           disp(tline)
%       end
%       fclose(fid);
%
% �Q�l�FFGETS, FOPEN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:58:04 $
