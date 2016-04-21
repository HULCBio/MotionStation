# NOTE: Derived from blib\lib\Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 176 "blib\lib\Storable.pm (autosplit into blib\lib\auto/Storable/retrieve_fd.al)"
#
# retrieve_fd
#
# Same as retrieve, but perform from an already opened file descriptor instead.
#
sub retrieve_fd {
	my ($file) = @_;
	my $fd = fileno($file);
	croak "Not a valid file descriptor" unless defined $fd;
	my $self;
	eval { $self = pretrieve($file) };		# Call C routine
	croak $@ if $@ =~ s/\.?\n$/,/;
	return $self;
}

# end of Storable::retrieve_fd
1;
