package Acme::IRC::Trust;
use Moose;

has _trust => (
    isa        => 'HashRef',
    is         => 'ro',
    init_arg   => 'trust',
    lazy_build => 1,
);

sub _build__trust { {} }

has op_list_size => (
    isa     => 'Int',
    is      => 'ro',
    default => 5,
);

sub is_op {
    my ($trust) = @_;
    return 1 if $trust >= 1;
    return 1 if $trust eq 'o';
    return 0;
}

sub is_halfop {
    my ($trust) = @_;
    return 1 if $trust >= 0.5;
    return 1 if $trust eq 'h';
    return 0;
}

sub is_voice {
    my ($trust) = @_;
    return 1 if $trust >= 0.25;
    return 1 if $trust eq 'v';
    return 0;

}

sub check {
    my ( $self, $channel, @users ) = @_;
    my %mode = ();
    for my $nickstr (@users) {
        my $nick = parse_user($nickstr);
        next unless my $trust_record = $self->_trust->{$nick};
        if ( !ref $trust_record ) {
            $mode{$nick} = 'o' if $trust_record eq 'everywhere';
            next;
        }
        if ( ref $trust_record eq 'ARRAY' ) {
            $mode{$nick} = 'o' if grep { $_ eq $channel } @$trust_record;
        }
        if ( ref $trust_record eq 'HASH' ) {
            my $trust = $trust_record->{$channel};
            $mode{$nick} = 'o' if ( $self->is_op($trust) );
            $mode{$nick} = 'h' if ( $self->is_halfop($trust) );
            $mode{$nick} = 'v' if ( $self->is_voice($trust) );
        }
    }
    return unless %mode;
    return \%mode;
}

sub get_modes {
    my ( $self, $channel, @users ) = @_;

    my $modes = $self->check( $channel, @users );
    return unless $modes;
    my $limit = $self->op_list_size - 1;
    my @output;
    while (@users) {
        my ( $start, $end ) = ( '+', '' );
        for ( 0 .. $limit ) {
            last unless @users;
            my $nick = parse_user( shift @users );
            next unless exists $modes->{$nick};
            $start .= $modes->{$nick};
            $end   .= " $nick";
        }
        push @output, "$start$end";
    }

    return \@output;
}

# replace with POCO IRC Common
sub parse_user {
    return unless defined wantarray;    # don' t do anything in void context
    my ($nickstr) = @_;
    return unless $nickstr;
    my ( $nick, $hostmask ) = split /!/, $nickstr;
    return $nick unless wantarray;    # if we only want a scalar return the nick
    my ( $user, $host ) = split /@/, $hostmask;
    return ( $nick, $user, $host );
}

no Moose;
1;
__END__
