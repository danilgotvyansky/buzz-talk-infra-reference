from flask import Flask, request, jsonify
import pymysql.cursors
import logging
import traceback

# Configure logging
logging.basicConfig(filename='/home/cpanel_username/prometheus/dbhealthcheck/dbhealthcheck.log', level=logging.INFO,
                    format='%(asctime)s:%(levelname)s:%(message)s')

app = Flask(__name__)


def check_mysql_connection(host, user, password, db):
    connection = None
    try:
        connection = pymysql.connect(host=host,
                                     user=user,
                                     password=password,
                                     database=db,
                                     charset='utf8mb4',  # Ensuring the charset is set to support all characters
                                     cursorclass=pymysql.cursors.DictCursor)
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            return True
    except Exception as e:
        logging.error("Failed to connect to MySQL database. Error: %s", str(e))
        return False
    finally:
        if connection:
            connection.close()


@app.route('/healthcheck/mysql', methods=['GET'])
def healthcheck_mysql():
    host = request.args.get('host')
    user = request.args.get('user')
    password = request.args.get('password')
    db = request.args.get('db')

    # Log the received details for debugging
    logging.debug(f"Received DB details - Host: {host}, User: {user}, Password: {password}, DB: {db}")

    # Basic validation to check if all parameters are received
    if host and user and password and db:
        if check_mysql_connection(host, user, password, db):
            return jsonify({"status": "success", "code": 200}), 200
        else:
            return jsonify({"status": "failure", "code": 500}), 500
    else:
        # If any parameter is missing, log this event and return a bad request response
        logging.debug("Missing one or more database connection parameters.")
        return jsonify({"status": "failure", "message": "Missing database connection parameter.", "code": 400}), 400


if __name__ == '__main__':
    app.run(debug=True)
