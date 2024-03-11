#!/usr/bin/env perl
# Blind video game.
# By John R., March 2024.

use strict;
use warnings;
$| = 1;

use lib "$ENV{HOME}/perl5/lib/perl5";
use Getopt::Long;
use Data::Dumper;
use File::JSON::Slurper qw(read_json write_json);
use File::Touch 0.12;
use JSON;

my $SAVE_FILE = "$ENV{HOME}/.blind_saves.json";

# Help menu.
sub usage {
    my $err_msg = shift;
    print "$err_msg\n" if $err_msg;
    print <<~EOF;
      Name:
          blind.pl - Blind video game script

      Usage:
          blind.pl [options]

      Options:
        -help                   Print this help menu
        -list_saves             List saved games
        -load_save int          Load save number
        -new_game               Starts a new game
        -list_levels            List game levels
        -level int              Start at level number
        -debug                  Run in debug mode

      Defaults:
        -load_save 1            Loads default save game
      
    EOF
    exit;
}

my %O = (
    load_save => 1,
);

GetOptions(\%O,
    'help',
    'list_saves',
    'load_save=i',
    'new_game',
    'list_levels',
    'level=i',
    'debug'
) or usage();

# Sanity checks.
usage() if ($O{help});

&list_levels() if $O{list_levels};

&print_banner();

unless (-e $SAVE_FILE) {
    touch($SAVE_FILE);
    my %new_game = (saves => {});
    &new_save(1, \%new_game);
}

my $SAVE_DATA = read_json($SAVE_FILE);
if ($O{list_saves}) {
    foreach (sort keys %{$SAVE_DATA->{saves}}) {
        print "* Save #$_: $SAVE_DATA->{saves}{$_}{save_title}\n";
    }
    exit;
}
if ($O{new_game}) {
    my $new_save_num = (keys %{$SAVE_DATA->{saves}}) + 1;
    $O{load_save} = $new_save_num;
    &new_save($new_save_num, $SAVE_DATA);
}

my $SAVE = $SAVE_DATA->{saves}{$O{load_save}};
die "Save number: $O{load_save} NOT found!\n" unless $SAVE;

my $STATS = $SAVE->{stats};

&level_one() if ($SAVE->{level} == 1);
&level_two() if ($SAVE->{level} == 2);

exit;

sub list_levels {
    print <<~EOF;
        1)  The Hole    - Game intro (exposition)
        2)  The Barn    - You find your way into a rundown old barn
    EOF
    exit;
}

sub print_banner {
    print <<~EOF;

      ██████╗ ██╗     ██╗███╗   ██╗██████╗ 
      ██╔══██╗██║     ██║████╗  ██║██╔══██╗
      ██████╔╝██║     ██║██╔██╗ ██║██║  ██║
      ██╔══██╗██║     ██║██║╚██╗██║██║  ██║
      ██████╔╝███████╗██║██║ ╚████║██████╔╝
      ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝╚═════╝ 
         ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⣤⣤⣴⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
         ⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⠿⠛⠋⠉⠁⠀⠀⠀⠈⠙⠻⢷⣦⡀⠀⠀⠀⠀⠀⠀
         ⠀⠀⠀⠀⠀⣤⣾⡿⠋⠁⠀⣠⣶⣿⡿⢿⣷⣦⡀⠀⠀⠀⠙⠿⣦⣀⠀⠀⠀⠀
         ⠀⠀⢀⣴⣿⡿⠋⠀⠀⢀⣼⣿⣿⣿⣶⣿⣾⣽⣿⡆⠀⠀⠀⠀⢻⣿⣷⣶⣄⠀
         ⠀⣴⣿⣿⠋⠀⠀⠀⠀⠸⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⠀⠀⠀⠐⡄⡌⢻⣿⣿⡷
         ⢸⣿⣿⠃⢂⡋⠄⠀⠀⠀⢿⣿⣿⣿⣿⣿⣯⣿⣿⠏⠀⠀⠀⠀⢦⣷⣿⠿⠛⠁
         ⠀⠙⠿⢾⣤⡈⠙⠂⢤⢀⠀⠙⠿⢿⣿⣿⡿⠟⠁⠀⣀⣀⣤⣶⠟⠋⠁⠀⠀⠀
         ⠀⠀⠀⠀⠈⠙⠿⣾⣠⣆⣅⣀⣠⣄⣤⣴⣶⣾⣽⢿⠿⠟⠋⠀⠀⠀⠀⠀⠀⠀
         ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠙⠋⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    EOF
}

sub new_save {
    my ($save_num, $saves_hash) = @_;
    print "Please enter a name for new save: ";
    my $save_title = <STDIN>;
    print "\n";
    chomp $save_title;
    $saves_hash->{saves}{$save_num} = {
        save_title => $save_title,
        level => 1,
        stats => {
            health => 55,
            stamina => 30,
            vision => 0,
        },
    };
    print Dumper $saves_hash if $O{debug};
    write_json($SAVE_FILE, $saves_hash);
}

