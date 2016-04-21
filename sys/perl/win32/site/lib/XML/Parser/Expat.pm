package XML::Parser::Expat;

require 5.004;

use English;
use strict;
use vars qw($VERSION @ISA %Handler_Setters %Encoding_Table @Encoding_Path
	    $have_File_Spec);
use Carp;

use IO::Handle;

require DynaLoader;

@ISA = qw(DynaLoader);
$VERSION = "2.23" ;

$have_File_Spec = do 'File/Spec.pm';

%Encoding_Table = ();
if ($have_File_Spec) {
  @Encoding_Path = (grep(-d $_,
			 map(File::Spec->catdir($_, qw(XML Parser Encodings)),
			     @INC)),
		    File::Spec->curdir);
}
else {
  @Encoding_Path = (grep(-d $_, map($_ . '/XML/Parser/Encodings', @INC)), '.');
}
  

bootstrap XML::Parser::Expat $VERSION;

%Handler_Setters = (
		    Start => \&SetStartElementHandler,
		    End   => \&SetEndElementHandler,
		    Char  => \&SetCharacterDataHandler,
		    Proc  => \&SetProcessingInstructionHandler,
		    Comment => \&SetCommentHandler,
		    CdataStart => \&SetStartCdataHandler,
		    CdataEnd   => \&SetEndCdataHandler,
		    Default => \&SetDefaultHandler,
		    Unparsed => \&SetUnparsedEntityDeclHandler,
		    Notation => \&SetNotationDeclHandler,
		    ExternEnt => \&SetExternalEntityRefHandler,
		    Entity => \&SetEntityDeclHandler,
		    Element => \&SetElementDeclHandler,
		    Attlist => \&SetAttListDeclHandler,
		    Doctype => \&SetDoctypeHandler,
		    XMLDecl => \&SetXMLDeclHandler
		    );

sub new {
  my ($class, %args) = @_;
  my $self = bless \%args, $_[0];
  $args{Used} = 0;
  $args{Context} = [];
  $args{Namespaces} ||= 0;
  $args{ErrorMessage} ||= '';
  if ($args{Namespaces}) {
    $args{Namespace_Table} = {};
    $args{Namespace_List} = [undef];
    $args{Prefix_Table} = {};
    $args{New_Prefixes} = [];
  }
  $args{_Setters} = \%Handler_Setters;
  $args{Parser} = ParserCreate($self, $args{ProtocolEncoding},
			       $args{Namespaces});
  $self;
}

sub load_encoding {
  my ($file) = @_;

  $file =~ s![^/]+$!\L$&\E!;
  $file .= '.enc' unless $file =~ /\.enc$/;
  unless ($file =~ m!^/!) {
    foreach (@Encoding_Path) {
      my $tmp = ($have_File_Spec
		 ? File::Spec->catfile($_, $file)
		 : "$_/$file");
      if (-e $tmp) {
	$file = $tmp;
	last;
      }
    }
  }

  local(*ENC);
  open(ENC, $file) or croak("Couldn't open encmap $file:\n$!\n");
  binmode(ENC);
  my $data;
  my $br = sysread(ENC, $data, -s $file);
  croak("Trouble reading $file:\n$!\n")
    unless defined($br);
  close(ENC);

  my $name = LoadEncoding($data, $br);
  croak("$file isn't an encmap file")
    unless defined($name);

  $name;
}  # End load_encoding

sub setHandlers {
  my ($self, @handler_pairs) = @_;

  croak("Uneven number of arguments to setHandlers method")
    if (int(@handler_pairs) & 1);

  while (@handler_pairs) {
    my $type = shift @handler_pairs;
    my $handler = shift @handler_pairs;
    my $hndl = $self->{_Setters}->{$type};

    unless (defined($hndl)) {
      my @types = sort keys %{$self->{_Setters}};
      croak("Unknown Expat handler type: $type\n Valid types: @types");
    }

    &$hndl($self->{Parser}, $handler);
  }
}

