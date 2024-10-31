package CaesarCipher;

use warnings;
use strict;

# Its perl, I gotta use hashmaps ;)
my %NUM_TO_ALPHA;
@NUM_TO_ALPHA{0 .. 25} = ('a' .. 'z');

my %ALPHA_TO_NUM;
@ALPHA_TO_NUM{'a' .. 'z'} = (0 .. 25);

sub new {
    my ($class, $args) = @_;

    my $shift = $args->{shift_index};
    my $message = $args->{message};

    # Only accept ints for shift value.
    if (!defined $shift || $shift !~ /^\d+$/) {
        die "Invalid shift value! Must be an integer between 0 and 25.";
    }

    if (!defined $message || $message !~ /\w/) {
        die "Invalid message text! Has to have some ascii chars.";
    }

    my $self = {
        shift   => $shift,
        message => $message,
    };

    return bless $self, $class;
}

sub _shift_msg {
    my ($self, $direction) = @_;

    my @shifted_msg;

    for my $char ( split('', $self->{message}) ) {
        if ($char =~ ' ' || $char !~ /\w/ || $char =~ "\n") {
            push @shifted_msg, $char;
            next;
        } 

        $char = lc $char;

        my $base_index = $ALPHA_TO_NUM{$char};
        my $shift_index;

        # Shift right is encode.
        if ($direction eq 'right') {
            $shift_index = $base_index + $self->{shift};
        }

        # Shift left is decode.
        if ($direction eq 'left') {
            $shift_index = $base_index - $self->{shift};
        }

        # Enable alphabet wrap around.
        if ($shift_index > 25 || $shift_index < 0) {
            $shift_index = $shift_index % 26;
            $shift_index = abs $shift_index;
        }

        push @shifted_msg, $NUM_TO_ALPHA{$shift_index};
    }

    my $shifted_msg = join '', @shifted_msg;
    return $shifted_msg;
}

sub encode_msg {
    my $self = shift;
    return _shift_msg($self, 'right');
}

sub decode_msg {
    my $self = shift;
    return _shift_msg($self, 'left');
}