sub save_game {
    $SAVE_DATA->{saves}{$O{load_save}} = $SAVE;
    write_json($SAVE_FILE, $SAVE_DATA);
    print "Game Progress Saved!\n";
}

sub get_action {
    my ($accepted_actions) = shift;
    print "Actions: (";
    print "$_, " foreach (sort keys %$accepted_actions);
    print "\b\b)\n";
    print "Enter Actions: ";
    my $action = <STDIN>;
    print "\n";
    chomp $action;
    # Recurse if input is invalid!
    unless (exists $accepted_actions->{$action}) {
        print "Invalid input! Pick again!\n";
        return &get_action($accepted_actions);
    }
    return $action;
}

sub cry {
    print <<~EOF;
    ---
    You start to cry but the salty tears burn like lava.

    You wince in pain which only causes more tears to flow.

    You try to hold your face but everything stings and burns as if your
    eyelids were covered in cactus spines.

    If you squint through the tears you can slightly see the blurry outline of
    your hands in front of you.

    But the pain of opening your eye is too much. So you close them again tight
    and continue to cry.

    -10 Health
    -5 Stamina
    +5 Vision
    ---
    EOF
}

sub feel_around {
    print <<~EOF;
    ---
    You feel around you in a panicked frenzied state.

    All around you is loose soil and high dirt walls.

    You bring yourself to your feet only to realize the dirt walls extend
    above your head in all directions.

    You can just about feel the top of it when all of the sudden you run
    into something on the ground.

    You reach down to realize its a backpack on the ground with something
    inside of it.
    ---
    EOF
}

sub jump_up {
    if ($STATS->{vision} >= 15) {
        print <<~EOF;
        ---
        You jump up an try to throw your arms out of the hole to find anything to
        grab onto.

        You squint through the pain and see a blurry potential object to grab
        slightly to your left.

        You manage to grab hold of what feels like a tree stump. But you are unable
        to get your arms around it.

        After a few minutes of struggling you fall back into the hole hurting your
        ankle on the way down.

        -15 Health
        -15 Stamina
        ---
        EOF
        return;
    }
    print <<~EOF;
    ---
    You jump up an try to throw your arms out of the hole to find anything to
    grab onto.

    You reach around invain unable to find anything on top of the hole to grab
    onto.

    You think to yourself, "If only I could see a little bit!"

    After a few minutes of struggling you fall back into the hold hurting your
    ankle on the way down.

    -15 Health
    -15 Stamina
    ---
    EOF
}

sub open_backpack {
    print <<~EOF;
    ---
    You manage to find a zipper and open the backpack.

    Inside you find a bottle of water and a metal chain.

    You sling the backpack over your shoulder as you try to think of what to do
    with your new found items.
    ---
    EOF
}

sub drink_water {
    print <<~EOF;
    ---
    You open the plastic water bottle and chug the contents of it down.

    The half full bottle is gone before you know it. But the fresh cold water
    left you feeling refreshed and rejuvinated.

    +10 Health
    +15 Stamina
    ---
    EOF
}

sub splash_face {
    print <<~EOF;
    ---
    You open the plastic water bottle and pour the contents of it onto your
    burning eyes.

    The sudden splash to your face shocks your system and wakes you up.

    Although it leaves you freezing and struggling to catch your breath in the
    friged air.

    After a few moments you realize you can now open your eye lids slightly and
    see some light and shapes through them.

    -5 Health
    +5 Stamina
    +10 Vision
    ---
    EOF
}

sub throw_chain {
    print <<~EOF;
    ---
    You stand back and start trying to throw the chain up over the stump.

    It takes a few tries but eventually you get it stuck over the stump.

    You tie the chain off in a slip knot and pull it tight around the stump.

    You pull on the chain with all of your weight and the stump holds firm.

    You think to yourself, "Its time to get out of this hole!"
    ---
    EOF
}

sub climb_out {
    print <<~EOF;
    ---
    You jump up and grab onto the chain as far up on it as you can get.

    You struggle with all of your remaining strength to pull your body up over
    the edge of the hole.

    Once you get your check up out of the hole you are able to reach around
    the stump and pull yourself up further.

    As soon as your leg is over the edge of the hole you are able to push
    yourself the rest of the way out.

    Now fully out of the hole, you roll over on your back to catch your breath.

    You are still freezing to death. But off in the distance you are able to
    see the faint outline of what appears to be some sort of building a few
    hundered yards away.
    ---
    EOF
}

