% ADDFRAME   �r�f�I�t���[���� AVI �t�@�C���ɕt��
% 
% AVIOBJ = ADDFRAME(AVIOBJ,FRAME) �́AFRAME ���̃f�[�^�� AVIFILE �Ƃ���
% �쐬���ꂽAVIOBJ �֕t�����܂��BFRAME �́A�C���f�b�N�X�t���C���[�W(M�s
% N��)�A�܂��� double �� uint8 �̐��x�̃g�D���[�J���[�C���[�W(M�~N�~3)
% �̂����ꂩ�ɂȂ�܂��BFRAME �ŁA�ŏ��̃t���[���� AVI�t�@�C���ɕt������
% �Ȃ��ꍇ�A�O�̃t���[���̎����Ɛ����������K�v������܂��B
%   
% AVIOBJ = ADDFRAME(AVIOBJ,FRAME1,FRAME2,FRAME3,...) �́A�����̃t���[����
% ���AVI�t�@�C���ɕt�����܂��B
%
% AVIOBJ = ADDFRAME(AVIOBJ,MOV) �́AMATLAB���[�r�[ MOV �Ɋ܂܂ꂽ�t���[��
% ��AVI�t�@�C���ɕt�����܂��B�C���f�b�N�X�t���C���[�W�Ƃ��ăt���[����
% �X�g�A����MATLAB���[�r�[�́A�J���[�}�b�v���O�����Đݒ肳��Ă��Ȃ�
% �ꍇ�AAVI�t�@�C���p�̃J���[�}�b�v�Ƃ��čŏ��̃t���[�����g���܂��B
%
% AVIOBJ = ADDFRAME(AVIOBJ,H) �́Afigure�A�܂��͍��W���̃n���h�������
% �t���[�����L���v�`�����A���̃t���[����AVI�t�@�C���ɕt�����܂��B�t���[��
% �́AAVI�t�@�C���ɉ�������O�ɁA��ʊO�̔z����ɕ`�ʂ���܂��B����
% �V���^�b�N�X�́A�A�j���[�V�������̃O���t�� XOR �O���t�B�b�N�X��p����
% ����ꍇ�͎g���܂���B
%
% �A�j���[�V������ XOR �O���t�B�b�N�X��p���Ă���ꍇ�AMATLAB���[�r�[
% �̂���t���[���̒��ɃO���t�B�b�N�X��\���������� GETFRAME ��p����
% ���̗�Ɏ����悤�ɁA�V���^�b�N�X [AVIOBJ] = ADDFRAME(AVIOBJ,MOV) ��
% �g���܂��BGETFRAME �́A��ʏ�̃C���[�W�̃X�i�b�v�V���b�g���B��܂��B
% 
%    fig=figure;
%    set(fig,'DoubleBuffer','on');
%    set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%        'nextplot','replace','Visible','off')
%    aviobj = avifile('example.avi')
%    x = -pi:.1:pi;
%    radius = [0:length(x)];
%    for i=1:length(x)
%     h = patch(sin(x)*radius(i),cos(x)*radius(i),[abs(cos(x(i))) 0 0]);
%     set(h,'EraseMode','xor');
%     frame = getframe(gca);
%     aviobj = addframe(aviobj,frame);
%    end
%    aviobj = close(aviobj);
%
% �Q�l�FAVIFILE, AVIFILE/CLOSE, MOVIE2AVI.


%   Copyright 1984-2002 The MathWorks, Inc.
