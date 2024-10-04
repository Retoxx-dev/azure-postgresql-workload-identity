import psycopg2
import os

from azure.identity import DefaultAzureCredential

def get_connection_uri():
    dbhost = os.environ.get("DBHOST")
    dbname = os.environ.get("DBNAME")
    dbuser = os.environ.get("DBUSER")
    sslmode = os.environ.get("SSL_MODE")

    credential = DefaultAzureCredential()

    password = credential.get_token("https://ossrdbms-aad.database.windows.net/.default").token

    db_uri = f"postgresql://{dbuser}:{password}@{dbhost}/{dbname}?sslmode={sslmode}"
    return db_uri

def main():
    connection_string = get_connection_uri()

    connection = psycopg2.connect(connection_string)
    print("Connection established")
    cursor = connection.cursor()

    # Drop previous table of same name if one exists
    cursor.execute("DROP TABLE IF EXISTS inventory;")
    print("Finished dropping table (if existed)")

    # Create a table
    cursor.execute("CREATE TABLE inventory (id serial PRIMARY KEY, name VARCHAR(50), quantity INTEGER);")
    print("Finished creating table")

    # Insert some data into the table
    cursor.execute("INSERT INTO inventory (name, quantity) VALUES (%s, %s);", ("banana", 150))
    cursor.execute("INSERT INTO inventory (name, quantity) VALUES (%s, %s);", ("orange", 154))
    cursor.execute("INSERT INTO inventory (name, quantity) VALUES (%s, %s);", ("apple", 100))
    print("Inserted 3 rows of data")

    connection.commit()
    cursor.close()
    connection.close()
    print("Connection closed")

if __name__ == "__main__":
    main()
