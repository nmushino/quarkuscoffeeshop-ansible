#!/bin/bash

### coffeeshopadminで実行する
export PGPASSWORD=$(oc get secret coffeeshopdb-pguser-coffeeshopadmin -n quarkuscoffeeshop-demo -o jsonpath='{.data.password}' | base64 -d)
export PGHOSTNAME=$(oc get secret coffeeshopdb-pguser-coffeeshopadmin -n quarkuscoffeeshop-demo -o jsonpath='{.data.host}' | base64 -d)

psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "CREATE SCHEMA IF NOT EXISTS coffeeshop;"
psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "CREATE SCHEMA coffeeshop AUTHORIZATION coffeeshopadmin;"
psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "alter table if exists coffeeshop.LineItems
    drop constraint if exists FK6fhxopytha3nnbpbfmpiv4xgn;"
psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "drop table if exists coffeeshop.LineItems cascade;
drop table if exists coffeeshop.Orders cascade;
drop table if exists coffeeshop.OutboxEvent cascade;"
psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "create table coffeeshop.LineItems (
                           id uuid not null,
                           order_id varchar(255) not null,
                           item varchar(255),
                           lineItemStatus varchar(255),
                           price numeric(19, 2),
                           primary key (id)
);"

psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "create table coffeeshop.Orders (
                        order_id varchar(255) not null,
                        loyaltyMemberId varchar(255),
                        location     varchar(255),
                        orderSource varchar(255),
                        orderStatus varchar(255),
                        timestamp timestamp,
                        primary key (order_id)
);"

psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "create table coffeeshop.OutboxEvent (
                             id uuid not null,
                             aggregatetype varchar(255) not null,
                             aggregateid varchar(255) not null,
                             type varchar(255) not null,
                             timestamp timestamp not null,
                             payload varchar(8000),
                             primary key (id)
);"

psql -h ${PGHOSTNAME} -p 5432 -U coffeeshopadmin coffeeshopdb  -c "alter table if exists coffeeshop.LineItems
    add constraint FK6fhxopytha3nnbpbfmpiv4xgn
        foreign key (order_id)
            references coffeeshop.Orders;"