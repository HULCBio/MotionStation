% NORMXCORR2 ���K������2�����̑��ݑ���
%
% C = NORMXCORR2(TEMPLATE,A) �́A�s�� TEMPLATE�� A�̐��K���������ݑ��ւ�
% �v�Z���܂��B���K�����Ӗ��������߂ɂ́A�s�� A �́A�s�� TEMPLATE ���
% �傫���T�C�Y�ł��邱�Ƃ��K�v�ł��BTEMPLATE �̒l�́A�K�������A���ׂē���
% �ł͂���܂���B���ʂ̍s�� C �́A���֌W�����܂�ł��āA���͈̔͂́A
% -1.0����1.0�ł��B
%
% �N���X�T�|�[�g
% -------------
% ���͍s��́A�N���X logical�Auint8, uint16, double �̂����ꂩ�ł��B
% �o�͍s�� C �́Adouble �ł��B
%
% ���
% -------
%   T = .2*ones(11); % �Â��O���[�o�b�N�O�����h��ɖ��邢�O���[��������
%   T(6,3:9) = .6;   
%   T(3:9,6) = .6;
%   BW = T>0.5;      % ���̃o�b�N�O�����h��ɔ���������
%   imshow(BW), title('Binary')
%   figure, imshow(T), title('Template')
%   % �e���v���[�gT���I�t�Z�b�g����V�����C���[�W���쐬
%   T_offset = .2*ones(21); 
%   offset = [3 5];  % 3�s5��̃V�t�g
%   T_offset( (1:size(T,1))+offset(1), (1:size(T,2))+offset(2) ) = T;
%   figure, imshow(T_offset), title('Offset Template')
%   
%   % ���ݑ���BW�ƁA�I�t�Z�b�g���񕜂��邽�߂�T_offset  
%   cc = normxcorr2(BW,T_offset); 
%   [max_cc, imax] = max(abs(cc(:)));
%   [ypeak, xpeak] = ind2sub(size(cc),imax(1));
%   corr_offset = [ (ypeak-size(T,1)) (xpeak-size(T,2)) ];
%   isequal(corr_offset,offset) % 1 �́A�I�t�Z�b�g���񕜂��ꂽ���Ƃ��Ӗ����܂�
%
% �Q�l  CORRCOEF.


%   Copyright 1993-2002 The MathWorks, Inc.
