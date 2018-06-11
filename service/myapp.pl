#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use Mojolicious::Plugin::Database;

plugin 'PODRenderer';

plugin 'database' => {
    dsn      => "dbi:SQLite:dbname=./barcode.sqlite",
    options  => { RaiseError => 1,  PrintError => 1, AutoCommit => 1 },
    helper   => 'db',
};

#CREATE TABLE IF NOT EXISTS barcodes
#    (
#        barcode varchar(100) NOT NULL,
#    make varchar(50) NOT NULL,
#    part_number varchar(50) NOT NULL
#    );
#CREATE INDEX IF NOT EXISTS  barcodes_barcode_make_part_number_index ON barcodes (barcode, make, part_number);
#CREATE INDEX IF NOT EXISTS  barcodes_barcode_index ON barcodes (barcode);

get '/' => sub {
    my $self = shift;

    $self->db->do("CREATE TABLE IF NOT EXISTS barcodes(barcode varchar(100) NOT NULL,make varchar(50) NOT NULL,part_number varchar(50) NOT NULL);");
    $self->db->do("CREATE INDEX IF NOT EXISTS barcodes_barcode_make_part_number_index ON barcodes (barcode, make, part_number)");
    $self->db->do("CREATE INDEX IF NOT EXISTS barcodes_barcode_index ON barcodes (barcode)");

    $self->render(
        json => {
            status => "ok",
        }
    );
};

get '/search' => sub {
    my $self = shift;

    my $barcode = $self->param('barcode');
    $barcode =~ s/\W//gi;

    my $items = $self->db->selectall_arrayref("SELECT * FROM barcodes WHERE barcode=?",{Slice=>{}}, $barcode);

    $self->render(
        json => {
            status => "ok",
            items => $items,
        }
    );
};

put '/add' => sub {
    my $self = shift;

    my $barcode = $self->param('barcode');
    $barcode =~ s/\W//gi;

    my $part_number = $self->param('part_number');
    $part_number =~ s/\W//gi;

    $self->db->do("INSERT OR IGNORE INTO barcodes(barcode,make,part_number) VALUES (?,?,?)",{}
        , $barcode, $self->param('make'), $part_number);

    $self->render(
        json => {
            status => "ok"
        }
    );
};

app->start;