sub xpcroak {
  my ($self, $message) = @_;

  my $eclines = $self->{ErrorContext};
  my $line = GetCurrentLineNumber($_[0]->{Parser});
  $message .= " at line $line";
  $message .= ":\n" . $self->position_in_context($eclines)
    if defined($eclines);
  croak $message;
}

sub xpcarp {
  my ($self, $message) = @_;

  my $eclines = $self->{ErrorContext};
  my $line = GetCurrentLineNumber($_[0]->{Parser});
  $message .= " at line $line";
  $message .= ":\n" . $self->position_in_context($eclines)
    if defined($eclines);
  carp $message;
}

sub default_current {
  my $self = shift;
  DefaultCurrent($self->{Parser});
}

sub recognized_string {
  my $self = shift;
  RecognizedString($self->{Parser});
}

sub original_string {
  my $self = shift;
  OriginalString($self->{Parser});
}

sub current_line {
  GetCurrentLineNumber($_[0]->{Parser});
}

sub current_column {
  GetCurrentColumnNumber($_[0]->{Parser});
}

sub current_byte {
  GetCurrentByteIndex($_[0]->{Parser});
}

sub base {
  my ($self, $newbase) = @_;
  my $p = $self->{Parser};
  my $oldbase = GetBase($p);
  SetBase($p, $newbase) if @_ > 1;
  $oldbase;
}

sub context {
  my $ctx = $_[0]->{Context};
  @$ctx;
}

sub current_element {
  my ($self) = @_;
  @{$self->{Context}} ? $self->{Context}->[-1] : undef;
}

sub in_element {
  my ($self, $element) = @_;
  @{$self->{Context}} ? $self->eq_name($self->{Context}->[-1], $element)
    : undef;
}

sub within_element {
  my ($self, $element) = @_;
  my $cnt = 0;
  foreach (@{$self->{Context}}) {
    $cnt++ if $self->eq_name($_, $element);
  }
  return $cnt;
}

sub depth {
  my ($self) = @_;
  int(@{$self->{Context}});
}

sub element_index {
  my ($self) = @_;

  ElementIndex($self->{Parser});
}

################
# Namespace methods

sub namespace {
  my ($self, $name) = @_;
  local($WARNING) = 0;
  $self->{Namespace_List}->[int($name)];
}

sub eq_name {
  my ($self, $nm1, $nm2) = @_;
  local($WARNING) = 0;

  int($nm1) == int($nm2) and $nm1 eq $nm2;
}

sub generate_ns_name {
  my ($self, $name, $namespace) = @_;

  $namespace ?
    GenerateNSName($name, $namespace, $self->{Namespace_Table},
		   $self->{Namespace_List})
      : $name;
}

sub new_ns_prefixes {
  my ($self) = @_;
  if ($self->{Namespaces}) {
    return @{$self->{New_Prefixes}};
  }
  return ();
}

sub expand_ns_prefix {
  my ($self, $prefix) = @_;

  if ($self->{Namespaces}) {
    my $stack = $self->{Prefix_Table}->{$prefix};
    return (defined($stack) and @$stack) ? $stack->[-1] : undef;
  }

  return undef;
}

sub current_ns_prefixes {
  my ($self) = @_;

  if ($self->{Namespaces}) {
    my %set = %{$self->{Prefix_Table}};

    if (exists $set{'#default'} and not defined($set{'#default'}->[-1])) {
      delete $set{'#default'};
    }

    return keys %set;
  }

  return ();
}


################################################################
# Namespace declaration handlers
#

sub NamespaceStart {
  my ($self, $prefix, $uri) = @_;

  $prefix = '#default' unless defined $prefix;
  my $stack = $self->{Prefix_Table}->{$prefix}; 

  if (defined $stack) {
    push(@$stack, $uri);
  }
  else {
    $self->{Prefix_Table}->{$prefix} = [$uri];
  }

  # The New_Prefixes list gets emptied at end of startElement function
  # in Expat.xs

  push(@{$self->{New_Prefixes}}, $prefix);
}

