% PRINT   Figure�܂��̓��f���̈���B�C���[�W�܂���M-�t�@�C���Ƃ���
%         �f�B�X�N�ɕۑ�
%
% �\��:
%   print 
% PRINT�́A�J�����g��figure�����[�U�̃J�����g�̃v�����^�ɑ���܂��B�v��
% ���g�o�͂̑傫���ƌ`�́AFigure��PaperPosiotn[mode]�v���p�e�B�ƃ��[�U��
% PRINTOPT.M�t�@�C���Ŏw�肵���f�t�H���g��print�R�}���h�ɂ��قȂ�܂��B
% 
%   print -s
% 
% ��L�Ɠ����ł����A�J�����g��Simulink���f����������܂��B
%
%   print -device -options 
% 
% �I�v�V�����Ƃ��ăv�����g�f�o�C�X(tiff��PostScript�̂悤�ȏo�̓t�H�[�}
% �b�g��A�v�����^�ɑ�������̂𐧌䂷��v�����g�h���C�o)��A�v�����g
% �����t�@�C���̎�X�̓���(�𑜓x�A�v���r���[�̃^�C�v�A�������Figure
% ��)�𐧌䂷��I�v�V�������w��ł��܂��B�g�p�\�ȃf�o�C�X�ƃI�v�V����
% �����L�Ɏ����܂��B
%
%   print -device -options filename
% 
% �t�@�C�������w�肵���ꍇ�AMATLAB�̓v�����^�̑���Ƀt�@�C���ɏo�͂���
% ���BPRINT�́A�t�@�C���g���q���w�肵�Ȃ���΁A�K�؂Ȃ��̂�ǉ����܂��B
%
%   print( ... )
% 
% ��L�Ɠ����ł����A����́APRINT��MATLAB�R�}���h�Ƃ��Ăł͂Ȃ��AMATLAB
% �֐��Ƃ��ČĂяo���܂��B�����̈Ⴂ�́A���ʂ̕t�����������X�g������
% �ۂ��ł��B�C�ӂ̓��͈����ɑ΂��ĕϐ���n�����Ƃ��ł��܂��B���ɁA�����
% ��figure�⃂�f���̃n���h����t�@�C������n���̂ɖ𗧂��܂��B
% 
% ����: 
% PRINT�́AResizeFcn�v���p�e�B��������figure���������ꍇ�́A���[�j���O
% ��\�����܂��B ���[�j���O���������ɂ́APaperPositionMode�v���p�e�B��
% 'auto'�ɂ��邩�A�܂��́A"PageSetup"�_�C�A���O�ŁA�t�B�M���A�̃X�N���[
% �������킹��悤�ɐݒ肵�Ă��������B
%
% �o�b�`����:
% PRINT�̊֐��`�����g�����Ƃ��ł��܂��B����́A�o�b�`����ɗL���ł��B
% ���Ƃ��΁A�ʂ̃O���t���쐬����̂�for���[�v���g������A����z��Ɋi�[
% ����Ă����A�̃t�@�C������������邱�Ƃ��ł��܂��B
%
%     for i = 1:length(fnames)
%         print('-dpsc','-r200',fnames(i))
%     end
%            
% �������E�B���h�E�̎w��
% 
%   -f<handle>   % �������Figure��Handle Graphics�̃n���h��
%   -s<name>     % ����p�ɃI�[�v�����Ă���Simulink���f����
%   h            % PRINT�̊֐��`�����g���Ƃ���Figure�܂��̓��f���̃n���h��
% 
% ���:
% print -f2      % �����̃R�}���h���APRINTOPT�Ŏw�肳�ꂽ�f�t�H���g��
% print( 2 )     % �h���C�o�ƃI�y���[�e�B���O�V�X�e���R�}���h���g���āA
%                  Figure 2��������܂��B
%
% print -svdp    % vdp�Ƃ������O�̃I�[�v�����Ă���Simulink���f�����v�����g
%                  ���܂��B
%
% �o�̓t�@�C���̎w��:
% <filename>     % �R�}���h���C���̕�����
% '<filename>'   % PRINT�̊֐��`�����g���Ƃ��ɓn����镶����
% 
% ���:
%
%     print -deps foo
%     fn = 'foo'; print( gcf�A'-deps'�Afn )
% 
% ���ҋ��Ƃ��J�����g��figure���A�J�����g�̍�ƃf�B���N�g������'foo.eps'
% �Ƃ����t�@�C���ɕۑ����܂��BEPS�t�@�C���́AWord�h�L�������g�⑼�̃��[
% �h�v���Z�b�T�ɑ}�����邱�Ƃ��ł��܂��B
%
% ���ʂ̃f�o�C�X�h���C�o
% �o�͌`���́A�f�o�C�X�h���C�o���͈����Ŏw�肳��܂��B���̈����́A'-d'��
% ��n�܂�A���̃J�e�S���̂�����1�ɊY�����܂��B
% 
% Microsoft Windows�V�X�e���̃f�o�C�X�h���C�o�I�v�V����:
% 
%     -dwin      % figure�����m�N���ŃJ�����g�v�����^�ɑ���
%     -dwinc     % figure���J���[�ŃJ�����g�v�����^�ɑ���
%     -dmeta     % figure��Metafile�t�H�[�}�b�g�ŃN���b�v�{�[�h(�܂���
%                  �t�@�C��)�ɑ���
%     -dbitmap   % figure���r�b�g�}�b�v�t�H�[�}�b�g�ŃN���b�v�{�[�h
%                  (�܂��̓t�@�C��)�ɑ���
%     -dsetup    % Print Setup�_�C�A���O�{�b�N�X�𗧂��グ�邪�A�����
%                  �s��Ȃ�
%     -v         % Verbose���[�h�ŁA�ʏ�͕\������Ȃ�Print�_�C�A���O
%                  �{�b�N�X�𗧂����
%
% MATLAB�ɑg�ݍ��܂�Ă���h���C�o:
% 
%     -dps       % �����v�����^�ɑ΂���PostScript
%     -dpsc      % �J���[�v�����^�ɑ΂���PostScript
%     -dps2      % Level 2�̔����v�����^�ɑ΂���PostScript
%     -dpsc2     % Level 2�̃J���[�v�����^�ɑ΂���PostScript
%
%     -deps      % Encapsulated PostScript 
%     -depsc     % Encapsulated Color PostScript
%     -deps2     % ���x��2��Encapsulated PostScript
%     -depsc2    % ���x��2�̃J���[Encapsulated PostScript
% 
%     -dhpgl     % Hewlett-Packard 7475A �v���b�^�݊���HPGL 
%     -dill      % Adobe Illustrator 88�݊��C���X�g���[�V�����t�@�C��
%     -djpeg<nn> % �i�����x��nn��JPEG �C���[�W(Figure�E�B���h�E�̂݁A
%                  -loose���Ӗ����܂�)�B���Ƃ��΁A-djpeg90 ���i�����x��
%                  90�ł��Bnn���ȗ������ƁA�i�����x���̃f�t�H���g��75
%                  �ł��B
%     -dtiff     % packbits(lossless run-length encoding)���k���g����
%                  TIFF(Figure�E�B���h�E�̂݁A-loose���Ӗ����܂�)
%     -dtiffnocompression �@�@
%                % ���k���g��Ȃ�TIFF (Figure�E�B���h�E�̂݁A-loose����
%                  �����܂�)
%     -dpng      % Portable Network Graphic 24�r�b�g�g�D���[�J���[�C���[
%                  �W(Figure�E�B���h�E�̂݁A-loose���Ӗ����܂�)    
% 
% ���̏o�͌`���́AMATLAB���񋟂���GhostScript�A�v���P�[�V�������g������
% �ɂ���ĉ\�ł��B���S�ȏo�͌`���̃��X�g�́A�R�}���h
% 'help private/ghostscript'���g���āAGHOSTSCRIPT�̃I�����C���w���v��
% �Q�Ƃ��Ă��������B
% GhostScript�ŃT�|�[�g����Ă���f�o�C�X�h���C�o�̗���ȉ��Ɏ����܂��B
% 
%     -dljet2p   % HP LaserJet IIP
%     -dljet3    % HP LaserJet III
%     -ddeskjet  % HP DeskJet��DeskJet Plus
%     -dcdj550   % HP Deskjet 550C
%     -dpaintjet % HP PaintJet color printer
%     -dpcx24b   % 24�r�b�g�J���[PCX�t�@�C���t�H�[�}�b�g�A
%                  3���8�r�b�gplanes
%     -dppm      % Portable Pixmap (plain�`��)
%
% ���:
%     print -dwinc  % �J�����g��Figure���J���[�ŃJ�����g�̃v�����^��
%                     ���
%     print( h�A'-djpeg'�A'foo') % Figure/���f��h ��foo.jpg�Ɉ��
%
% �v�����g�I�v�V����
% PostScript��GhostScript�h���C�o�ł̂ݎg�p�����I�v�V�������ȉ��Ɏ���
% �܂��B
%     -loose     % Figure��PaperPosition��PostScript BoundingBox�Ƃ��Ďg
%                  �p���܂��B
%     -append    % �O���t��PostScript�t�@�C���ɏ㏑�������ɒǉ����܂��B
%     -tiff      % TIFF�v���r���[��ǉ����܂��BEPS�t�@�C���̂�(-loose��
%                  �Ӗ����܂�)
%     -cmyk      % RGB�̑����CMYK�J���[���g�p���܂��B
%     -adobecset % Adobe PostScript�W���L�����N�^�Z�b�g�G���R�[�h���g�p
%                  ���܂��B
%
% PostScript�AGhostScript�ATiff�AJpeg�̃I�v�V����:
%     -r<number>  %�C���`������̃h�b�g���ŕ\�킷�𑜓x�BSimulink�̃f�t
%                  �H���g��90�ŁATiff��Jpeg�C���[�W����Figure��Zbuffer��
%                  �[�h�ł̈���̃f�t�H���g��150�ł��B����ȊO��864�ł��B
%                  �X�N���[���̉𑜓x���w�肷��ɂ́A-r0���g�p���Ă�����
%                  ���B
% 
% ���:
%     print -depsc -tiff -r300 matilda 
%
% �J�����g�� Figure ��300 dpi�� TIFF �v���r���[(Simulink ���f���ɑ΂��� 
% 72 dpi, figure �ɑ΂���150 dpi )���g���ăJ���[EPS�� matilda.eps �ɕۑ�
% ���܂��B���� TIFF �v���r���[�́Amatilda.eps �� Word�h�L�������g���� 
% Picture �Ƃ��đ}�������Ε\������܂����AWord�h�L�������g�� PostScript 
% �v�����^�ň�����ꂽ�ꍇ�́AEPS ���g�p����܂��B
%
% figure�E�B���h�E�ɑ΂��鑼�̃I�v�V����:
%     -Pprinter  % �v�����^���w��BWindows �� Unix �Ŏg�p�B
%     -noui      % UI�R���g���[���I�u�W�F�N�g��������܂���
%     -painters  % ����̂��߂̕`��́APainters���[�h�ōs���܂�
%     -zbuffer   % ����̂��߂̕`��́AZ-Buffer���[�h�ōs���܂�
%     -opengl    % ����̂��߂̕`��́AOpenGL ���[�h�ōs���܂��B
% figure�̈������Renderer�̒��ӂƂ��āAMATLAB�̓X�N���[����Ɠ���
% Renderer����Ɏg���킯�ł͂���܂���B����́A�������Ɉ˂���̂ł��B
% ���̂��߁A������ꂽ�o�͂����̗��R�ɂ��X�N���[����ƈقȂ�ꍇ��
% ����܂��B���̂悤�ȏꍇ��-zbuffer�A�܂��́A-opengl ���w�肷��ƁA
% �X�N���[�����G�~�����[�g����o�͂�^���܂��B
%
% ���ڍׂȃw���v�́AMATLAB�R�}���h���C���ŃR�}���h'doc print'�ƃ^�C�v
% ���āA�f�o�C�X�ƃI�v�V�����̊��S�ȃ��X�g�����Ă��������B����̏ڍׂȏ�
% ��́AUsing MATLAB Graphics�}�j���A�����Q�Ƃ��Ă��������B
%
% �Q�l�FPRINTOPT, PRINTDLG, ORIENT, IMWRITE, HGSAVE, SAVEAS.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2004/04/28 01:56:05 $

