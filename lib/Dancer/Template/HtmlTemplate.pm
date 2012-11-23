package Dancer::Template::HtmlTemplate;

use strict;
use warnings;
use Dancer::ModuleLoader;
use Dancer::FileUtils 'path';

use base 'Dancer::Template::Abstract';

our $VERSION = '0.06';


sub init {
    my ($self) = @_;

    die "HTML::Template is needed by Dancer::Template::HtmlTemplate"
      unless Dancer::ModuleLoader->load('HTML::Template');
}

sub render($$$) {
    my ($self, $template, $tokens) = @_;
    die "'$template' is not a regular file"
      if !ref($template) && (!-f $template);

    _flatten($tokens)
      if ref $tokens eq 'HASH';

    my $config = $self->config;
    if ($config->{die_on_bad_params}) {
        Dancer::Logger::warning(
            "Ignoring die_on_bad_params setting supplied - see documentation"
        );
        delete $config->{die_on_bad_params};
    }
    my $ht = HTML::Template->new(
        filename => $template,
        %$config,
        die_on_bad_params => 0, # Required, as we pass through other params too
    );
    $ht->param($tokens);
    return $ht->output;

}

sub _flatten {
    my ($tokens) = @_;
    my @keys = keys %$tokens;
    while (@keys) {
        my $key = shift @keys;
        ref $tokens->{$key} eq 'HASH'
          or next;
        my $value = delete $tokens->{$key};
        my @new_keys = map "$key.$_", keys %$value;
        @$tokens{@new_keys} = values %$value;
        push(@keys, @new_keys);
    }
}

1;
__END__

=pod

=head1 NAME

Dancer::Template::HtmlTemplate - HTML::Template wrapper for Dancer

=head1 DESCRIPTION

This class is an interface between Dancer's template engine abstraction layer
and the L<HTML::Template> module.

In order to use this engine, use the template setting:

    template: html_template

This can be done in your config.yml file or directly in your app code with the
B<set> keyword.

Since HTML::Template uses different syntax to other template engines like
Template::Toolkit, the default layout C<main.tt> generated by the scaffolding
script must be updated to use HTML::Template directives:

    [% content %]

needs to be changed to:

    <!--tmpl_var name="content"-->

or

    <TMPL_VAR name="content">

Future versions of Dancer may ask you which template engine you wish to use, and
write the default layout and example templates appropriately.

Also, the current default file extension for template files is C<.tt>; at the
time this template engine wrapper was produced, the template engine wrapper
could not override default file extensions.  This is now possible, but I haven't
made this change as it would break applications relying on the default being
C<.tt>.

If you want to change the extension used, use the C<extension> configuration
option, for example, to declare that the extension should be C<.tmpl>:

    template: HtmlTemplate
    engines:
        HtmlTemplate:
            extension: 'tmpl'

Even if you use the default C<.tt>, you may want to explictly set that, as
future versions may default to a more suitable 



=head1 Handling nested hashrefs

Since HTML::Template does not allow you to access nested hashrefs (at least,
not without switching to using  L<HTML::Template::Pluggable> along with
L<HTML::Template::Plugin::Dot>), this module "flattens" nested hashrefs.

For instance, the session contents are passed to Dancer templates as C<session>
- to access a key of that hashref named C<username>, you'd say:

    <TMPL_VAR name="session.username">



=head1 SEE ALSO

L<Dancer>, L<HTML::Template>


=head1 AUTHOR
 
David Precious, C<< <davidp@preshweb.co.uk> >>
 
 
=head1 CONTRIBUTING
 
This module is developed on Github at:                                                          
 
L<http://github.com/bigpresh/Dancer-Template-HtmlTemplate>
 
Feel free to fork the repo and submit pull requests!

=head1 ACKNOWLEDGEMENTS

Thanks to Damien Krotkine for providing code to flatten nested hashrefs in a way
that allows HTML::Template templates to make use of them.


=head1 LICENSE

This module is free software and is released under the same terms as Perl
itself.

=cut