sub NamespaceEnd {
  my ($self, $prefix) = @_;

  $prefix = '#default' unless defined $prefix;

  my $stack = $self->{Prefix_Table}->{$prefix};
  if (@$stack > 1) {
    pop(@$stack);
  }
  else {
    delete $self->{Prefix_Table}->{$prefix};
  }
}

################

sub is_defaulted {
  my ($self, $attname) = @_;

  warn <<'End_of_Warning;';
The is_defaulted method no longer works.
Please use the specified_attr method instead. The is_defaulted method will
be removed altogether in a future version.
End_of_Warning;
  return 0;
}

sub specified_attr {
  my $self = shift;
  
  GetSpecifiedAttributeCount($self->{Parser});
}

sub finish {
  my ($self) = @_;
  my $parser = $self->{Parser};
  UnsetAllHandlers($parser);
}

sub position_in_context {
  my ($self, $lines) = @_;
  my $parser = $self->{Parser};
  my ($string, $linepos) = PositionContext($parser, $lines);

  return '' unless defined($string);

  my $col = GetCurrentColumnNumber($parser);
  my $ptr = ('=' x ($col - 1)) . '^' . "\n";
  my $ret;
  my $dosplit = $linepos < length($string);
  
  $string .= "\n" unless $string =~ /\n$/;
  
  if ($dosplit) {
    $ret = substr($string, 0, $linepos) . $ptr
      . substr($string, $linepos);
  } else {
    $ret = $string . $ptr;
  }
  
  $ret;
}

sub xml_escape {
  my $self = shift;
  my $text = shift;

  study $text;
  $text =~ s/\&/\&amp;/g;
  $text =~ s/</\&lt;/g;
  $text =~ s/>/\&gt;/g;
  foreach (@_) {
    my $rep = '&#' . ord($_) . ';';
    $text =~ s/$_/$rep/g;
  }
  $text;
}

sub release {
  my $self = shift;
  ParserRelease($self->{Parser});
}

sub DESTROY {
  my $self = shift;
  ParserFree($self->{Parser});
}

sub parse {
  my $self = shift;
  my $arg = shift;
  croak "Parse already in progress (Expat)" if $self->{Used};
  $self->{Used} = 1;
  my $parser = $self->{Parser};
  my $ioref;
  my $result = 0;
  
  if (defined $arg) {
    if (ref($arg) and UNIVERSAL::isa($arg, 'IO::Handler')) {
      $ioref = $arg;
    } else {
      eval {
	$ioref = *{$arg}{IO};
      };
    }
  }
  
  if (defined($ioref)) {
    my $delim = $self->{Stream_Delimiter};
    my $prev_rs;
    
    $prev_rs = ref($ioref)->input_record_separator("\n$delim\n")
      if defined($delim);
    
    $result = ParseStream($parser, $ioref, $delim);
    
    ref($ioref)->input_record_separator($prev_rs)
      if defined($delim);
  } else {
    $result = ParseString($parser, $arg);
  }
  
  $result or croak $self->{ErrorMessage};
}

sub parsestring {
  my $self = shift;
  $self->parse(@_);
}

sub parsefile {
  my $self = shift;
  croak "Parser has already been used" if $self->{Used};
  local(*FILE);
  open(FILE, $_[0]) or  croak "Couldn't open $_[0]:\n$!";
  binmode(FILE);
  my $ret = $self->parse(*FILE);
  close(FILE);
  $ret;
}

################################################################
package XML::Parser::ExpatNB;

use vars qw(@ISA);
use Carp;

@ISA = qw(XML::Parser::Expat);

sub new {
  my ($class, %args) = @_;

  my $self = $class->SUPER::new(%args);

  delete $self->{ErrorContext};
  $self;
}

sub parse {
  my $self = shift;
  my $class = ref($self);
  croak "parse method not supported in $class";
}

sub parsestring {
  my $self = shift;
  my $class = ref($self);
  croak "parsestring method not supported in $class";
}

sub parsefile {
  my $self = shift;
  my $class = ref($self);
  croak "parsefile method not supported in $class";
}

