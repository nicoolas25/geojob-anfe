## Job offer gatherer and displayer

This tools is used at home to have a nice visualisation of
some job board that provides no map display of their offers.

## Install

Use the Store::PStore if you can! Otherwise here is the setup
to follow to use the PostgreSQL database.

1. `docker run --name geojob-postgres  -p 127.0.0.1:5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres:9.5`
2. Create the database with the postgresql tool: `createdb`
3. Add the environment variable `DATABASE_URL=postgres://postgres:mysecretpassword@127.0.0.1:5432/geojob`
4. Run the web application (still with the `DATABASE_URL`)
