package Acme::IRC::Trust;
use Moose;

has _trust => (
    isa        => 'HashRef',
    is         => 'ro',
    init_arg   => 'trust',
    lazy_build => 1,
);

sub _build__trust { {} }

sub check {
    my ( $self, $channel, @users ) = @_;
    my %mode = ();
    for my $nickstr (@users) {
        my $nick = parse_user($nickstr);
        next unless my $trust_record = $self->_trust->{$nick};
        $mode{$nick} = 'o' if $trust_record eq 'everywhere';
        if ( ref $trust_record eq 'ARRAY' ) {
            $mode{$nick} = 'o' if grep { $_ eq $channel } @$trust_record;
        }
        if ( ref $trust_record eq 'HASH' ) {
            $mode{$nick} = 'v' if $trust_record->{$channel} >= 0.25;
            $mode{$nick} = 'h' if $trust_record->{$channel} >= 0.5;
            $mode{$nick} = 'o' if $trust_record->{$channel} >= 1;
        }
    }
    return unless %mode;
    return \%mode;
}

# replace with POCO IRC Common
sub parse_user {
    return unless defined wantarray;    # don't do anything in void context
    my ($nickstr) = @_;
    return unless $nickstr;
    my ( $nick, $hostmask ) = split /!/, $nickstr;
    return $nick unless wantarray;  # if we only want a scalar return the nick
    my ( $user, $host ) = split /@/, $hostmask;
    return ( $nick, $user, $host );
}

no Moose;
1;
__END__