sub position_in_context {
  my $self = shift;
  my $class = ref($self);
  croak "position_in_context method not supported in $class";
}

sub original_string {
  my $self = shift;
  my $class = ref($self);
  croak "original_string method not supported in $class";
}

sub parse_more {
  my ($self, $data) = @_;

  my $ret = XML::Parser::Expat::ParsePartial($self->{Parser}, $data);

  croak $self->{ErrorMessage} unless $ret;
}

sub parse_done {
  my $self = shift;

  my $ret = XML::Parser::Expat::ParseDone($self->{Parser});
  unless ($ret) {
    my $msg = $self->{ErrorMessage};
    $self->release;
    croak $msg;
  }

  my $result = $ret;
  my @result = ();
  my $final = $self->{FinalHandler};
  if (defined $final) {
    if (wantarray) {
      @result = &$final($self);
    }
    else {
      $result = &$final($self);
    }
  }

  $self->release;

  return unless defined wantarray;
  return wantarray ? @result : $result;
}

################################################################

package XML::Parser::Encinfo;

sub DESTROY {
  my $self = shift;
  XML::Parser::Expat::FreeEncoding($self);
}

1;

__END__

=head1 NAME

XML::Parser::Expat - Lowlevel access to James Clark's expat XML parser

=head1 SYNOPSIS

 use XML::Parser::Expat;

 $parser = new XML::Parser::Expat;
 $parser->setHandlers('Start' => \&sh,
		      'End'   => \&eh,
                      'Char'  => \&ch);
 open(FOO, 'info.xml') or die "Couldn't open";
 $parser->parse(*FOO);
 close(FOO);
 # $parser->parse('<foo id="me"> here <em>we</em> go </foo>');

 sub sh
 {
   my ($p, $el, %atts) = @_;
   $p->setHandlers('Char' => \&spec)
     if ($el eq 'special');
   ...
 }

 sub eh
 {
   my ($p, $el) = @_;
   $p->setHandlers('Char' => \&ch)  # Special elements won't contain
     if ($el eq 'special');         # other special elements
   ...
 } 

=head1 DESCRIPTION

This module provides an interface to James Clark's XML parser, expat. As in
expat, a single instance of the parser can only parse one document. Calls
to parsestring after the first for a given instance will die.

Expat (and XML::Parser::Expat) are event based. As the parser recognizes
parts of the document (say the start or end of an XML element), then any
handlers registered for that type of an event are called with suitable
parameters.

=head1 METHODS

=over 4

=item new

This is a class method, the constructor for XML::Parser::Expat. Options are
passed as keyword value pairs. The recognized options are:

=over 4

=item * ProtocolEncoding

The protocol encoding name. The default is none. The expat built-in
encodings are: C<UTF-8>, C<ISO-8859-1>, C<UTF-16>, and C<US-ASCII>.
Other encodings may be used if they have encoding maps in one of the
directories in the @Encoding_Path list. Setting the protocol encoding
overrides any encoding in the XML declaration.

=item * Namespaces

When this option is given with a true value, then the parser does namespace
processing. By default, namespace processing is turned off. When it is
turned on, the parser consumes I<xmlns> attributes and strips off prefixes
from element and attributes names where those prefixes have a defined
namespace. A name's namespace can be found using the L<"namespace"> method
and two names can be checked for absolute equality with the L<"eq_name">
method.

=item * NoExpand

Normally, the parser will try to expand references to entities defined in
the internal subset. If this option is set to a true value, and a default
handler is also set, then the default handler will be called when an
entity reference is seen in text. This has no effect if a default handler
has not been registered, and it has no effect on the expansion of entity
references inside attribute values.

=item * Stream_Delimiter

This option takes a string value. When this string is found alone on a line
while parsing from a stream, then the parse is ended as if it saw an end of
file. The intended use is with a stream of xml documents in a MIME multipart
format. The string should not contain a trailing newline.

=item * ErrorContext

When this option is defined, errors are reported in context. The value
of ErrorContext should be the number of lines to show on either side of
the line in which the error occurred.

