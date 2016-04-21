package Win32::Console;
#######################################################################
#
# Win32::Console - Perl Module for Windows Clipboard Interaction
# ^^^^^^^^^^^^^^
# Version: 0.03 (07 Apr 1997)
#
#######################################################################

require Exporter;       # to export the constants to the main:: space
require DynaLoader;     # to dynuhlode the module.

@ISA= qw( Exporter DynaLoader );
@EXPORT = qw(
    BACKGROUND_BLUE
    BACKGROUND_GREEN
    BACKGROUND_INTENSITY
    BACKGROUND_RED
    CAPSLOCK_ON
    CONSOLE_TEXTMODE_BUFFER
    CTRL_BREAK_EVENT    
    CTRL_C_EVENT
    ENABLE_ECHO_INPUT
    ENABLE_LINE_INPUT
    ENABLE_MOUSE_INPUT
    ENABLE_PROCESSED_INPUT
    ENABLE_PROCESSED_OUTPUT
    ENABLE_WINDOW_INPUT
    ENABLE_WRAP_AT_EOL_OUTPUT
    ENHANCED_KEY
    FILE_SHARE_READ
    FILE_SHARE_WRITE
    FOREGROUND_BLUE
    FOREGROUND_GREEN
    FOREGROUND_INTENSITY
    FOREGROUND_RED
    LEFT_ALT_PRESSED
    LEFT_CTRL_PRESSED
    NUMLOCK_ON
    GENERIC_READ
    GENERIC_WRITE
    RIGHT_ALT_PRESSED
    RIGHT_CTRL_PRESSED
    SCROLLLOCK_ON
    SHIFT_PRESSED
    STD_INPUT_HANDLE
    STD_OUTPUT_HANDLE
    STD_ERROR_HANDLE
);


#######################################################################
# This AUTOLOAD is used to 'autoload' constants from the constant()
# XS function.  If a constant is not found then control is passed
# to the AUTOLOAD in AutoLoader.
#

sub AUTOLOAD {
    my($constname);
    ($constname = $AUTOLOAD) =~ s/.*:://;
    #reset $! to zero to reset any current errors.
    $!=0;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
#    if ($! =~ /Invalid/) {
#        $AutoLoader::AUTOLOAD = $AUTOLOAD;
#        goto &AutoLoader::AUTOLOAD;
#    } else {
        ($pack, $file, $line) = caller; undef $pack;
        die "Symbol Win32::Console::$constname not defined, used at $file line $line.";
#    }
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}


#######################################################################
# STATIC OBJECT PROPERTIES
#
$VERSION = "0.03";

# %HandlerRoutineStack = ();
# $HandlerRoutineRegistered = 0;

#######################################################################
# PUBLIC METHODS
#

#======== (MAIN CONSTRUCTOR)
sub new {
#========
    my($class, $param1, $param2) = @_;

    my $self = {};

    if(defined($param1) 
    and ($param1 == constant("STD_INPUT_HANDLE",  0)
    or   $param1 == constant("STD_OUTPUT_HANDLE", 0)
    or   $param1 == constant("STD_ERROR_HANDLE",  0))) {

        $self->{'handle'} = _GetStdHandle($param1);

    } else {

        $param1 = constant("GENERIC_READ", 0)    | constant("GENERIC_WRITE", 0) unless $param1;
        $param2 = constant("FILE_SHARE_READ", 0) | constant("FILE_SHARE_WRITE", 0) unless $param2;
        $self->{'handle'} = _CreateConsoleScreenBuffer($param1, $param2, 
                                                       constant("CONSOLE_TEXTMODE_BUFFER", 0));
    }
    bless $self, $class;
    return $self;
}


#============
sub Display {
#============
    my($self)=@_;
    return undef unless ref($self);

    return _SetConsoleActiveScreenBuffer($self->{'handle'});
}

#===========
sub Select {
#===========
    ($self, $type) = @_;
    return undef unless ref($self);

    return _SetStdHandle($type, $self->{'handle'});
}


#==========
sub Title {
#==========
    my($self, $title) = @_;

    $title = $self unless ref($self);

    if(defined($title)) {
      return _SetConsoleTitle($title);
    } else {
      return _GetConsoleTitle();
    }
}

#==============
sub WriteChar {
#==============
    my($self, $text, $col, $row) = @_;
    return undef unless ref($self);

    return _WriteConsoleOutputCharacter($self->{'handle'},$text,$col,$row);
}

