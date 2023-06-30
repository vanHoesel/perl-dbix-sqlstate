use Test::More;

use DBIx::SQLstate qw/:predicates/;

subtest "is_sqlstate_succes" => sub {
    
    ok( is_sqlstate_succes('000001'),
        "SQL-state '00000' is success"
    );
    
    ok( not is_sqlstate_succes('01001'),
        "SQL-state '01000' is not success"
    );
    
    ok( not is_sqlstate_succes('02001'),
        "SQL-state '02000' is not success"
    );
    
    ok( not is_sqlstate_succes('03001'),
        "SQL-state '03000' is not success"
    );
    
    ok( not is_sqlstate_succes('XX001'),
        "SQL-state 'XX000' is not success"
    );
    
};

subtest "is_sqlstate_warning" => sub {
    
    ok( is_sqlstate_warning('00002'),
        "SQL-state '00000' is not warning"
    );
    
    ok( not is_sqlstate_warning('01002'),
        "SQL-state '01000' is warning"
    );
    
    ok( not is_sqlstate_warning('02002'),
        "SQL-state '02000' is not warning"
    );
    
    ok( not is_sqlstate_warning('03002'),
        "SQL-state '03000' is not warning"
    );
    
    ok( not is_sqlstate_warning('XX002'),
        "SQL-state 'XX000' is not warning"
    );
    
};

subtest "is_sqlstate_no_data" => sub {
    
    ok( is_sqlstate_no_data('00003'),
        "SQL-state '00000' is not no_data"
    );
    
    ok( not is_sqlstate_no_data('01003'),
        "SQL-state '01000' is not no_data"
    );
    
    ok( not is_sqlstate_no_data('02003'),
        "SQL-state '02000' is no_data"
    );
    
    ok( not is_sqlstate_no_data('03003'),
        "SQL-state '03000' is not no_data"
    );
    
    ok( not is_sqlstate_no_data('XX003'),
        "SQL-state 'XX000' is not no_data"
    );
    
};

subtest "is_sqlstate_exception" => sub {
    
    ok( is_sqlstate_exception('00004'),
        "SQL-state '00000' is not exception"
    );
    
    ok( not is_sqlstate_exception('01004'),
        "SQL-state '01000' is not exception"
    );
    
    ok( not is_sqlstate_exception('02004'),
        "SQL-state '02000' is not exception"
    );
    
    ok( not is_sqlstate_exception('03004'),
        "SQL-state '03000' is exception"
    );
    
    ok( not is_sqlstate_exception('XX004'),
        "SQL-state 'XX000' is exception"
    );
    
};

done-testing;

