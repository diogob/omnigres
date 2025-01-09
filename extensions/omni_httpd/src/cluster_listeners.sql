create or replace function cluster_listeners() returns setof omni_httpd.listeners
language plpgsql
as $$
declare
    dbname text;
begin
    for dbname in select datname from pg_database dbs where dbs.datname not in ('template0', 'template1', 'postgres')
    loop
        if (select has_listener from dblink('dbname=' || dbname || ' user=' || current_user, 'select exists(select from pg_extension x where x.extname = ''omni_httpd'')') e (has_listener boolean)) then
            return query select id, address, port, effective_port, protocol from dblink('dbname=' || dbname || ' user=' || current_user, 'select * from omni_httpd.listeners l') l (id integer, address inet, port omni_httpd.port, effective_port omni_httpd.port, protocol omni_httpd.http_protocol);
        end if;
    end loop;
    return;
end;
$$;
