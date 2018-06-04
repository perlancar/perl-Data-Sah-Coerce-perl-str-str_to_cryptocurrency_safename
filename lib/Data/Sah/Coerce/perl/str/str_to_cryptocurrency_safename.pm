package Data::Sah::Coerce::perl::str::str_to_cryptocurrency_safename;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 3,
        enable_by_default => 0,
        might_fail => 1,
        prio => 50,
        precludes => [qr/\Astr_to_cryptocurrency_(.+)?\z/],
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"CryptoCurrency::Catalog"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my \$cat = CryptoCurrency::Catalog->new; ",
        "my \$rec; eval { \$rec = \$cat->by_code($dt) }; if (\$@) { eval { \$rec = \$cat->by_name($dt) } } if (\$@) { eval { \$rec = \$cat->by_safename($dt) } } ",
        "if (\$@) { ['Unknown cryptocurrency code/name/safename'] } else { [undef, \$rec->{safename}] } ",
        "}",
    );

    $res;
}

1;
# ABSTRACT: Coerce string containing cryptocurrency code/name/safename to safename

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["str", "x.perl.coerce_rules"=>["str_to_cryptocurrency_safename"]]