#=============
sub ReadChar {
#=============
    my($self, $size, $col, $row) = @_;
    return undef unless ref($self);
  
    my $buffer = (" " x $size);  
    if(_ReadConsoleOutputCharacter($self->{'handle'}, $buffer, $size, $col, $row)) {
        return $buffer;
    } else {
        return undef;
    }
}



#==============
sub WriteAttr {
#==============
    my($self, $attr, $col, $row) = @_;
    return undef unless ref($self);
    return _WriteConsoleOutputAttribute($self->{'handle'}, $attr, $col, $row);
}

#=============
sub ReadAttr {
#=============
    my($self, $size, $col, $row) = @_;
    return undef unless ref($self);
  
    return _ReadConsoleOutputAttribute($self->{'handle'}, $size, $col, $row);
}


#==========
sub Write {
#==========
    my($self,$string) = @_;
    return undef unless ref($self);
    return _WriteConsole($self->{'handle'}, $string);
}


#=============
sub ReadRect {
#=============
    my($self, $left, $top, $right, $bottom) = @_;
    return undef unless ref($self);
    
    my $col = $right  - $left + 1;
    my $row = $bottom - $top  + 1;

    my $buffer = (" " x ($col*$row*4));
    if(_ReadConsoleOutput($self->{'handle'},   $buffer,
                          $col,  $row, 0,      0,
                          $left, $top, $right, $bottom)) {
        return $buffer;
    } else {
        return undef;
    }
}


#==============
sub WriteRect {
#==============
    my($self, $buffer, $left, $top, $right, $bottom) = @_;
    return undef unless ref($self);

    my $col = $right  - $left + 1;
    my $row = $bottom - $top  + 1;

    return _WriteConsoleOutput($self->{'handle'},   $buffer,
                               $col,  $row, 0,  0,
                               $left, $top, $right, $bottom);
}



#===========
sub Scroll {
#===========
    my($self, $left1, $top1, $right1, $bottom1,
              $col,   $row,  $char,   $attr,
              $left2, $top2, $right2, $bottom2) = @_;
    return undef unless ref($self);
  
    return _ScrollConsoleScreenBuffer($self->{'handle'},
                                      $left1, $top1, $right1, $bottom1,
                                      $col,   $row,  $char,   $attr,
                                      $left2, $top2, $right2, $bottom2);
}


#==============
sub MaxWindow {
#==============
    my($self, $flag) = @_;
    return undef unless ref($self);
  
    if(not defined($flag)) {
        my @info = _GetConsoleScreenBufferInfo($self->{'handle'});
        return $info[9], $info[10];
    } else {
        return _GetLargestConsoleWindowSize($self->{'handle'});
    }
}

#=========
sub Info {
#=========
    my($self) = @_;
    return undef unless ref($self);
  
    return _GetConsoleScreenBufferInfo($self->{'handle'});
}


#===========
sub Window {
#===========
    my($self, $flag, $left, $top, $right, $bottom) = @_;
    return undef unless ref($self);
  
    if(not defined($flag)) {
        my @info = _GetConsoleScreenBufferInfo($self->{'handle'});
        return $info[5], $info[6], $info[7], $info[8];
    } else {
        return _SetConsoleWindowInfo($self->{'handle'}, $flag, $left, $top, $right, $bottom);
    }
}

#==============
sub GetEvents {
#==============
    my $self="";
    ($self)=@_;
    return undef unless ref($self);
  
    return _GetNumberOfConsoleInputEvents($self->{'handle'});
}


#==========
sub Flush {
#==========
    my($self) = @_;
    return undef unless ref($self);

    return _FlushConsoleInputBuffer($self->{'handle'});
}

#==============
sub InputChar {
#==============
    my($self, $number) = @_;
    return undef unless ref($self);
    
    $number = 1 unless defined($number);
  
    my $buffer = (" " x $number);
    if(_ReadConsole($self->{'handle'}, $buffer, $number) == $number) {
        return $buffer;
    } else {
        return undef;
    }
}

#==========
sub Input {
#==========
    my($self) = @_;
    return undef unless ref($self);
  
    return _ReadConsoleInput($self->{'handle'});
}

#==============
sub PeekInput {
#==============
    my($self) = @_;
    return undef unless ref($self);
  
    return _PeekConsoleInput($self->{'handle'});
}


