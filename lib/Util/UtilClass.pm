#--------------------------------------------------------------------------------------------------------------------------
# h: lib::Util::UtilsClass
#--------------------------------------------------------------------------------------------------------------------------
package lib::Util::UtilClass;

#--------------------------------------------------------------------------------------------------------------------------
# pkg system
#--------------------------------------------------------------------------------------------------------------------------
use Moo;

#--------------------------------------------------------------------------------------------------------------------------
# pkg system
#--------------------------------------------------------------------------------------------------------------------------
use Text::Xslate;
use Types::Standard qw(Str InstanceOf HashRef);
use Data::Dumper;
use utf8;

#--------------------------------------------------------------------------------------------------------------------------
# pkg local
#--------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------
# attributes
#--------------------------------------------------------------------------------------------------------------------------
has pkg_name      => ( is => 'ro', lazy => 1, default => __PACKAGE__,             isa => Str     );
has base_name     => ( is => 'ro', lazy => 1, default => __FILE__,                isa => Str     );
has data          => ( is => 'rw', lazy => 1, default => sub{ {} },               isa => HashRef );
has class         => ( is => 'rw', lazy => 1, default => '',                      isa => Str     );
has attribut      => ( is => 'rw', lazy => 1, default => '',                      isa => Str     );
has parent_dir    => ( is => 'rw', lazy => 1, default => '',                      isa => Str     );
has template_file => ( is => 'rw', lazy => 1, default => 'libs/Utils/UtilClass.tx', isa => Str     );

#--------------------------------------------------------------------------------------------------------------------------
# f* default builder
#---
sub BUILD {
  my $self = shift;
}

#--------------------------------------------------------------------------------------------------------------------------
# f* do_make builder
#---
sub do_make {
  my $self = shift;
  print "[$0][do_make] - inici\n";

  my $ok_class    = $self->_validate_class;
  my $ok_attribut = $self->_validate_attributes;

  # validate class
  print "class..... ok - " . $ok_class      . " - value: "  . $self->class     . "\n";
  print "attribut.. ok - " . $ok_attribut . " - values: " . $self->attribut . "\n";

  # do make class or package
  if ( $ok_class && $ok_attribut ) {

  # show message error bad aruguments input
  } else {

  }


  print "[$0][do_make] - final\n";
}

#--------------------------------------------------------------------------------------------------------------------------
# f* do_make_class_and_attributes:
#---
sub do_make_class_and_attributes  {
  my $self = shift;
  print "[$0][do_make_class_and_attributes] - inici\n";


  print "[$0][do_make_class_and_attributes] - final\n";
}

#--------------------------------------------------------------------------------------------------------------------------
# f* _validate_class:
#---
sub _validate_class {
  my $self   = shift;
  my $return = 0;

  if ( $self->class =~ /^\w+$/ ) {
    $self->data->{_class_name_} = $self->class( ucfirst($self->class) );
    $return = 1;
  }

  return $return;
}

#--------------------------------------------------------------------------------------------------------------------------
# f* _validate_attributes:
#---
sub _validate_attributes {
  my $self = shift;

  return 0 if $self->attribut eq '';

  my ($i, $end, @attributes, $attributes_count ) = ( 0, 1, (), 0);

  @attributes       = split /,/, $self->attribut;
  $attributes_count = @attributes;

  while ( $i < $attributes_count and $end == 1) {

    my @list_attribute = split /:/, $attributes[$i];

    if ( $list_attribute[0] ne '' ) {
      # set value to hash
      $self->data->{_list_attributes_}->{$attributes[$i]} = {
        'name' => $list_attribute[0],
        'type' => $list_attribute[1] || '',
        'init' => $list_attribute[2] || '',
      };

    } else {
      $end = 0;
    }
    $i++;
  }

  print "[$0][_validate_attributes] Error invalid attribute_type or attribute_init\n" if !$end;
  return $end;
}


#--------------------------------------------------------------------------------------------------------------------------
# f* demolish:
#---
sub demolish  {
  my $self = shift;
  foreach (values %$self) { $_->DESTROY if ref $_ eq __PACKAGE__; }
  %$self = ();
}

# end Moo package
#----------------------------------------------------------------------------------------------------------
1;
