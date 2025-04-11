import duckdb
import pandas as pd

def query_duckdb():
    con = duckdb.connect('dev.duckdb')
    print(con)
    df = con.execute("select * from provider_addresses_agg").fetchdf()
    print(df)


if __name__ == "__main__":
    query_duckdb()
