import duckdb

class Runner:

    def __init__(self, db_path = "/opt/dbt/Data/Processed/bikeshare.duckdb"):

        self.CON = duckdb.connect(db_path)

    def run(self, SQL_FILE):

        with open(SQL_FILE, 'r') as f:
            sql = f.read()
            self.CON.execute(sql)