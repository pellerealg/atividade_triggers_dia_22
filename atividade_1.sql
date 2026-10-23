create table estoque (
    id serial primary key,
    nome_item varchar(100) not null,
    quantidade int not null default 0
);

create or replace function fn_valida_estoque_minimo()
returns trigger as $$
begin
    if new.quantidade < 0 then
        raise exception 'Operação cancelada! O item "%" não pode ter estoque negativo (Tentativa: % unidade(s)).', 
            NEW.nome_item, NEW.quantidade;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_valida_estoque
before insert or update on estoque
for each row
execute function fn_valida_estoque_minimo();

insert intp estoque (nome_item, quantidade) values ('Teclado Mecânico', 10);

update estoque set quantidade = 2 where id = 1
