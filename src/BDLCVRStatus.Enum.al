enum 50401 "BDL CVR Status"
{
    Caption = 'BDL CVR-status';
    Extensible = true;

    value(0; Unknown)
    {
        Caption = 'Ukendt';
    }
    value(1; Active)
    {
        Caption = 'Aktiv';
    }
    value(2; Ceased)
    {
        Caption = 'Ophørt';
    }
    value(3; UnderBankruptcy)
    {
        Caption = 'Under konkurs';
    }
    value(4; Dissolved)
    {
        Caption = 'Opløst';
    }
}