=back

=item setHandlers(TYPE, HANDLER [, TYPE, HANDLER [...]])

This method registers handlers for the various events. If no handlers are
registered, then a call to parsestring or parsefile will only determine if
the corresponding XML document is well formed (by returning without error.)
This may be called from within a handler, after the parse has started.

Setting a handler to something that evaluates to false unsets that
handler.

The recognized events and the parameters passed to the corresponding
handlers are:

=over 4

=item * Start		(Parser, Element [, Attr, Val [,...]])

This event is generated when an XML start tag is recognized. Parser is
an XML::Parser::Expat instance. Element is the name of the XML element that
is opened with the start tag. The Attr & Val pairs are generated for each
attribute in the start tag.

=item * End		(Parser, Element)

This event is generated when an XML end tag is recognized. Note that
an XML empty tag (<foo/>) generates both a start and an end event.

There is always a lower level start and end handler installed that wrap
the corresponding callbacks. This is to handle the context mechanism.
A consequence of this is that the default handler (see below) will not
see a start tag or end tag unless the default_current method is called.

=item * Char		(Parser, String)

This event is generated when non-markup is recognized. The non-markup
sequence of characters is in String. A single non-markup sequence of
characters may generate multiple calls to this handler. Whatever the
encoding of the string in the original document, this is given to the
handler in UTF-8.

=item * Proc		(Parser, Target, Data)

This event is generated when a processing instruction is recognized.

=item * Comment		(Parser, String)

This event is generated when a comment is recognized.

=item * CdataStart	(Parser)

This is called at the start of a CDATA section.

=item * CdataEnd	(Parser)

This is called at the end of a CDATA section.

=item * Default		(Parser, String)

This is called for any characters that don't have a registered handler.
This includes both characters that are part of markup for which no
events are generated (markup declarations) and characters that
could generate events, but for which no handler has been registered.

Whatever the encoding in the original document, the string is returned to
the handler in UTF-8.

=item * Unparsed		(Parser, Entity, Base, Sysid, Pubid, Notation)

This is called for a declaration of an unparsed entity. Entity is the name
of the entity. Base is the base to be used for resolving a relative URI.
Sysid is the system id. Pubid is the public id. Notation is the notation
name. Base and Pubid may be undefined.

=item * Notation		(Parser, Notation, Base, Sysid, Pubid)

This is called for a declaration of notation. Notation is the notation name.
Base is the base to be used for resolving a relative URI. Sysid is the system
id. Pubid is the public id. Base, Sysid, and Pubid may all be undefined.

=item * ExternEnt		(Parser, Base, Sysid, Pubid)

This is called when an external entity is referenced. Base is the base to be
used for resolving a relative URI. Sysid is the system id. Pubid is the public
id. Base, and Pubid may be undefined.

This handler should either return a string, which represents the contents of
the external entity, or return an open filehandle that can be read to obtain
the contents of the external entity, or return undef, which indicates the
external entity couldn't be found and will generate a parse error.

If an open filehandle is returned, it must be returned as either a glob
(*FOO) or as a reference to a glob (e.g. an instance of IO::Handle). The
parser will close the filehandle after using it.

=item * Entity			(Parser, Name, Val, Sysid, Pubid, Ndata)

This is called when an entity is declared in the internal subset. For
internal entities, the Val parameter will contain the value and the remaining
three parameters will be undefined. For external entities, the Val parameter
will be undefined, the Sysid parameter will have the system id, the Pubid
parameter will have the public id if it was provided (it will be undefined
otherwise), the Ndata parameter will contain the notation for unparsed
entities. If this is a parameter entity declaration, then a '%' will be
prefixed to the name.

Note that this handler and the Unparsed handler above overlap. If both are
set, then this handler will not be called for unparsed entities.

=item * Element			(Parser, Name, Model)

The element handler is called when an element declaration is found in the
internal subset. Name is the element name, and Model is the content model
as a string.

=item * Attlist			(Parser, Elname, Attname, Type, Default, Fixed)