#===============
sub WriteInput {
#===============
    my($self) = shift;
    return undef unless ref($self);
  
    return _WriteConsoleInput($self->{'handle'}, @_);
}


#=========
sub Mode {
#=========
    my($self, $mode) = @_;
    return undef unless ref($self);
  
    if(defined($mode)) {
        return _SetConsoleMode($self->{'handle'}, $mode);
    } else {
        return _GetConsoleMode($self->{'handle'});
    }
}

#========
sub Cls {
#========
    my($self, $attr) = @_;
    return undef unless ref($self);

    $attr = $main::ATTR_NORMAL unless defined($attr);
    
    my ($x, $y) = $self->Size();
    my($left, $top, $right ,$bottom) = $self->Window();
    my $vx = $right  - $left;
    my $vy = $bottom - $top;
    $self->FillChar(" ", $x*$y, 0, 0);
    $self->FillAttr($attr, $x*$y, 0, 0);
    $self->Cursor(0, 0);
    $self->Window(1, 0, 0, $vx, $vy);
}


#=========
sub Attr {
#=========
    my($self, $attr) = @_;
    return undef unless ref($self);
  
    if(not defined($attr)) {
        return (_GetConsoleScreenBufferInfo($self->{'handle'}))[4];
    } else {
        return _SetConsoleTextAttribute($self->{'handle'}, $attr);
    }
}

#===========
sub Cursor {
#===========
    my($self, $col, $row, $size, $visi) = @_;
    return undef unless ref($self);

    my $curr_row  = 0;
    my $curr_col  = 0;
    my $curr_size = 0;
    my $curr_visi = 0;
    my $return    = 0;
    my $discard   = 0;

  
    if(defined($col)) {
        $row = -1 if not defined($row);
        if($col == -1 or $row == -1) {
            ($discard, $discard, $curr_col, $curr_row) = _GetConsoleScreenBufferInfo($self->{'handle'});
            $col=$curr_col if $col==-1;
            $row=$curr_row if $row==-1;
        }
        $return += _SetConsoleCursorPosition($self->{'handle'}, $col, $row);
        if(defined($size) and defined($visi)) {
            if($size == -1 or $visi == -1) {
                ($curr_size, $curr_visi) = _GetConsoleCursorInfo($self->{'handle'});
                $size = $curr_size if $size == -1;
                $visi = $curr_visi if $visi == -1;
            }
            $size = 1 if $size < 1;
            $size = 99 if $size > 99;
            $return += _SetConsoleCursorInfo($self->{'handle'}, $size, $visi);
        }
        return $return;
    } else {
        ($discard, $discard, $curr_col, $curr_row) = _GetConsoleScreenBufferInfo($self->{'handle'});
        ($curr_size, $curr_visi) = _GetConsoleCursorInfo($self->{'handle'});
        return ($curr_col, $curr_row, $curr_size, $curr_visi);
    }
}
  
#=========
sub Size {
#=========
    my($self, $col, $row) = @_;
    return undef unless ref($self);
    if(not defined($col)) {
        ($col, $row) = _GetConsoleScreenBufferInfo($self->{'handle'});
        return ($col, $row);
    } else {
        $row = -1 if not defined($row);
        if($col == -1 or $row == -1) {
            ($curr_col, $curr_row) = _GetConsoleScreenBufferInfo($self->{'handle'});
            $col=$curr_col if $col==-1;
            $row=$curr_row if $row==-1;
        }
        return _SetConsoleScreenBufferSize($self->{'handle'}, $col, $row);
    }
}

#=============
sub FillAttr {
#=============
    my($self, $attr, $number, $col, $row) = @_;
    return undef unless ref($self);

    $number = 1 unless $number;

    if(!defined($col) or !defined($row) or $col == -1 or $row == -1) {
        ($discard,  $discard, 
         $curr_col, $curr_row) = _GetConsoleScreenBufferInfo($self->{'handle'});
        $col = $curr_col if !defined($col) or $col == -1;
        $row = $curr_row if !defined($row) or $row == -1;
    }
    return _FillConsoleOutputAttribute($self->{'handle'}, $attr, $number, $col, $row);
}

#=============
sub FillChar {
#=============
    my($self, $char, $number, $col, $row) = @_;
    return undef unless ref($self);

    if(!defined($col) or !defined($row) or $col == -1 or $row == -1) {
        ($discard,  $discard,
         $curr_col, $curr_row) = _GetConsoleScreenBufferInfo($self->{'handle'});
        $col = $curr_col if !defined($col) or $col == -1;
        $row = $curr_row if !defined($row) or $row == -1;
    }
    return _FillConsoleOutputCharacter($self->{'handle'}, $char, $number, $col, $row);
}

