create table contas (
id serial primary key,
nome_cliente varchar(150) not null,
saldo numeric (10,2) not null default 0.00
);

create table movimentacoes (
id serial primary key,
conta_id int references contas(id),
tipo varchar (1) check (tipo in('C', 'D')),
valor numeric (10,2) not null,
data_movimentacao timestamp default current_timestamp
);

create or replace function fn_atualizacao_saldo_conta()
returns trigger as $$
begin
if new.tipo = 'C' then 
update contas set saldo = saldo + new.valor where id = new.conta_id;
elsif new.tipo = 'D' then 
update contas set saldo = saldo - new.valor where id = new.conta.id;
end if;
return new;
end;
$$ language plpgsql;

create trigger trg_atualiza_saldo
after insert on movimentacoes
for each row
execute function fn_atualizacao_saldo_conta();
