use Test::More;

use DBIx::SQLstate;

is( DBIx::SQLstate->token("HY017"),
    'InvalidUseOfAutomaticallyAllocatedDescriptorHandle',
    "Got the right token for [HY017]"
);

is( DBIx::SQLstate->const("0N000"),
    'SQL_XML_MAPPING_ERROR',
    "Got the right token for [0N000]"
);

done_testing;

__END__
