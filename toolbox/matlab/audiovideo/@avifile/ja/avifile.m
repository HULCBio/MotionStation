% AVIFILE   �V���� AVI �t�@�C�����쐬
%
% AVIOBJ = AVIFILE(FILENAME) �́A�f�t�H���g�p�����[�^�l������ AVIFILE 
% �I�u�W�F�N�g AVIOBJ ���쐬���܂��BFILENAME ���g���q���܂�ł��Ȃ��ꍇ�A
% '.avi' ���g���܂��BAVIFILE �ɂ���ĊJ���ꂽ�t�@�C�������ɂ́A
% AVIFILE/CLOSE ���g���܂��B���ׂĂ̊J���ꂽAVI�t�@�C�������ɂ́A
% "clear mex" ���g���Ă��������B
%
% AVIOBJ = AVIFILE(FILENAME,'PropertyName',VALUE,'PropertyName',VALUE,...)
% �́A�w�肵���v���p�e�B�l������ AVIFILE �I�u�W�F�N�g���o�͂��܂��B
%
% AVIFILE �p�����[�^
%
% FPS         - AVI���[�r�[�p�̕b���̃t���[���B���̃p�����[�^�́AADDFRAME
%               ���g�p����O�ɐݒ肳��Ă��Ȃ���΂Ȃ�܂���B�f�t�H���g
%               �́A15 fps �ł��B
%
% COMPRESSION - ���k�ɗp������@���w�肷�镶����ł��BUNIX�ł́A���̒l��
%               'None' �łȂ���΂Ȃ�܂���BWindows�p�̗��p�\�ȃp�����[�^
%               �́A'Indeo3', 'Indeo5', 'Cinepak', 'MSVC', 'RLE', 'None'
%               �̂����ꂩ�ł��B���[�U�̈��k�@���g�p����ꍇ�A�l�� codec 
%               �h�L�������g�Ŏw�肳�ꂽ4�̃L�����N�^�R�[�h���g���܂��B
%               �w�肳�ꂽ���[�U�̈��k�@��������Ȃ��ꍇ�AADDFRAME ��
%               �R�[�����Ă���ԂɃG���[�ɂȂ�܂��B���̃p�����[�^�́A
%               ADDFRAME ���g�p����O�ɐݒ肳��Ă��Ȃ���΂Ȃ�܂���B
%               �f�t�H���g�́AWindows�� 'Indeo5'�ŁAUNIX�ł� 'None' �ł��B
%
% QUALITY      - 0����100�̊Ԃ̐��B���̃p�����[�^�͈��k����Ă��Ȃ�
%                ���[�r�[�ɂ͉e�����܂���B���̃p�����[�^�́AADDFRAME
%                ���g�p����O�ɐݒ肳��Ă��Ȃ���΂Ȃ�܂���B�����l�́A
%                �����r�f�I�掿�ł��傫�ȃt�@�C���T�C�Y�ɂȂ�A�Ⴂ
%                �l�́A�Ⴂ�r�f�I�掿�ŏ����ȃt�@�C���ł�菬���ȃt�@�C��
%                �T�C�Y�ɂȂ�܂��B�f�t�H���g��75�ł��B
%
% KEYFRAME     - �ꎞ�I�Ȉ��k���T�|�[�g���鈳�k�@�ɑ΂��āA���̃p�����[�^
%                �́A�P�ʎ���(�b)������̃L�[�t���[�����ł��B���̃p�����[�^
%                �́AADDFRAME ���g�p����O�ɐݒ肳��Ă��Ȃ���΂Ȃ�܂���B
%                �f�t�H���g�͖��b2�t���[���ł��B
%
% COLORMAP     - �C���f�b�N�X�t��AVI���[�r�[�ɑ΂��Ďg�p�����J���[�}�b�v
%                ���`����M�s3��̍s��ł��BM ��256��菬�������łȂ����
%                �Ȃ�܂���(Indeo ���k��236�ł�)�B���̃p�����[�^�́AMATLAB
%                �̃��[�r�[�V���^�b�N�X�Ƃ��� ADDFRAME ���g���ȊO�ł́A
%                ADDFRAME ���R�[�������O�ɐݒ肳��Ă��Ȃ���΂Ȃ�܂���B
%                �f�t�H���g�̃J���[�}�b�v�͂���܂���B
%
% VIDEONAME    - �r�f�I�X�g���[���p�̋L�q���B���̃p�����[�^�́A64�L�����N�^
%                ��菬�����Ȃ���΂Ȃ�܂���B�����āAADDFRAME ���g�p
%                ����O�ɐݒ肷��K�v������܂��B�f�t�H���g�̓t�@�C�����ł��B
%
%
% AVIFILE �v���p�e�B�́AMATLAB�\���̃V���^�b�N�X��p���Đݒ�ł��܂��B
% �Ⴆ�΁A���̃V���^�b�N�X���g���� Quality �v���p�e�B��100��ݒ肵�܂��B
%
%      aviobj = avifile(filename);
%      aviobj.Quality = 100;
%
% 
% ���:
%
%      fig=figure;
%      set(fig,'DoubleBuffer','on');
%      set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%      	   'NextPlot','replace','Visible','off')
%      mov = avifile('example.avi')
%      x = -pi:.1:pi;
%      radius = [0:length(x)];
%      for i=1:length(x)
%      	h = patch(sin(x)*radius(i),cos(x)*radius(i),[abs(cos(x(i))) 0 0]);
%      	set(h,'EraseMode','xor');
%      	F = getframe(gca);
%      	mov = addframe(mov,F);
%      end
%      mov = close(mov);
%
% �Q�l : AVIFILE/ADDFRAME, AVIFILE/CLOSE, MOVIE2AVI.


%   Copyright 1984-2002 The MathWorks, Inc.
