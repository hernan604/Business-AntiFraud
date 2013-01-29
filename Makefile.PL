

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Business::AntiFraud',
    VERSION_FROM => 'lib/Business/AntiFraud.pm', # finds \$VERSION
    AUTHOR       => 'Hernan Lopes (hernanlopes@gmail.com)',
    ABSTRACT     => 'Interface for multiple antifraud systems',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