This handler is called for each attribute in an ATTLIST declaration found in
the internal subset. So an ATTLIST declaration that has multiple attributes
will generate multiple calls to this handler. The Elname parameter is the
name of the element with which the attribute is being associated. The Attname
parameter is the name of the attribute. Type is the attribute type, given as
a string. Default is the default value, which will either be "#REQUIRED",
"#IMPLIED" or a quoted string (i.e. the returned string will begin and end
with a quote character). If Fixed is true, then this is a fixed attribute.

=item * Doctype			(Parser, Name, Sysid, Pubid, Internal)

This handler is called for DOCTYPE declarations. Name is the document type
name. Sysid is the system id of the document type, if it was provided,
otherwise it's undefined. Pubid is the public id of the document type,
which will be undefined if no public id was given. Internal is the internal
subset, given as a string. If there was no internal subset, it will be
undefined. Internal will contain all whitespace, comments, processing
instructions, and declarations seen in the internal subset. The declarations
will be there whether or not they have been processed by another handler
(except for unparsed entities processed by the Unparsed handler). However,
comments and processing instructions will not appear if they've been processed
by their respective handlers.

=item * XMLDecl			(Parser, Version, Encoding, Standalone)

This handler is called for xml declarations. Version is a string containg
the version. Encoding is either undefined or contains an encoding string.
Standalone will be either true, false, or undefined if the standalone attribute
is yes, no, or not made respectively.

=back

=item namespace(name)

Return the URI of the namespace that the name belongs to. If the name doesn't
belong to any namespace, an undef is returned. This is only valid on names
received through the Start or End handlers from a single document, or through
a call to the generate_ns_name method. In other words, don't use names
generated from one instance of XML::Parser::Expat with other instances.

=item eq_name(name1, name2)

Return true if name1 and name2 are identical (i.e. same name and from
the same namespace.) This is only meaningful if both names were obtained
through the Start or End handlers from a single document, or through
a call to the generate_ns_name method.

=item generate_ns_name(name, namespace)

Return a name, associated with a given namespace, good for using with the
above 2 methods. The namespace argument should be the namespace URI, not
a prefix.

=item new_ns_prefixes

When called from a start tag handler, returns namespace prefixes declared
with this start tag. If called elsewere (or if there were no namespace
prefixes declared), it returns an empty list. Setting of the default
namespace is indicated with '#default' as a prefix.

=item expand_ns_prefix(prefix)

Return the uri to which the given prefix is currently bound. Returns
undef if the prefix isn't currently bound. Use '#default' to find the
current binding of the default namespace (if any).

=item current_ns_prefixes

Return a list of currently bound namespace prefixes. The order of the
the prefixes in the list has no meaning. If the default namespace is
currently bound, '#default' appears in the list.

=item recognized_string

Returns the string from the document that was recognized in order to call
the current handler. For instance, when called from a start handler, it
will give us the the start-tag string. The string is encoded in UTF-8.

=item original_string

Returns the verbatim string from the document that was recognized in
order to call the current handler. The string is in the original document
encoding.

=item default_current

When called from a handler, causes the sequence of characters that generated
the corresponding event to be sent to the default handler (if one is
registered). Use of this method is deprecated in favor the recognized_string
method, which you can use without installing a default handler.

=item xpcroak(message)

Concatenate onto the given message the current line number within the
XML document plus the message implied by ErrorContext. Then croak with
the formed message.

=item xpcarp(message)

Concatenate onto the given message the current line number within the
XML document plus the message implied by ErrorContext. Then carp with
the formed message.

=item current_line

Returns the line number of the current position of the parse.

=item current_column

Returns the column number of the current position of the parse.

=item current_byte

Returns the current position of the parse.

=item base([NEWBASE]);

Returns the current value of the base for resolving relative URIs. If
NEWBASE is supplied, changes the base to that value.

=item context

Returns a list of element names that represent open
elements, with the last one being the innermost.

=item current_element

Returns the name of the innermost currently opened element.

=item in_element(NAME)

