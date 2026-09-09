import os
import glob
import pandas as pd
from sqlalchemy import create_engine

DATABASE_URL = "postgresql+psycopg2://localhost/olist_analytics"

engine = create_engine(DATABASE_URL)

for filepath in sorted(glob.glob("data/raw/*.csv")):
    table_name = os.path.splitext(os.path.basename(filepath))[0]
    df = pd.read_csv(filepath)
    df.to_sql(table_name, engine, if_exists="replace", index=False)
    print(f"{table_name}: {len(df):,} rows loaded")

engine.dispose()
print("All tables loaded successfully")

