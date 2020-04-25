function init() {
echo "" > .env
  echo "
version: '3'

services:
  " >docker-compose.yml
}

function setup_nginx() {

  append_to_env \#nginx \n

  port=$(screen_question "Ok,enter nginx port(default is 80): " "NGINX")

  port=${port:-80}

  append_to_env "NGINX_PORT=$port"



  echo "
## --------------------------------------------
## | 1 : web server nginx
## --------------------------------------------
  nginx:
    build:
      context: ./DockerConfig/Nginx
      dockerfile: Dockerfile
    expose:
      - 80
    ports:
      - ${NGINX_PORT}:80
    restart: always
    depends_on:
      - php
    volumes:
      - ./DockerConfig/Nginx/default.conf:/etc/nginx/conf.d/default.conf
      - ./ProjectSource:/var/www/html
  " >>docker-compose.yml

  tasks=("Port")
  progress_bar "Nginx" $tasks
}


function setup_php() {

  echo "
## --------------------------------------------
## | 2 : application server
## --------------------------------------------
  php:
    build:
      context: ./DockerConfig/Php
      dockerfile: Dockerfile
    restart: always
    expose:
      - 9000
    volumes:
      - ./ProjectSource:/var/www/html/
      - ./DockerConfig/Php/Config/upload.ini:/usr/local/etc/php/conf.d/upload.ini
      - ./DockerShareArea/Php/:/DockerShareArea/
  " >>docker-compose.yml

  tasks=()
  progress_bar "PHP" $tasks
}


function setup_mysql() {

  append_to_env \#mysql \n

  port=$(screen_question "Ok,enter Mysql port(default is 3306): " "MYSQL")
  port=${port:-3306}

    append_to_env "MYSQL_PORT=$port"

  database_name=$(screen_question "Ok,enter Mysql database name(default is TestDB): " "MYSQL")
  database_name=${port:-TestDB}

  append_to_env "MYSQL_DATABASE_NAME=$database_name"

  database_root_password=$(screen_question "Ok,enter Mysql database root password(default is root): " "MYSQL")
  database_root_password=${port:-root}

  append_to_env "MYSQL_ROOT_PASSWORD=$database_root_password"

  echo "
## --------------------------------------------
## | 3 : database server
## --------------------------------------------
  mysqldb:
    image: mysql
    restart: always
    environment:
      - MYSQL_DATABASE=\${MYSQL_DATABASE_NAME}
      - MYSQL_ROOT_PASSWORD=\${MYSQL_ROOT_PASSWORD}
    expose:
      - 3306
    ports:
      - \${MYSQL_PORT}:3306
    volumes:
      - "./DockerData/Mysql/:/var/lib/mysql"
      - ./DockerShareArea/Mysql/:/DockerShareArea/
  " >>docker-compose.yml

  tasks=("port" "database_name" "database_root_password")
  progress_bar "Mysql" $tasks
}



function setup_redis() {

  append_to_env \#redis \n

  port=$(screen_question "Ok,enter Redis port(default is 6380): " "REDIS")
  port=${port:-6380}

    append_to_env "REDIS_PORT=$port"

  password=$(screen_question "Ok,enter REDIS database password(default is 123456): " "REDIS")
  password=${port:-123456}

  append_to_env "REDIS_PASSWORD=$password"


echo "
## --------------------------------------------
## | 4 : cache
## --------------------------------------------
  redis:
    image: redis:4.0.10-alpine
    expose:
      - 6379
    command: [
      "sh", "-c",'docker-entrypoint.sh --requirepass "\${REDIS_PASSWORD}"'
    ]
    ports:
      - \${REDIS_PORT}:6379
    volumes:
      - ./DockerConfig/Redis/default.conf:/usr/local/etc/redis/redis.conf
" >>docker-compose.yml

  tasks=("port" "password")
  progress_bar "Redis" $tasks
}

function setup_phpmyadmin() {

  append_to_env \#phpmyadmin \n

  port=$(screen_question "Ok,enter phpmyadmin port(default is 8006): " "PHPMYADMIN")

    port=${port:-8006}

  append_to_env "PHP_MY_ADMIN_PORT=$port"

    echo "
## --------------------------------------------
## | 5 : PhpMyAdmin
## --------------------------------------------
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    depends_on:
      - mysqldb
    expose:
      - '80'
      - '443'
    environment:
      - PMA_HOST=mysqldb
    volumes:
      - /sessions
    ports:
    - \${PHP_MY_ADMIN_PORT}:80
    " >>docker-compose.yml

  tasks=("port")
  progress_bar "Phpmyadmin" $tasks
}

function setup_queue() {
    echo "
## --------------------------------------------
## | 6 : application queue server
## --------------------------------------------
  queued:
    build:
      context: ./DockerConfig/Queue
      dockerfile: Dockerfile
      args:
        WWW_DATA_USER_ID: 1000
    expose:
      - "9001"
    env_file:
      - .env
    ports:
      - "9007:9001"
    volumes:
      - ./ProjectSource:/var/www/html
      - ./DockerConfig/Php/Config/upload.ini:/usr/local/etc/php/conf.d/upload.ini
    " >>docker-compose.yml

  tasks=()
  progress_bar "Queue(Supervisor)" $tasks
}