Returns true if NAME is equal to the name of the innermost currently opened
element. If namespace processing is being used and you want to check
against a name that may be in a namespace, then use the generate_ns_name
method to create the NAME argument.

=item within_element(NAME)

Returns the number of times the given name appears in the context list.
If namespace processing is being used and you want to check
against a name that may be in a namespace, then use the generate_ns_name
method to create the NAME argument.

=item depth

Returns the size of the context list.

=item element_index

Returns an integer that is the depth-first visit order of the current
element. This will be zero outside of the root element. Note that
in start and end handlers, you're outside of the element that the
corresponding tags delimit. For example, this would return 0 when
called from the start handler for the root element start tag.

=item position_in_context(LINES)

Returns a string that shows the current parse position. LINES should be
an integer >= 0 that represents the number of lines on either side of the
current parse line to place into the returned string.

=item xml_escape(TEXT [, CHAR [, CHAR ...]])

Returns TEXT with markup characters turned into character entities. Any
additional characters provided as arguments are also turned into character
references where found in TEXT.

=item parse (SOURCE)

The SOURCE parameter should either be a string containing the whole XML
document, or it should be an open IO::Handle. Only a single document
may be parsed for a given instance of XML::Parser::Expat, so this will croak
if it's been called previously for this instance.

=item parsestring(XML_DOC_STRING)

Parses the given string as an XML document. Only a single document may be
parsed for a given instance of XML::Parser::Expat, so this will die if either
parsestring or parsefile has been called for this instance previously.

This method is deprecated in favor of the parse method.

=item parsefile(FILENAME)

Parses the XML document in the given file. Will die if parsestring or
parsefile has been called previously for this instance.

=item is_defaulted(ATTNAME)

NO LONGER WORKS. To find out if an attribute is defaulted please use
the specified_attr method.

=item specified_attr

When the start handler receives lists of attributes and values, the
non-defaulted (i.e. explicitly specified) attributes occur in the list
first. This method returns the number of specified items in the list.
So if this number is equal to the length of the list, there were no
defaulted values. Otherwise the number points to the index of the
first defaulted attribute name.

=item finish

Unsets all handlers (including internal ones that set context), but expat
continues parsing to the end of the document or until it finds an error.
It should finish up a lot faster than with the handlers set.

=item release

There are data structures used by XML::Parser::Expat that have circular
references. This means that these structures will never be garbage
collected unless these references are explicitly broken. Calling this
method breaks those references (and makes the instance unusable.)

Normally, higher level calls handle this for you, but if you are using
XML::Parser::Expat directly, then it's your responsibility to call it.

=back

=head2 XML::Parser::ExpatNB Methods

The class XML::Parser::ExpatNB is a subclass of XML::Parser::Expat used
for non-blocking access to the expat library. The Expat methods
position_in_context and original_string are disabled for this class and
it doesn't honor the ErrorContext option. It has the following additional
methods:

=over 4

=item parse_more(DATA)

Feed expat more text to munch on.

=item parse_done

Tell expat that it's gotten the whole document.

=back

=head1 FUNCTIONS

=over 4

=item XML::Parser::Expat::load_encoding(ENCODING)

Load an external encoding. ENCODING is either the name of an encoding or
the name of a file. The basename is converted to lowercase and a '.enc'
extension is appended unless there's one already there. Then, unless
it's an absolute pathname (i.e. begins with '/'), the first file by that
name discovered in the @Encoding_Path path list is used.

The encoding in the file is loaded and kept in the %Encoding_Table
table. Earlier encodings of the same name are replaced.

This function is automaticly called by expat when it encounters an encoding
it doesn't know about. Expat shouldn't call this twice for the same
encoding name. The only reason users should use this function is to
explicitly load an encoding not contained in the @Encoding_Path list.

=back

=head1 AUTHORS

Larry Wall <F<larry@wall.org>> wrote version 1.0.

Clark Cooper <F<coopercc@netheaven.com>> picked up support, changed the API
for this version (2.x), provided documentation, and added some standard
package features.

=cut
