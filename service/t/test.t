use Test::More qw(no_plan);
use Test::Mojo;
use utf8;
use Modern::Perl;
use FindBin;
require "$FindBin::Bin/../myapp.pl";

my $t = Test::Mojo->new();

$t->get_ok('/')->status_is(200)->json_is('/status' => "ok");

$t->put_ok('/add' => form => { barcode => '123', make => 'Toyota', part_number => '123-Norm al'})
    ->status_is(200)->json_is('/status' => "ok");

$t->put_ok('/add' => form => { barcode => '12 4', make => 'Toyota', part_number => '124/no '})
    ->status_is(200)->json_is('/status' => "ok");

$t->get_ok('/search' => form => { barcode => '12 3'})
    ->status_is(200)
    ->json_is('/status' => "ok")
    ->json_is('/items/0/barcode' => "123")
    ->json_is('/items/0/part_number' => "123Normal")
    ->json_is('/items/0/make' => "Toyota");

$t->get_ok('/search' => form => { barcode => '12.4'})
    ->status_is(200)
    ->json_is('/status' => "ok")
    ->json_is('/items/0/barcode' => "124")
    ->json_is('/items/0/part_number' => "124no")
    ->json_is('/items/0/make' => "Toyota");

done_testing();