sub l1_check_action {
    my ($action, $possible_options) = @_;

    exit if ($action eq 'quit');
    if ($action eq 'save') {
        &save_game();
        return 1
    }

    if ($action eq 'cry') {
        $STATS->{health} -= 10;
        $STATS->{stamina} -= 5;
        $STATS->{vision} += 5;
        &cry();
    } 
    
    if ($action eq 'wait') {
        $STATS->{health} -= 5;
        $STATS->{stamina} += 5;
        $STATS->{vision}++;
        print <<~EOF;
        ---
        The bitter cold takes some health, but you regain some stamina.

        Your eyes feel ever so slightly better.

        -5 Health
        +5 Stamina
        +1 Vision
        ---
        EOF
    }

    if ($action eq 'feel-around') {
        delete $possible_options->{'feel-around'};
        $possible_options->{'open-backpack'} = 1;
        $possible_options->{'jump-up'} = 1;
        &feel_around();
    }

    if ($action eq 'jump-up') {
        if ($SAVE->{inventory}{chain} and $STATS->{vision} >= 15) {
            $possible_options->{'throw-chain'} = 1;
        }
        if ($STATS->{stamina} >= 15) {
            delete $possible_options->{'jump-up'};
            $STATS->{stamina} -= 15;
            $STATS->{health} -= 15;
            &jump_up();
        } else {
            print <<~EOF;
            ---
            You are too exhaused and do not have enough stamina to jump!
            ---
            EOF
        }
    }

    if ($action eq 'open-backpack') {
        $SAVE->{inventory}{chain} = 1;
        $SAVE->{inventory}{water} = 1;
        $possible_options->{'drink-water'} = 1;
        $possible_options->{'splash-face'} = 1;
        delete $possible_options->{'open-backpack'};
        &open_backpack();
    }

    if ($action eq 'drink-water') {
        $STATS->{health} += 10;
        $STATS->{stamina} += 15;
        delete $possible_options->{'drink-water'};
        delete $possible_options->{'splash-face'};
        delete $SAVE->{inventory}{water};
        &drink_water();
    }

    if ($action eq 'splash-face') {
        $STATS->{health} -= 5;
        $STATS->{stamina} += 5;
        $STATS->{vision} += 10;
        delete $possible_options->{'drink-water'};
        delete $possible_options->{'splash-face'};
        delete $SAVE->{inventory}{water};
        &splash_face();
    }

    if ($action eq 'throw-chain') {
        $possible_options->{'climb-out'} = 1;
        delete $possible_options->{'throw-chain'};
        &throw_chain();
    }

    if ($action eq 'climb-out') {
        if ($STATS->{stamina} < 15) {
            print <<~EOF;
            ---
            You are too exhaused and do not have enough stamina to climb out of the hole!
            ---
            EOF
            return 1;
        }
        $STATS->{stamina} -= 15;
        $STATS->{health} -= 15;
        &climb_out();
        return 0;
    }
    return 1;
}

sub level_one {
    print <<~EOF;
    ---
    # Level 1 - The Hole

    You wake up laying on your back in the dirt with a massive headache.

    As you come to you realize your eyes are in searing pain.

    Its cold and snowing. You are freezing and shivering. But the cold
    snowflakes falling provide some relief for your burning eyes.

    You have no idea where you are or how you got there.

    You reach up to you eyes but your fingertips sting as you try to touch
    your raw burning eyelids.

    You cannot see.

    ---
    EOF

    # In case there's already a game with set of options saved.
    unless ($SAVE->{possible_options}) {
        $SAVE->{possible_options} = {'wait' => 1, 'feel-around' => 1, 'cry' => 1, 'save' => 1, 'quit' => 1};
    }
    my $in_hole = 1;
    while ($in_hole) {
        print <<~EOF;
        ## Stats
        ## - Health: $STATS->{health}
        ## - Stamina: $STATS->{stamina}
        ## - Vision: $STATS->{vision}
        EOF
        if ($STATS->{health} <= 0) {
            print <<~EOF;
            ---
            You died in a hole.

            Game Over!
            ---
            EOF
            exit;
        }
        $in_hole = &l1_check_action(&get_action($SAVE->{possible_options}), $SAVE->{possible_options});
        if ($STATS->{stamina} < 15) {
            delete $SAVE->{possible_options}{'jump-up'};
        } else {
            $SAVE->{possible_options}{'jump-up'} = 1;
        }
    }
    print <<~EOF;
    ---
    Level 1 Complete!

    Congradulations on not dying in a hole!

    ## Final Stats
    ## - Health: $STATS->{health}
    ## - Stamina: $STATS->{stamina}
    ## - Vision: $STATS->{vision}
    ---
    EOF
    $SAVE->{level} = 2;
    &save_game();
}


sub level_two {
    print <<~EOF;
    ---
    Level two not started yet!
    ---
    EOF
}