#============
sub InputCP {
#============
    my($self, $codepage) = @_;
    $codepage = $self if (defined($self) and ref($self) ne "Win32::Console");
    if(defined($codepage)) {
        return _SetConsoleCP($codepage);
    } else {
        return _GetConsoleCP();
    }
}

#=============
sub OutputCP {
#=============
    my($self, $codepage) = @_;
    $codepage = $self if (defined($self) and ref($self) ne "Win32::Console");
    if(defined($codepage)) {
        return _SetConsoleOutputCP($codepage);
    } else {
        return _GetConsoleOutputCP();
    }
}

#======================
sub GenerateCtrlEvent {
#======================
    my($self, $type, $pid) = @_;
    $type = constant("CTRL_C_EVENT", 0) unless defined($type);
    $pid = 0 unless defined($pid);
    return _GenerateCtrlEvent($type, $pid);
}

#===================
#sub SetCtrlHandler {
#===================
#    my($name, $add) = @_;
#    $add = 1 unless defined($add);
#    my @nor = keys(%HandlerRoutineStack);
#    if($add == 0) {
#        foreach $key (@nor) {
#            delete $HandlerRoutineStack{$key}, last if $HandlerRoutineStack{$key}==$name;
#        }
#        $HandlerRoutineRegistered--;
#    } else {
#        if($#nor == -1) {
#            my $r = _SetConsoleCtrlHandler();
#            if(!$r) {
#                print "WARNING: SetConsoleCtrlHandler failed...\n";
#            }
#        }
#        $HandlerRoutineRegistered++;
#        $HandlerRoutineStack{$HandlerRoutineRegistered} = $name;
#    }
#}


########################################################################
# PRIVATE METHODS
#

#================
#sub CtrlHandler {
#================
#    my($ctrltype) = @_;
#    my $routine;
#    my $result = 0;
#    CALLEM: foreach $routine (sort { $b <=> $a } keys %HandlerRoutineStack) {
#        #print "CtrlHandler: calling $HandlerRoutineStack{$routine}($ctrltype)\n";
#        $result = &{"main::".$HandlerRoutineStack{$routine}}($ctrltype);
#        last CALLEM if $result;
#    }
#    return $result;
#}

#============  (MAIN DESTRUCTOR)
sub DESTROY {
#============
    my($self) = @_;
    _CloseHandle($self->{'handle'});
}



#######################################################################
# dynamically load in the Console.pll module.
#

bootstrap Win32::Console;

#######################################################################
# ADDITIONAL CONSTANTS EXPORTED IN THE MAIN NAMESPACE
#

$main::FG_BLACK        = 0;
$main::FG_BLUE         = constant("FOREGROUND_BLUE",0);
$main::FG_LIGHTBLUE    = constant("FOREGROUND_BLUE",0)|
                         constant("FOREGROUND_INTENSITY",0);
$main::FG_RED          = constant("FOREGROUND_RED",0);
$main::FG_LIGHTRED     = constant("FOREGROUND_RED",0)|
                         constant("FOREGROUND_INTENSITY",0);
$main::FG_GREEN        = constant("FOREGROUND_GREEN",0);
$main::FG_LIGHTGREEN   = constant("FOREGROUND_GREEN",0)|
                         constant("FOREGROUND_INTENSITY",0);
$main::FG_MAGENTA      = constant("FOREGROUND_RED",0)|
                         constant("FOREGROUND_BLUE",0);
$main::FG_LIGHTMAGENTA = constant("FOREGROUND_RED",0)|
                         constant("FOREGROUND_BLUE",0)|
                         constant("FOREGROUND_INTENSITY",0);
$main::FG_CYAN         = constant("FOREGROUND_GREEN",0)|
                         constant("FOREGROUND_BLUE",0);
$main::FG_LIGHTCYAN    = constant("FOREGROUND_GREEN",0)|
                         constant("FOREGROUND_BLUE",0)|
                         constant("FOREGROUND_INTENSITY",0);
$main::FG_BROWN        = constant("FOREGROUND_RED",0)|
                         constant("FOREGROUND_GREEN",0);