function setup_elasticsearch() {

  append_to_env \#elasticsearch \n

  port=$(screen_question "Ok,enter Elasticsearch port(default is 9201): " "ELASTICSEARCH")
  port=${port:-9201}

  append_to_env "ELASTICSEARCH_PORT=$port"


  cluster_name=$(screen_question "Ok,enter Elasticsearch cluster name(default is elasticsearch_cluster): " "ELASTICSEARCH")
  cluster_name=${port:-elasticsearch_cluster}

  append_to_env "ELASTICSEARCH_CLUSTER_NAME=$cluster_name"

    echo "
## --------------------------------------------
## | 7 : Elasticsearch search server
## --------------------------------------------
  elasticsearch:
    build:
      context: ./DockerConfig/Elasticsearch
      dockerfile: Dockerfile
      args:
        - UID=1000
        - GID=1000
    environment:
      - cluster.name=\${ELASTICSEARCH_CLUSTER_NAME}
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xmx2g -Xms2g
    ulimits:
      memlock:
        soft: -1
        hard: -1
    expose:
      - "9200"
    ports:
      - \${ELASTICSEARCH_PORT}:9200
    volumes:
      - ./DockerData/Elasticsearch/:/usr/share/elasticsearch/data
      #- ./elasticsearch/config.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - ./DockerShareArea/Elasticsearch/:/DockerShareArea/
    " >>docker-compose.yml

  tasks=("port" "cluster_name")
  progress_bar "Elasticsearch" $tasks
}

function setup_kibana() {

  append_to_env \#kibana \n

  port=$(screen_question "Ok,enter Kibana port(default is 5601): " "KIBANA")
  port=${port:-5601}

  append_to_env "KIBANA_PORT=$port"


    echo "
## --------------------------------------------
## | 8 : Kibana
## --------------------------------------------
  kibana:
    image: docker.elastic.co/kibana/kibana:6.3.2
    depends_on:
      - elasticsearch
    environment:
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    ports:
      - \${KIBANA_PORT}:5601
    volumes:
      - ./DockerConfig/Kibana/kibana.yml:/usr/share/kibana/config/kibana.yml
    " >>docker-compose.yml

  tasks=("port")
  progress_bar "Kibana" $tasks
}

function setup_phpredisadmin() {
  append_to_env \#redis admin client \n

  port=$(screen_question "Ok,enter redis admin client port(default is 8383): " "PHPREDISADMIN")
  port=${port:-8383}

  append_to_env "REDIS_ADMIN_CLIENT_PORT=$port"

  username=$(screen_question "Ok,enter redis admin client username(default is admin): " "PHPREDISADMIN")
  username=${port:-admin}

  append_to_env "REDIS_ADMIN_CLIENT_USERNAME=$username"

  password=$(screen_question "Ok,enter redis admin client password(default is admin): " "PHPREDISADMIN")
  password=${port:-admin}

  append_to_env "REDIS_ADMIN_CLIENT_PASSWORD=$password"


    echo "
## --------------------------------------------
## | 9 : Redis Web Client
## --------------------------------------------
  phpredisadmin:
    build:
      context: ./DockerConfig/Phpredisadmin
      dockerfile: Dockerfile
    environment:
      - ADMIN_USER=\${REDIS_ADMIN_CLIENT_USERNAME}
      - ADMIN_PASS=\${REDIS_ADMIN_CLIENT_PASSWORD}
      - REDIS_1_HOST=redis
      - REDIS_1_PORT=6379
    links:
      - redis
    expose:
      - 80
    ports:
      - \${REDIS_ADMIN_CLIENT_PORT}:80
    " >>docker-compose.yml

  tasks=("port" "username" "password")
  progress_bar "Phpredisadmin" $tasks
}


function setup_mongo() {
  append_to_env \#Mongo DB \n

  port=$(screen_question "Ok,enter MongoDB port(default is 27019): " "MONGO")
  port=${port:-27019}

  append_to_env "MONGODB_PORT=$port"

    echo "
## -------------------------------------------------
## | Mongodb
## -------------------------------------------------
  mongodb:
    image: mongo:3.6.1
    command: mongod
    ports:
      - \${MONGODB_PORT}:27017
    volumes:
      - ./DockerData/Mongo/:/data/db
      - ./DockerShareArea/Mongo/:/DockerShareArea/
    " >>docker-compose.yml

  tasks=()
  progress_bar "MongoDB" $tasks
}


  function progress_bar() {

  tasks=$2
  task_counter=0
  row=1
  COUNT=25
  message=""
  {
  for s in "${tasks[@]}"; do
      echo $COUNT
      echo "XXX"
      echo "Installing . . . \n\n"
      message+="$row) Setup $1  $s \n"
      echo $message
      echo "XXX"
      COUNT=`expr $COUNT + 25`
      task_counter=`expr $task_counter + 1`
      row=`expr $row + 1`
      sleep 1
  done

} | whiptail --gauge "Please wait while we are sleeping..." 15 50 0

}


function append_to_env() {
  echo $1 >> .env
  source ./.env
}

function screen_question() {
    echo $(whiptail --inputbox "$1" 8 78  --title "$2" 3>&1 1>&2 2>&3)
}

