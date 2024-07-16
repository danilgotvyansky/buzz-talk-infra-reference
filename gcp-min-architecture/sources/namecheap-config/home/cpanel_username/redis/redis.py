import redis_server

server_path = redis_server.REDIS_SERVER_PATH  
cli_path = redis_server.REDIS_CLI_PATH

print(f"""
You can start redis-server by executing this command:
nohup {server_path} /home/cpanel_username/redis/etc/redis.conf &

You can use redis-cli by executing this command:
{cli_path}
""")