$main::FG_YELLOW       = constant("FOREGROUND_RED",0)|
                         constant("FOREGROUND_GREEN",0)|
                         constant("FOREGROUND_INTENSITY",0);
$main::FG_GRAY         = constant("FOREGROUND_RED",0)|
                         constant("FOREGROUND_GREEN",0)|
                         constant("FOREGROUND_BLUE",0);
$main::FG_WHITE        = constant("FOREGROUND_RED",0)|
                         constant("FOREGROUND_GREEN",0)|
                         constant("FOREGROUND_BLUE",0)|
                         constant("FOREGROUND_INTENSITY",0);

$main::BG_BLACK        = 0;
$main::BG_BLUE         = constant("BACKGROUND_BLUE",0);
$main::BG_LIGHTBLUE    = constant("BACKGROUND_BLUE",0)|
                         constant("BACKGROUND_INTENSITY",0);
$main::BG_RED          = constant("BACKGROUND_RED",0);
$main::BG_LIGHTRED     = constant("BACKGROUND_RED",0)|
                         constant("BACKGROUND_INTENSITY",0);
$main::BG_GREEN        = constant("BACKGROUND_GREEN",0);
$main::BG_LIGHTGREEN   = constant("BACKGROUND_GREEN",0)|
                         constant("BACKGROUND_INTENSITY",0);
$main::BG_MAGENTA      = constant("BACKGROUND_RED",0)|
                         constant("BACKGROUND_BLUE",0);
$main::BG_LIGHTMAGENTA = constant("BACKGROUND_RED",0)|
                         constant("BACKGROUND_BLUE",0)|
                         constant("BACKGROUND_INTENSITY",0);
$main::BG_CYAN         = constant("BACKGROUND_GREEN",0)|
                         constant("BACKGROUND_BLUE",0);
$main::BG_LIGHTCYAN    = constant("BACKGROUND_GREEN",0)|
                         constant("BACKGROUND_BLUE",0)|
                         constant("BACKGROUND_INTENSITY",0);
$main::BG_BROWN        = constant("BACKGROUND_RED",0)|
                         constant("BACKGROUND_GREEN",0);
$main::BG_YELLOW       = constant("BACKGROUND_RED",0)|
                         constant("BACKGROUND_GREEN",0)|
                         constant("BACKGROUND_INTENSITY",0);
$main::BG_GRAY         = constant("BACKGROUND_RED",0)|
                         constant("BACKGROUND_GREEN",0)|
                         constant("BACKGROUND_BLUE",0);
$main::BG_WHITE        = constant("BACKGROUND_RED",0)|
                         constant("BACKGROUND_GREEN",0)|
                         constant("BACKGROUND_BLUE",0)|
                         constant("BACKGROUND_INTENSITY",0);

$main::ATTR_NORMAL = $main::FG_GRAY|$main::BG_BLACK;
$main::ATTR_INVERSE = $main::FG_BLACK|$main::BG_GRAY;

undef unless $main::ATTR_NORMAL;
undef unless $main::ATTR_INVERSE;
undef unless $VERSION;

@main::CONSOLE_COLORS = ();

foreach $fg ($main::FG_BLACK, $main::FG_BLUE, $main::FG_GREEN, $main::FG_CYAN, 
             $main::FG_RED, $main::FG_MAGENTA, $main::FG_BROWN, $main::FG_GRAY,
             $main::FG_LIGHTBLUE, $main::FG_LIGHTGREEN, $main::FG_LIGHTCYAN,
             $main::FG_LIGHTRED, $main::FG_LIGHTMAGENTA, $main::FG_YELLOW, 
             $main::FG_WHITE) {

    foreach $bg ($main::BG_BLACK, $main::BG_BLUE, $main::BG_GREEN, $main::BG_CYAN, 
                 $main::BG_RED, $main::BG_MAGENTA, $main::BG_BROWN, $main::BG_GRAY,
                 $main::BG_LIGHTBLUE, $main::BG_LIGHTGREEN, $main::BG_LIGHTCYAN,
                 $main::BG_LIGHTRED, $main::BG_LIGHTMAGENTA, $main::BG_YELLOW, 
                 $main::BG_WHITE) {
        push(@main::CONSOLE_COLORS, $fg|$bg);
    }
}

undef $fg;
undef $bg;

# Preloaded methods go here.

#Currently Autoloading is not implemented in Perl for win32
# Autoload methods go after __END__, and are processed by the autosplit program.

1;

__END__

