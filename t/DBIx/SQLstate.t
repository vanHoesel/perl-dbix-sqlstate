use Test::More;

use DBIx::SQLstate;

is sqlstate_token "HY017", 'InvalidUseOfAutomaticallyAllocatedDescriptorHandle',
    "Got the right token for [HY017]";

done_testing;

__END__
