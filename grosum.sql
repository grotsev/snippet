type GrosumImpl as object
( grow number
, fall number
, static function ODCIAggregateInitialize(sctx in out GrosumImpl) return number
, member function ODCIAggregateIterate(self in out GrosumImpl, value in number) return number
, member function ODCIAggregateTerminate(self in GrosumImpl, returnValue out number, flags in number) return number
, member function ODCIAggregateMerge(self in out GrosumImpl, ctx2 in GrosumImpl) return number
)


type body GrosumImpl is

static function ODCIAggregateInitialize(sctx in out GrosumImpl)
return number is
begin
    sctx := GrosumImpl(0, 0);
    return ODCIConst.Success;
end;

member function ODCIAggregateIterate(self in out GrosumImpl, value in number) return number is
begin
    self.grow := self.grow + value;
    if self.grow < 0 then
        self.fall := self.fall - self.grow;
        self.grow := 0;
    end if;
    return ODCIConst.Success;
end;

member function ODCIAggregateTerminate(self in GrosumImpl, returnValue out number, flags in number) return number is
begin
    returnValue := self.grow;
    return ODCIConst.Success;
end;

member function ODCIAggregateMerge(self in out GrosumImpl, ctx2 in GrosumImpl) return number is
begin
    if self.grow < ctx2.fall then
        self.fall := self.fall + ctx2.fall - self.grow;
        self.grow := ctx2.grow;
    else
        self.grow := self.grow + ctx2.grow - ctx2.fall;
    end if;
    return ODCIConst.Success;
end;

end;

CREATE OR REPLACE function grosum(input number) return number parallel_enable aggregate using GrosumImpl;

-- Пример использования
with change(time, diff) as (
    select 1, 10 from dual union all
    select 2, -8 from dual union all
    select 3, -5 from dual union all
    select 4, 4 from dual
)
select time
     , grosum(diff) over (order by time) as balance
from change
